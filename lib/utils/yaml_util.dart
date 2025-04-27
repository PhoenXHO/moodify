import 'package:yaml/yaml.dart';

// Helper method to convert YamlMap to Map<String, dynamic>
Map<String, dynamic> convertYamlToMap(YamlMap yamlMap) {
  return yamlMap.map((key, value) {
    if (value is YamlMap) {
      return MapEntry(key, convertYamlToMap(value));
    } else if (value is YamlList) {
      return MapEntry(key, convertYamlToList(value));
    } else {
      return MapEntry(key, value);
    }
  });
}

// Helper method to convert YamlList to List<dynamic>
List<dynamic> convertYamlToList(YamlList yamlList) {
  return yamlList.map((value) {
    if (value is YamlMap) {
      return convertYamlToMap(value);
    } else if (value is YamlList) {
      return convertYamlToList(value);
    } else {
      return value;
    }
  }).toList();
}