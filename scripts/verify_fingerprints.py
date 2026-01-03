#!/usr/bin/env python3
"""
Verify that generated fingerprints match Dart's hashCode implementation
This is CRITICAL for cache matching to work in the app
"""

import json
import os
from generate_templates_v2 import generate_fingerprint

def verify_template_fingerprints(templates_dir: str = "habit_templates_v2"):
    """Verify all templates have matching fingerprint in filename and content"""
    
    print("\n" + "="*60)
    print("FINGERPRINT VERIFICATION")
    print("="*60)
    
    if not os.path.exists(templates_dir):
        print(f"❌ Directory {templates_dir} not found")
        return False
    
    files = [f for f in os.listdir(templates_dir) if f.endswith('.json')]
    
    if len(files) == 0:
        print(f"❌ No JSON files found in {templates_dir}")
        return False
    
    print(f"Found {len(files)} template files\n")
    
    mismatches = []
    verified = 0
    
    for filename in sorted(files):
        filepath = os.path.join(templates_dir, filename)
        
        with open(filepath, 'r', encoding='utf-8') as f:
            template = json.load(f)
        
        # Extract fingerprint from filename (remove .json)
        filename_fingerprint = filename[:-5]
        
        # Get fingerprint from template content
        content_fingerprint = template.get("fingerprint")
        
        # Regenerate fingerprint from profile
        profile = template.get("profile", {})
        profile_for_fingerprint = {
            "intent": profile.get("intent"),
            "maturity": profile.get("spiritualMaturity"),  # Map spiritualMaturity -> maturity
            "motivations": profile.get("motivations", []),
            "challenge": profile.get("challenge")
        }
        regenerated_fingerprint = generate_fingerprint(profile_for_fingerprint)

        # Verify all three match
        if filename_fingerprint == content_fingerprint == regenerated_fingerprint:
            verified += 1
            print(f"✅ {filename[:20]:20s} | {template['template_id'][:40]:40s}")
        else:
            mismatches.append({
                "file": filename,
                "filename_fp": filename_fingerprint,
                "content_fp": content_fingerprint,
                "regenerated_fp": regenerated_fingerprint,
                "template_id": template.get("template_id")
            })
    
    print(f"\n{'='*60}")
    print(f"Verified: {verified}/{len(files)}")
    
    if mismatches:
        print(f"❌ Mismatches: {len(mismatches)}\n")
        for mm in mismatches:
            print(f"File: {mm['file']}")
            print(f"  Template ID: {mm['template_id']}")
            print(f"  Filename FP: {mm['filename_fp']}")
            print(f"  Content FP:  {mm['content_fp']}")
            print(f"  Regen FP:    {mm['regenerated_fp']}")
            print()
        return False
    else:
        print("✅ All fingerprints match!")
        return True


def show_sample_dart_comparison():
    """Show sample fingerprint to verify against Dart"""
    
    print("\n" + "="*60)
    print("DART COMPARISON SAMPLE")
    print("="*60)
    print("\nTo verify in Dart, use this profile in your app:")
    print("""
OnboardingProfile(
  primaryIntent: PrimaryIntent.faithBased,
  spiritualMaturity: 'new',
  motivations: ['closerToGod'],
  challenge: 'lackOfTime',
  supportLevel: 'weak'
)
""")
    
    profile = {
        "intent": "faithBased",
        "maturity": "new",
        "motivations": ["closerToGod"],
        "challenge": "lackOfTime"
    }
    
    fingerprint = generate_fingerprint(profile)
    
    print(f"\nExpected fingerprint: {fingerprint}")
    print(f"\nDart code to verify:")
    print("""
final profile = OnboardingProfile(...);  // as above
print('Dart fingerprint: ${profile.cacheFingerprint}');
// Should output: {fingerprint}
""".format(fingerprint=fingerprint))
    
    print("\n✅ If they match, fingerprint algorithm is correct!")
    print("="*60)


if __name__ == "__main__":
    success = verify_template_fingerprints()
    
    if success:
        show_sample_dart_comparison()
    
    exit(0 if success else 1)

