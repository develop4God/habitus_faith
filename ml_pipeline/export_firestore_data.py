#!/usr/bin/env python3
"""
Export Firestore ML training data to CSV for model training.

This script:
1. Connects to Firestore using Firebase Admin SDK
2. Queries the ml_training_data collection
3. Exports data to CSV with required ML features
4. Validates minimum record count (50 records)

Usage:
    Place serviceAccountKey.json in ml_pipeline directory
    python export_firestore_data.py
"""

import os
import sys
import firebase_admin
from firebase_admin import credentials, firestore
import pandas as pd
from datetime import datetime


def initialize_firebase():
    """Initialize Firebase Admin SDK with service account credentials."""
    # Check for service account key
    key_path = os.path.join(os.path.dirname(__file__), 'serviceAccountKey.json')
    
    if not os.path.exists(key_path):
        print("❌ Error: serviceAccountKey.json not found in ml_pipeline directory")
        print("   Download it from Firebase Console → Project Settings → Service Accounts")
        sys.exit(1)
    
    try:
        cred = credentials.Certificate(key_path)
        firebase_admin.initialize_app(cred)
        print("✅ Firebase Admin SDK initialized")
    except Exception as e:
        print(f"❌ Failed to initialize Firebase: {e}")
        sys.exit(1)


def export_training_data():
    """Export ml_training_data collection to CSV."""
    db = firestore.client()
    
    # Query all documents from ml_training_data collection
    print("📥 Fetching data from Firestore ml_training_data collection...")
    
    try:
        docs = db.collection('ml_training_data').stream()
        
        records = []
        for doc in docs:
            data = doc.to_dict()
            
            # Extract ML features
            record = {
                'hourOfDay': data.get('hourOfDay'),
                'dayOfWeek': data.get('dayOfWeek'),
                'streakAtTime': data.get('streakAtTime'),
                'failuresLast7Days': data.get('failuresLast7Days'),
                'hoursFromReminder': data.get('hoursFromReminder'),
                'abandoned': not data.get('completed', True),  # abandoned = !completed
            }
            
            # Only include records with all required fields
            if all(v is not None for v in record.values()):
                records.append(record)
            else:
                print(f"⚠️  Skipping incomplete record: {doc.id}")
        
        if not records:
            print("⚠️  No complete records found in ml_training_data collection")
            print("   Make sure app is collecting data with recordCompletionForML()")
            sys.exit(1)
        
        # Create DataFrame
        df = pd.DataFrame(records)
        
        # Validate minimum record count
        if len(df) < 50:
            print(f"⚠️  Need at least 50 records for training, found {len(df)}")
            print(f"   Current records: {len(df)}/50")
            print("   Continue collecting data before training model")
            sys.exit(1)
        
        # Export to CSV
        output_path = os.path.join(os.path.dirname(__file__), 'data', 'training_data.csv')
        df.to_csv(output_path, index=False)
        
        print(f"✅ {len(df)} records exported to {output_path}")
        print(f"\nData summary:")
        print(f"  - Total records: {len(df)}")
        print(f"  - Abandoned: {df['abandoned'].sum()} ({df['abandoned'].sum()/len(df)*100:.1f}%)")
        print(f"  - Completed: {(~df['abandoned']).sum()} ({(~df['abandoned']).sum()/len(df)*100:.1f}%)")
        print(f"\nFeature ranges:")
        print(df.describe())
        
    except Exception as e:
        print(f"❌ Error exporting data: {e}")
        sys.exit(1)


def main():
    """Main execution function."""
    print("=" * 60)
    print("Firestore ML Training Data Exporter")
    print("=" * 60)
    print()
    
    initialize_firebase()
    export_training_data()
    
    print("\n" + "=" * 60)
    print("Export complete! Ready to train model with train_model.py")
    print("=" * 60)


if __name__ == '__main__':
    main()
