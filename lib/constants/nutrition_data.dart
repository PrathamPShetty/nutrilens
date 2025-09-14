import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  static const String dietaryHistoryKey = "DietaryHistory";

 
  static Future<void> saveNutritionData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();

 
    final nutritionEntry = {
      "data": data,
      "timestamp": DateTime.now().toIso8601String(),
    };


    List<String> history = prefs.getStringList(dietaryHistoryKey) ?? [];

 
    history.add(jsonEncode(nutritionEntry));

    await prefs.setStringList(dietaryHistoryKey, history);
  }


  static Future<List<Map<String, dynamic>>> getNutritionHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(dietaryHistoryKey) ?? [];

    return history
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .toList();
  }


  static Future<void> clearNutritionHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(dietaryHistoryKey);
  }
}

