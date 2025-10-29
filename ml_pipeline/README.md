# ML Pipeline for Habit Abandonment Prediction

This directory contains the offline training pipeline for the habit abandonment risk predictor.

## Setup

1. **Install Python dependencies:**
   ```bash
   cd ml_pipeline
   pip install -r requirements.txt
   ```

2. **Get Firebase service account key:**
   - Go to Firebase Console → Project Settings → Service Accounts
   - Click "Generate New Private Key"
   - Save as `serviceAccountKey.json` in this directory
   - ⚠️ **Never commit this file to git** (it's in .gitignore)

## Usage

### Export Training Data from Firestore

```bash
python export_firestore_data.py
```

This will:
- Connect to Firestore
- Query the `ml_training_data` collection
- Export to `data/training_data.csv`
- Require minimum 50 records before proceeding

### Train the Model

```bash
python train_model.py
```

This will:
- Load training data from CSV
- Train LogisticRegression and Keras models
- Export TFLite model to `../assets/ml_models/predictor.tflite`
- Save scaler parameters to `../assets/ml_models/scaler_params.json`
- Print accuracy metrics and model size

## Workflow

1. **Data Collection Phase** (2-3 weeks):
   - App users complete/abandon habits
   - Data flows to Firestore `ml_training_data` collection
   - Wait until ≥50 records accumulated

2. **Training Phase** (weekly):
   ```bash
   python export_firestore_data.py
   python train_model.py
   ```

3. **Deployment Phase**:
   - Model files are already in `assets/ml_models/`
   - Flutter app loads them automatically
   - (Optional) Create GitHub release for auto-updates

## Model Retraining

Recommended cadence:
- **First 3 months:** Weekly (model improves as data grows)
- **After stabilization:** Monthly (maintenance updates)

## GitHub Release for Auto-Updates

After training, optionally create a release for automatic model updates:

```bash
gh release create v1.0-ml \
  ../assets/ml_models/predictor.tflite \
  ../assets/ml_models/scaler_params.json \
  --title "ML Model v1.0" \
  --notes "Abandonment predictor trained on N records"
```

The Flutter app will auto-download new models weekly from the latest release.

## Files

- `requirements.txt` - Python dependencies
- `export_firestore_data.py` - Firestore to CSV exporter
- `train_model.py` - Model training script
- `serviceAccountKey.json` - Firebase credentials (git-ignored)
- `data/training_data.csv` - Exported training data (git-ignored)

## Troubleshooting

**"Need at least 50 records"**
- Wait for more users to interact with the app
- Check Firestore console to verify data is being collected

**"serviceAccountKey.json not found"**
- Download from Firebase Console
- Place in `ml_pipeline/` directory

**Model accuracy < 60%**
- Need more diverse training data
- Check class balance in export output
- May need to collect data for longer period
