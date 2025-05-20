import 'dart:io';
import 'package:emotion_music_player/viewmodels/chat_viewmodel.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/emotion_model.dart';

class EmotionViewModel extends ChangeNotifier {
  File? _image;
  EmotionModel? _emotion;
  final ChatViewModel _chatViewModel; // Add reference to ChatViewModel
  bool _isProcessing = false; // Flag to track processing state

  File? get image => _image;
  EmotionModel? get emotion => _emotion;
  bool get isProcessing => _isProcessing;

  // Constructor now requires ChatViewModel to be passed in
  EmotionViewModel(this._chatViewModel);

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;

    _isProcessing = true;
    notifyListeners();

    _image = File(pickedFile.path);
    notifyListeners();
    await analyzeEmotion();
  }

  Future<void> analyzeEmotion() async {
    if (_image == null) return;

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://8f29-102-99-97-235.ngrok-free.app/'),
      );
      request.files
          .add(await http.MultipartFile.fromPath('image', _image!.path));
      var response = await request.send();

      if (response.statusCode == 200) {
        final body = await http.Response.fromStream(response);
        final json = jsonDecode(body.body);
        _emotion = EmotionModel.fromJson(json);

        // After detecting emotion, automatically send message to ChatViewModel
        if (_emotion != null && _emotion!.emotion.isNotEmpty) {
          // Format the message
          final message = "Create ${_emotion!.emotion} playlist";
          // Send to chat service
          await _chatViewModel.sendMessage(message);
        }
      } else {
        _emotion = EmotionModel(emotion: 'Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error analyzing emotion: $e');
      _emotion = EmotionModel(emotion: 'Error: $e');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}
