import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/pet_model.dart';

class PetRepository {
  static const String _petsKey = 'pets';

  Future<List<Pet>> getPets(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final petsJson = prefs.getString(_petsKey);

    if (petsJson == null) return [];

    final List<dynamic> petsList = json.decode(petsJson);
    return petsList
        .map((json) => Pet.fromJson(json as Map<String, dynamic>))
        .where((pet) => pet.userId == userId)
        .toList();
  }

  Future<void> savePet(Pet pet) async {
    final prefs = await SharedPreferences.getInstance();
    final pets = await getPets(pet.userId);

    // Remove existing pet with same ID if it exists
    pets.removeWhere((p) => p.id == pet.id);
    pets.add(pet);

    final petsJson = json.encode(pets.map((p) => p.toJson()).toList());
    await prefs.setString(_petsKey, petsJson);
  }

  Future<void> deletePet(String userId, String petId) async {
    final prefs = await SharedPreferences.getInstance();
    final pets = await getPets(userId);

    pets.removeWhere((p) => p.id == petId);

    final petsJson = json.encode(pets.map((p) => p.toJson()).toList());
    await prefs.setString(_petsKey, petsJson);
  }

  Future<Pet?> getPetById(String userId, String petId) async {
    final pets = await getPets(userId);
    try {
      return pets.firstWhere((pet) => pet.id == petId);
    } catch (e) {
      return null;
    }
  }
}
