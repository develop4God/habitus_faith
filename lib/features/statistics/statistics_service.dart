import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'statistics_model.dart';
import 'dart:convert';

class StatisticsService {
  static const String statsKey = 'user_statistics';

  /// Flag para activar/desactivar sync con Firestore (preparado para Remote Config)
  static bool firebaseSyncEnabled = true;

  /// Guardar estadísticas localmente y (opcional) en Firestore
  Future<void> saveStatistics(StatisticsModel stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(statsKey, jsonEncode(stats.toJson()));
    debugPrint('💾 [StatisticsService] Estadísticas guardadas localmente');

    if (firebaseSyncEnabled) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          debugPrint(
            '⚠️ [StatisticsService] Usuario no autenticado, no se puede sincronizar con Firestore',
          );
          return;
        }
        final firestore = FirebaseFirestore.instance;
        await firestore
            .collection('user_statistics')
            .doc(user.uid)
            .set(stats.toJson());
        debugPrint(
          '☁️ [StatisticsService] Estadísticas sincronizadas en Firestore para usuario: ${user.uid}',
        );
      } catch (e) {
        debugPrint(
          '❌ [StatisticsService] Error al sincronizar estadísticas en Firestore: $e',
        );
      }
    } else {
      debugPrint('🚫 [StatisticsService] Sync con Firestore desactivado');
    }
  }

  /// Cargar estadísticas localmente (no cambia)
  Future<StatisticsModel> loadStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(statsKey);
    if (jsonString == null) return StatisticsModel.empty();
    return StatisticsModel.fromJson(jsonDecode(jsonString));
  }

  /// Limpiar estadísticas localmente y en Firestore si está activo
  Future<void> clearStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(statsKey);
    debugPrint('🗑️ [StatisticsService] Estadísticas locales eliminadas');

    if (firebaseSyncEnabled) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          debugPrint(
            '⚠️ [StatisticsService] Usuario no autenticado, no se puede borrar en Firestore',
          );
          return;
        }
        final firestore = FirebaseFirestore.instance;
        await firestore.collection('user_statistics').doc(user.uid).delete();
        debugPrint(
          '🗑️☁️ [StatisticsService] Estadísticas eliminadas en Firestore para usuario: ${user.uid}',
        );
      } catch (e) {
        debugPrint(
          '❌ [StatisticsService] Error al borrar estadísticas en Firestore: $e',
        );
      }
    }
  }
}
