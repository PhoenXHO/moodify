import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/emotion_viewmodel.dart';

class EmotionView extends StatelessWidget {
  const EmotionView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<EmotionViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Detect Emotion')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image preview with border
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: viewModel.image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(viewModel.image!, fit: BoxFit.cover),
                      )
                    : Center(
                        child: Icon(Icons.camera_alt, size: 50, color: Colors.grey[400]),
                      ),
              ),
              
              const SizedBox(height: 20),
              
              // Take Photo Button
              ElevatedButton.icon(
                onPressed: viewModel.isProcessing ? null : () => viewModel.pickImage(),
                icon: Icon(Icons.camera),
                label: Text("Take Photo"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Processing indicator
              if (viewModel.isProcessing)
                Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text(
                      "Analyzing emotion and creating playlist...",
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              
              // Emotion display
              if (!viewModel.isProcessing && viewModel.emotion != null)
                Column(
                  children: [
                    Text(
                      "Detected Emotion:",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      viewModel.emotion?.emotion ?? '',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Creating a playlist based on your emotion...",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Navigate back to chat screen to see the playlist creation process
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.playlist_play),
                      label: Text("Go to Chat"),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}