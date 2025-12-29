#!/usr/bin/env python3
"""
Comprehensive template validation script
Validates:
1. All templates have correct structure
2. Fingerprints match between Python and expected Dart output
3. Habits are properly selected based on profile
4. Templates are ready for integration
"""

import json
import os
import sys
from pathlib import Path
from typing import Dict, List
from generate_templates_v2 import generate_fingerprint

# Colors for terminal output
class Colors:
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    BOLD = '\033[1m'
    END = '\033[0m'

def validate_template_structure(template: Dict, filename: str) -> List[str]:
    """Validate template has correct structure"""
    errors = []
    
    # Required top-level fields
    required_fields = ["template_id", "fingerprint", "version", "profile", "habits"]
    for field in required_fields:
        if field not in template:
            errors.append(f"Missing required field: {field}")
    
    # Check version
    if template.get("version") != "2.0":
        errors.append(f"Invalid version: {template.get('version')}, expected 2.0")
    
    # Check profile structure
    profile = template.get("profile", {})
    profile_required = ["intent", "motivations", "challenge", "supportLevel"]
    for field in profile_required:
        if field not in profile:
            errors.append(f"Profile missing field: {field}")
    
    # Check habits
    habits = template.get("habits", [])
    if len(habits) < 3:
        errors.append(f"Template has only {len(habits)} habits (minimum 3)")
    
    if len(habits) > 6:
        errors.append(f"Template has {len(habits)} habits (maximum 6)")
    
    # Validate each habit
    habit_required = ["id", "nameKey", "category", "emoji", "target_minutes", "notification_key"]
    for i, habit in enumerate(habits):
        for field in habit_required:
            if field not in habit:
                errors.append(f"Habit {i} ({habit.get('id', 'unknown')}) missing field: {field}")
        
        # Validate target_minutes
        if habit.get("target_minutes", 0) < 5:
            errors.append(f"Habit {i} has target_minutes < 5: {habit.get('target_minutes')}")
    
    # Validate fingerprint matches filename
    fingerprint = template.get("fingerprint", "")
    expected_filename = f"{fingerprint}.json"
    if filename != expected_filename:
        errors.append(f"Filename mismatch: {filename} != {expected_filename}")
    
    return errors

def validate_fingerprint_matching(template: Dict) -> List[str]:
    """Validate fingerprint matches what Dart would generate"""
    errors = []
    
    profile = template.get("profile", {})
    
    # Reconstruct the fingerprint (handle None same as generator)
    python_fingerprint = generate_fingerprint({
        "intent": profile.get("intent", ""),
        "maturity": profile.get("spiritualMaturity") or "",  # Convert None to ""
        "motivations": profile.get("motivations", []),
        "challenge": profile.get("challenge", "")
    })
    
    template_fingerprint = template.get("fingerprint", "")
    
    if python_fingerprint != template_fingerprint:
        errors.append(f"Fingerprint mismatch: generated={python_fingerprint}, template={template_fingerprint}")
    
    return errors

def validate_habit_selection(template: Dict) -> List[str]:
    """Validate habits are appropriate for profile"""
    errors = []
    
    profile = template.get("profile", {})
    habits = template.get("habits", [])
    intent = profile.get("intent", "")
    support_level = profile.get("supportLevel", "")
    challenge = profile.get("challenge", "")
    
    # Count habits by category
    categories = {}
    for habit in habits:
        cat = habit.get("category", "unknown")
        categories[cat] = categories.get(cat, 0) + 1
    
    # Validate based on intent
    if intent == "faithBased":
        if "spiritual" not in categories:
            errors.append("FaithBased template has no spiritual habits")
        
        expected_count = 4 if support_level == "weak" else 5
        if len(habits) != expected_count and len(habits) != 5:
            errors.append(f"FaithBased expected {expected_count} habits, got {len(habits)}")
    
    elif intent == "wellness":
        if "physical" not in categories and "mental" not in categories:
            errors.append("Wellness template has no physical or mental habits")
        
        expected_count = 5 if support_level != "weak" else 6
        if len(habits) != expected_count and len(habits) != 5:
            errors.append(f"Wellness expected {expected_count} habits, got {len(habits)}")
    
    elif intent == "both":
        if "spiritual" not in categories:
            errors.append("Both template missing spiritual habits")
        if "physical" not in categories:
            errors.append("Both template missing physical habits")
        
        expected_count = 5 if support_level != "weak" else 6
        if len(habits) != expected_count:
            errors.append(f"Both expected {expected_count} habits, got {len(habits)}")
    
    # Validate durations for lackOfTime challenge
    if challenge == "lackOfTime":
        for habit in habits:
            if habit.get("target_minutes", 0) > 15:
                errors.append(f"Challenge lackOfTime but habit {habit.get('id')} has {habit.get('target_minutes')} minutes (max 15)")
    
    return errors

