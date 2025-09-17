import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:nutrilens/constants/api.dart';

class GeminiApiRepository {
  final String _apiKey = ApiService().apiKey;

  Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey",
    );

    // Convert image to base64
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {
              "text":
                  "Analyze this food image and return nutrition details ONLY as JSON with fields: "
                  "nameOfFood, calories, protein, fat, carbs, "
                  "goodForWeightLoss, healthBenefits, goodForHealth, "
                  "calories_kcal, protein_g, fat_g, carbs_g."
            },
            {
              "inline_data": {
                "mime_type": "image/jpeg",
                "data": base64Image,
              }
            }
          ]
        }
      ]
    });

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final output =
          data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"] ?? "";

      if (output.isEmpty) throw Exception("No nutrition details found.");

      final jsonText = _extractJson(output);
      return jsonDecode(jsonText);
    } else {
      throw Exception("API Error: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> generateWeightLossPlan() async {
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey",
    );

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {
              "text": """
Generate a 7-day weight loss diet plan in strict JSON only.
Structure:
{
  "dietPlan": {
    "week1": {
      "monday": {
        "veg": {
          "breakfast": {"name": "...", "calories": ...},
          "lunch": {"name": "...", "calories": ...},
          "dinner": {"name": "...", "calories": ...}
        },
        "nonVeg": {
          "breakfast": {"name": "...", "calories": ...},
          "lunch": {"name": "...", "calories": ...},
          "dinner": {"name": "...", "calories": ...}
        }
      },
      ...
    }
  }
}
Return only valid JSON. Do not add explanations or extra text.
"""

            }
          ]
        }
      ]
    });

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final output =
          data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"] ?? "";

      if (output.isEmpty) throw Exception("No diet plan found.");

      final jsonText = _extractJson(output);
      return jsonDecode(jsonText);
    } else {
      throw Exception("API Error: ${response.body}");
    }
  }

  String _extractJson(String text) {
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start != -1 && end != -1) {
      return text.substring(start, end + 1);
    }
    throw Exception("No valid JSON found in response");
  }
}
