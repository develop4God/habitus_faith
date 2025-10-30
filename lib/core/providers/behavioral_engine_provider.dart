import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/ai/behavioral_engine.dart';

part 'behavioral_engine_provider.g.dart';

@riverpod
BehavioralEngine behavioralEngine(Ref ref) {
  return BehavioralEngine();
}
