import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:yaml/yaml.dart';

import '../utils/yaml_util.dart';

class AiService {
  // This class is responsible for handling AI-related operations

  Map<String, dynamic>? _aiConfig;

  // Singleton pattern
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  Future<void> init() async {
    try {
      // Load AI configuration from YAML file
      final configString = await rootBundle.loadString('assets/ai_config.yaml');
      final yamlMap = loadYaml(configString);

      _aiConfig = convertYamlToMap(yamlMap);
      if (_aiConfig == null) {
        throw Exception('Failed to load AI configuration');
      }
    } catch (e) {
      print('Error loading AI configuration: $e');
      throw Exception('Failed to load AI configuration');
    }
  }

  // Renamed from processUserMessage to reflect its core task
  // Returns the raw response string from the AI
  Future<String> getAiResponse(String prompt, String chatHistory) async {
    if (_aiConfig == null) {
      await init(); // Ensure config is loaded
    }

    final apiKey = dotenv.env['OPENROUTER_API_KEY'];
    if (apiKey == null) {
      throw Exception('OPENROUTER_API_KEY not found in .env file');
    }

    final messages = [
      // Standard system prompts from config
      { 'role': 'system', 'content': _aiConfig!['system_prompt'] },
      { 'role': 'system', 'content': _aiConfig!['context'] },
      { 'role': 'system', 'content': _aiConfig!['rules'] },
      { 'role': 'system', 'content': _aiConfig!['personality'] },
      { 'role': 'system', 'content': _aiConfig!['instructions'] },
      // Add chat history if it's not empty/default
      if (chatHistory != 'CHAT HISTORY: None')
        { 'role': 'system', 'content': chatHistory },
      // The user's current message or the formatted prompt
      { 'role': 'user', 'content': prompt },
    ];

    final response = await http.post(
      Uri.parse("https://openrouter.ai/api/v1/chat/completions"),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
        'X-Title': 'Moodify', // Optional: Project identifier for OpenRouter
      },
      body: jsonEncode({
        'model': _aiConfig!['model'],
        'messages': messages,
      })
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Check if choices array is present and not empty
      if (data['choices'] != null && data['choices'].isNotEmpty) {
        final message = data['choices'][0]['message']['content'];
        return message.trim();
      } else {
        print('Error: AI response missing choices - ${response.body}');
        throw Exception('Failed to parse AI response: No choices found');
      }
    } else {
      print('Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load AI response (Status code: ${response.statusCode})');
    }
  }

  // Static helper method to attempt parsing a function call from the response
  static Map<String, dynamic>? tryParseFunctionCall(String response) {
    try {
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}');

      if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
        final jsonString = response.substring(jsonStart, jsonEnd + 1);
        final decodedJson = jsonDecode(jsonString);

        // Check if it looks like our expected function call structure
        if (decodedJson is Map<String, dynamic> &&
            decodedJson.containsKey('function') &&
            decodedJson.containsKey('parameters') &&
            decodedJson['parameters'] is Map<String, dynamic>) {
          print('Function call detected: $decodedJson');
          return decodedJson;
        }
      }
    } catch (e) {
      // Ignore parsing errors, means it's likely not a JSON function call
      print('Could not parse potential function call: $e');
    }
    return null; // Not a valid function call according to our structure
  }
}