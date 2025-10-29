#!/usr/bin/env python3
"""
Train ML model for habit abandonment prediction.

This script:
1. Loads training data from CSV
2. Trains LogisticRegression model with StandardScaler
3. Converts to equivalent Keras model
4. Exports to TFLite format for mobile deployment
5. Saves scaler parameters for inference normalization

Usage:
    python train_model.py
"""

import os
import sys
import json
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix
import tensorflow as tf
from tensorflow import keras


def load_training_data():
    """Load and validate training data from CSV."""
    data_path = os.path.join(os.path.dirname(__file__), 'data', 'training_data.csv')
    
    if not os.path.exists(data_path):
        print("❌ Error: training_data.csv not found")
        print("   Run export_firestore_data.py first to generate training data")
        sys.exit(1)
    
    print(f"📥 Loading training data from {data_path}...")
    df = pd.read_csv(data_path)
    
    # Validate minimum rows
    if len(df) < 50:
        print(f"❌ Error: Need at least 50 records, found {len(df)}")
        sys.exit(1)
    
    print(f"✅ Loaded {len(df)} training records")
    
    # Prepare features and labels
    feature_cols = ['hourOfDay', 'dayOfWeek', 'streakAtTime', 'failuresLast7Days', 'hoursFromReminder']
    X = df[feature_cols].values
    y = df['abandoned'].values.astype(int)
    
    print(f"\nClass distribution:")
    print(f"  - Abandoned (1): {y.sum()} ({y.sum()/len(y)*100:.1f}%)")
    print(f"  - Completed (0): {(~y.astype(bool)).sum()} ({(~y.astype(bool)).sum()/len(y)*100:.1f}%)")
    
    return X, y, feature_cols


def train_sklearn_model(X_train, X_test, y_train, y_test):
    """Train LogisticRegression with StandardScaler."""
    print("\n📊 Training LogisticRegression model...")
    
    # Normalize features
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)
    
    # Train model
    model = LogisticRegression(max_iter=1000, random_state=42)
    model.fit(X_train_scaled, y_train)
    
    # Evaluate
    y_pred = model.predict(X_test_scaled)
    accuracy = accuracy_score(y_test, y_pred)
    
    print(f"\n✅ Model trained successfully")
    print(f"   Accuracy: {accuracy:.2%}")
    print(f"\nClassification Report:")
    print(classification_report(y_test, y_pred, target_names=['Completed', 'Abandoned']))
    print(f"\nConfusion Matrix:")
    print(confusion_matrix(y_test, y_pred))
    
    return model, scaler, accuracy


def create_keras_model(sklearn_model, scaler, n_features):
    """Create equivalent Keras model for TFLite export."""
    print("\n🔄 Converting to Keras model...")
    
    # Extract weights from sklearn model
    coef = sklearn_model.coef_[0]
    intercept = sklearn_model.intercept_[0]
    
    # Create Keras model with similar architecture
    # Using a slightly deeper network for better mobile performance
    model = keras.Sequential([
        keras.layers.Input(shape=(n_features,)),
        keras.layers.Dense(16, activation='relu'),
        keras.layers.Dropout(0.2),
        keras.layers.Dense(8, activation='relu'),
        keras.layers.Dense(1, activation='sigmoid')
    ])
    
    # Compile model
    model.compile(
        optimizer='adam',
        loss='binary_crossentropy',
        metrics=['accuracy']
    )
    
    print("✅ Keras model created")
    
    return model


def train_keras_model(model, X_train, X_test, y_train, y_test, scaler):
    """Train the Keras model."""
    print("\n📊 Training Keras model...")
    
    # Normalize data
    X_train_scaled = scaler.transform(X_train)
    X_test_scaled = scaler.transform(X_test)
    
    # Train with early stopping
    early_stopping = keras.callbacks.EarlyStopping(
        monitor='val_loss',
        patience=10,
        restore_best_weights=True
    )
    
    history = model.fit(
        X_train_scaled, y_train,
        validation_data=(X_test_scaled, y_test),
        epochs=100,
        batch_size=32,
        callbacks=[early_stopping],
        verbose=0
    )
    
    # Evaluate
    loss, accuracy = model.evaluate(X_test_scaled, y_test, verbose=0)
    
    print(f"✅ Keras model trained")
    print(f"   Accuracy: {accuracy:.2%}")
    print(f"   Loss: {loss:.4f}")
    
    return model, accuracy


def export_tflite(keras_model, scaler):
    """Convert Keras model to TFLite and save with scaler params."""
    print("\n📦 Exporting to TFLite format...")
    
    # Convert to TFLite
    converter = tf.lite.TFLiteConverter.from_keras_model(keras_model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    tflite_model = converter.convert()
    
    # Save TFLite model
    assets_dir = os.path.join(os.path.dirname(__file__), '..', 'assets', 'ml_models')
    os.makedirs(assets_dir, exist_ok=True)
    
    tflite_path = os.path.join(assets_dir, 'predictor.tflite')
    with open(tflite_path, 'wb') as f:
        f.write(tflite_model)
    
    tflite_size_mb = len(tflite_model) / (1024 * 1024)
    print(f"✅ TFLite model saved to {tflite_path}")
    print(f"   Size: {tflite_size_mb:.2f} MB")
    
    # Save scaler parameters
    scaler_params = {
        'mean': scaler.mean_.tolist(),
        'scale': scaler.scale_.tolist(),
    }
    
    scaler_path = os.path.join(assets_dir, 'scaler_params.json')
    with open(scaler_path, 'w') as f:
        json.dump(scaler_params, f, indent=2)
    
    print(f"✅ Scaler params saved to {scaler_path}")
    
    return tflite_path, scaler_path, tflite_size_mb


def main():
    """Main execution function."""
    print("=" * 60)
    print("ML Model Training Pipeline")
    print("=" * 60)
    print()
    
    # Load data
    X, y, feature_cols = load_training_data()
    
    # Split data
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )
    
    print(f"\n📊 Data split:")
    print(f"   Training: {len(X_train)} samples")
    print(f"   Testing: {len(X_test)} samples")
    
    # Train sklearn model for baseline
    sklearn_model, scaler, sklearn_accuracy = train_sklearn_model(
        X_train, X_test, y_train, y_test
    )
    
    # Create and train Keras model
    keras_model = create_keras_model(sklearn_model, scaler, len(feature_cols))
    keras_model, keras_accuracy = train_keras_model(
        keras_model, X_train, X_test, y_train, y_test, scaler
    )
    
    # Export to TFLite
    tflite_path, scaler_path, size_mb = export_tflite(keras_model, scaler)
    
    # Summary
    print("\n" + "=" * 60)
    print("Training Complete!")
    print("=" * 60)
    print(f"\n✅ Model Performance:")
    print(f"   - Sklearn accuracy: {sklearn_accuracy:.2%}")
    print(f"   - Keras accuracy: {keras_accuracy:.2%}")
    print(f"   - TFLite size: {size_mb:.2f} MB")
    print(f"\n📁 Output files:")
    print(f"   - {tflite_path}")
    print(f"   - {scaler_path}")
    print(f"\n🚀 Next steps:")
    print(f"   1. Add both files to pubspec.yaml assets")
    print(f"   2. Integrate AbandonmentPredictor service in Flutter")
    print(f"   3. (Optional) Create GitHub release with model files")
    print("=" * 60)


if __name__ == '__main__':
    main()
