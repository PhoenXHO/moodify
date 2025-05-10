class EmotionModel {
  final String emotion;

  EmotionModel({required this.emotion});

  factory EmotionModel.fromJson(Map<String, dynamic> json) {
    return EmotionModel(emotion: json['emotion']);
  }
}
