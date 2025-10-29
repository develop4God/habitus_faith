#!/usr/bin/env python3
"""
Export GitHub Issues ML training data to CSV for model training.

This script:
1. Fetches issues labeled 'ml-training-data' from GitHub
2. Parses JSON data from issue bodies
3. Exports data to CSV with required ML features
4. Validates minimum record count (50 records)

Usage:
    python export_firestore_data.py
"""

import os
import sys
import json
import requests
import pandas as pd
from pathlib import Path


def export_github_issues():
    """Export ML training data from GitHub Issues."""
    print("📥 Fetching ML data from GitHub Issues...")
    
    response = requests.get(
        'https://api.github.com/repos/develop4God/habitus_faith/issues',
        params={'labels': 'ml-training-data', 'state': 'all', 'per_page': 100}
    )
    
    if response.status_code != 200:
        print(f"❌ GitHub API error: {response.status_code}")
        print(f"   Response: {response.text[:200]}")
        sys.exit(1)
    
    issues = response.json()
    
    if len(issues) < 50:
        print(f"⚠️  Only {len(issues)} records. Need ≥50 for training.")
        print(f"   Current records: {len(issues)}/50")
        print("   Continue collecting data before training model")
        sys.exit(1)
    
    # Parse JSON from issue bodies
    records = []
    for issue in issues:
        try:
            data = json.loads(issue['body'])
            
            # Extract ML features
            record = {
                'hourOfDay': data.get('hourOfDay'),
                'dayOfWeek': data.get('dayOfWeek'),
                'streakAtTime': data.get('streakAtTime'),
                'failuresLast7Days': data.get('failuresLast7Days'),
                'hoursFromReminder': data.get('hoursFromReminder'),
                'completed': data.get('completed'),
            }
            
            # Only include records with all required fields
            if all(v is not None for k, v in record.items()):
                records.append(record)
            else:
                print(f"⚠️  Skipping incomplete record: {issue['title']}")
        except (json.JSONDecodeError, KeyError) as e:
            print(f"⚠️  Skipping invalid issue {issue.get('number', '?')}: {e}")
            continue
    
    if not records:
        print("❌ No valid records found in GitHub Issues")
        print("   Make sure app is collecting data with recordCompletionForML()")
        sys.exit(1)
    
    # Create DataFrame
    df = pd.DataFrame(records)
    
    # Convert to binary target
    df['abandoned'] = (~df['completed']).astype(int)
    df = df.drop('completed', axis=1)
    
    # Validate minimum record count after filtering
    if len(df) < 50:
        print(f"⚠️  Need at least 50 valid records for training, found {len(df)}")
        print(f"   Current valid records: {len(df)}/50")
        sys.exit(1)
    
    # Save to CSV
    Path('data').mkdir(exist_ok=True)
    output_path = 'data/training_data.csv'
    df.to_csv(output_path, index=False)
    
    print(f"✅ {len(df)} records exported to {output_path}")
    print(f"\nData summary:")
    print(f"  - Total records: {len(df)}")
    print(f"  - Abandoned: {df['abandoned'].sum()} ({df['abandoned'].sum()/len(df)*100:.1f}%)")
    print(f"  - Completed: {(~df['abandoned'].astype(bool)).sum()} ({(~df['abandoned'].astype(bool)).sum()/len(df)*100:.1f}%)")
    print(f"\nFeature ranges:")
    print(df.describe())
    
    return True


def main():
    """Main execution function."""
    print("=" * 60)
    print("GitHub Issues ML Training Data Exporter")
    print("=" * 60)
    print()
    
    export_github_issues()
    
    print("\n" + "=" * 60)
    print("Export complete! Ready to train model with train_model.py")
    print("=" * 60)


if __name__ == '__main__':
    main()