def validate_all_templates(directory: str = "habit_templates_v2") -> bool:
    """Validate all templates in directory"""
    template_dir = Path(directory)
    
    if not template_dir.exists():
        print(f"{Colors.RED}✗ Directory not found: {directory}{Colors.END}")
        return False
    
    json_files = list(template_dir.glob("*.json"))
    
    if len(json_files) == 0:
        print(f"{Colors.RED}✗ No JSON files found in {directory}{Colors.END}")
        return False
    
    print(f"{Colors.BOLD}Validating {len(json_files)} templates...{Colors.END}\n")
    
    total_errors = 0
    valid_count = 0
    
    for json_file in sorted(json_files):
        try:
            with open(json_file, 'r', encoding='utf-8') as f:
                template = json.load(f)
            
            filename = json_file.name
            all_errors = []
            
            # Run all validations
            all_errors.extend(validate_template_structure(template, filename))
            all_errors.extend(validate_fingerprint_matching(template))
            all_errors.extend(validate_habit_selection(template))
            
            if all_errors:
                print(f"{Colors.RED}✗ {filename}{Colors.END}")
                for error in all_errors:
                    print(f"  - {error}")
                print()
                total_errors += len(all_errors)
            else:
                print(f"{Colors.GREEN}✓ {filename}{Colors.END}")
                valid_count += 1
        
        except json.JSONDecodeError as e:
            print(f"{Colors.RED}✗ {json_file.name} - Invalid JSON: {e}{Colors.END}\n")
            total_errors += 1
        except Exception as e:
            print(f"{Colors.RED}✗ {json_file.name} - Error: {e}{Colors.END}\n")
            total_errors += 1
    
    # Summary
    print(f"\n{Colors.BOLD}{'='*60}{Colors.END}")
    print(f"{Colors.BOLD}VALIDATION SUMMARY{Colors.END}")
    print(f"{Colors.BOLD}{'='*60}{Colors.END}")
    print(f"Total templates: {len(json_files)}")
    print(f"{Colors.GREEN}Valid: {valid_count}{Colors.END}")
    print(f"{Colors.RED}Invalid: {len(json_files) - valid_count}{Colors.END}")
    print(f"{Colors.YELLOW}Total errors: {total_errors}{Colors.END}")
    
    if total_errors == 0:
        print(f"\n{Colors.GREEN}{Colors.BOLD}✓ ALL TEMPLATES VALID! Ready for integration.{Colors.END}")
        return True
    else:
        print(f"\n{Colors.RED}{Colors.BOLD}✗ Fix errors before proceeding.{Colors.END}")
        return False

def test_sample_profiles():
    """Test fingerprint generation for sample profiles"""
    print(f"\n{Colors.BOLD}Testing Sample Profile Fingerprints:{Colors.END}\n")
    
    test_profiles = [
        {
            "name": "New FaithBased - Lack of Time",
            "intent": "faithBased",
            "maturity": "new",
            "motivations": ["closerToGod"],
            "challenge": "lackOfTime"
        },
        {
            "name": "Wellness - Reduce Stress",
            "intent": "wellness",
            "maturity": "",
            "motivations": ["reduceStress", "physicalHealth"],
            "challenge": "lackOfMotivation"
        },
        {
            "name": "Both - Growing - Time Management",
            "intent": "both",
            "maturity": "growing",
            "motivations": ["closerToGod", "timeManagement"],
            "challenge": "dontKnowStart"
        }
    ]
    
    for profile in test_profiles:
        fingerprint = generate_fingerprint(profile)
        print(f"{Colors.BLUE}{profile['name']}{Colors.END}")
        print(f"  Fingerprint: {fingerprint}")
        print(f"  Would look for: {fingerprint}.json")
        print()

if __name__ == "__main__":
    print(f"{Colors.BOLD}{'='*60}{Colors.END}")
    print(f"{Colors.BOLD}HABIT TEMPLATE VALIDATION{Colors.END}")
    print(f"{Colors.BOLD}{'='*60}{Colors.END}\n")
    
    # Test fingerprint generation
    test_sample_profiles()
    
    # Validate templates
    success = validate_all_templates("habit_templates_v2")
    
    # Also validate assets directory if it exists
    assets_dir = "../assets/habit_templates_v2"
    if os.path.exists(assets_dir):
        print(f"\n{Colors.BOLD}Validating assets directory...{Colors.END}\n")
        assets_success = validate_all_templates(assets_dir)
        success = success and assets_success
    
    sys.exit(0 if success else 1)

