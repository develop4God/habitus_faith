import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider para controlar la visibilidad del botón global de agregar hábito
final addHabitButtonVisibleProvider = StateProvider<bool>((ref) => true);
