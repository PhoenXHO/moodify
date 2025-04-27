This file contains the latest changes made to the project. It is recommended to keep this file updated with each change to ensure that all contributors are aware of the latest modifications. When making changes to the project, please follow the format below to document the changes made. Add your name and the date of the change, and use emojis to indicate the type of change made. This will help keep the changelog organized and easy to read.

Keep in mind that not all changes need to be documented here. Only document changes that are significant or affect the overall functionality of the project.

_Note: Old changes will be grayed out to indicate that they are no longer relevant and will be removed after a certain period._

# Changes Log

## Dependency Updates
<span style="color:gray">**Oussama**: 09-04-2025
- <span style="color:gray">🟩 Add `just_audio` dependency for audio playback
- <span style="color:gray">🟩 Add `audio_session` dependency for audio session management
- <span style="color:gray">🟩 Add `just_audio_background` dependency for background audio playback
- <span style="color:gray">🟩 Add `rxdart` dependency for reactive programming with streams

**Oussama**: 20-04-2025
- 🟩 Add `http` dependency for making HTTP requests (used by AI service)
- 🟩 Add `yaml` dependency for parsing YAML configuration files (used by AI service)

## Folder Structure and Naming Conventions
### Folders and Files
<span style="color:gray">**Oussama**: 09-04-2025
- <span style="color:gray">🟩 Add `services/` directory for service classes

**Oussama**: 19-04-2025
- 🔄 Rename `PlaylistSong.dart` to `playlist_song.dart`
- 🔄 Rename `Credentials.dart` to `credentials.dart`
- 🔄 Rename `playlist_detail.dart` to `playlist_contents.dart`
- 🔄 Rename `PlaylistRepository.dart` to `playlist_repository.dart`

**Oussama**: 20-04-2025
- 🟩 Add new files and directories:
  - `assets/ai_config.yaml` - Configuration for AI chat assistant
  - `lib/models/chat_message.dart` - Data model for chat messages
  - `lib/models/credentials.dart` - Model for storing login credentials
  - `lib/models/playlist_song.dart` - Model for playlist-song relationships
  - `lib/repositories/chat_repository.dart` - Database interactions for chat
  - `lib/repositories/playlist_repository.dart` - Repository for playlist management
  - `lib/services/ai_service.dart` - Integration with AI model API
  - `lib/services/chat_service.dart` - Business logic for chat functionality
  - `lib/utils/yaml_util.dart` - Utilities for YAML parsing
  - `lib/viewmodels/chat_viewmodel.dart` - View model for chat screen
  - `lib/viewmodels/playlists_viewmodel.dart` - View model for playlists
  - `lib/widgets/message_bubble.dart` - UI component for chat messages
  - `lib/views/playlist_contents.dart` - Screen for playlist details
- 🔄 Fix imports in multiple files to use correct naming conventions

**Oussama**: 27-04-2025
- 🔄 Fix imports in `main.dart` to use correct case for `playlists_viewmodel.dart`
- 🔄 Update implementations for `ChatViewModel` and `ChatScreen` for better robustness
- 🟩 Create error handling mechanisms in AI chat feature

### Code
<span style="color:gray">**Oussama**: 29-03-2025
- <span style="color:gray">🔄 Rename `signupUser()` to `signUp()` in `auth_service.dart`
- <span style="color:gray">🔄 Rename `loginUser()` to `login()` in `auth_service.dart`

## Code Changes
### Authentication
<span style="color:gray">**Oussama**: 29-03-2025
- <span style="color:gray">🔷 Update authentication logic to use Supabase instead of Firebase
	+ Files affected:
		- `auth_service.dart`: `signUp()` and `login()` methods
		- `main.dart`: Initialize Supabase client

### Favorites
**Oussama**: 19-04-2025
- 🔷 Updated the Song model to use `favorite_count` instead of `favorites`
- 🔷 Enhanced `SongRepository` to update favorite counts when toggling favorites
  + Added proper increment/decrement logic of favorite counts
  + Added safeguard to prevent negative favorite counts

### Navigation
<span style="color:gray">**Oussama**: 12-04-2025
- <span style="color:gray">🔷 Fixed an error when navigating away from the favorites screen.
	+ Files affected:
		- `widgets/bottomnav.dart`: Updated to handle navigation properly
		- `viewmodels/favorites_viewmodel.dart`: Added a method to clear the favorites list silently without notifying listeners
		- `views/favorites.dart`: Updated to use the new method in the view model

### Audio Playback
<span style="color:gray">**Oussama**: 11-04-2025
- <span style="color:gray">🟩 Implement audio playback functionality with a mini-player
  + Files added:
    - `services/audio_service.dart`: Service for managing audio playback
    - `widgets/mini_player.dart`: Mini player that appears at the bottom of the screen
    - `viewmodels/player_viewmodel.dart`: View model for managing audio playback
  + Files modified:
    - `widgets/song_widget.dart`: Updated to play songs when tapped
    - `widgets/bottomnav.dart`: Updated to include the mini-player
    - `main.dart`: Updated to initialize the audio session and register the PlayerViewModel
	- `AndroidManifest.xml`: Added permissions for audio playback as well as the service and receiver for background audio playback
	- `MainActivity.kt`: Updated to handle background audio playback and notifications

### Playlists
<span style="color:gray">**Atae**: 11-04-2025
- <span style="color:gray">🟩 Add playlist functionality
    + Files added:
        - `models/playlist.dart`: Model for playlists
        - `views/playlists.dart`: Main playlists screen
        - `views/playlist_detail.dart`: Playlist details screen
        - `viewmodels/playlists_viewmodel.dart`: ViewModel for playlist operations
        - `repositories/playlist_repository.dart`: Repository for Supabase interactions
    + Features implemented:
        - Create new playlists
        - View list of playlists
        - Edit playlist details
        - Delete playlists
        - Add loading states and error handling
        - Implement pull-to-refresh functionality
    + Database changes:
        - 🟩 Create `playlists` table in Supabase
        - 🟩 Create `playlist_songs` junction table
        - 🟩 Add RLS policies for playlist security

**Oussama**: 20-04-2025
- 🔷 Implement proper MVVM architecture for playlist management:
  + Created `PlaylistRepository` for database operations
  + Created `PlaylistsViewModel` to manage state and business logic
  + Fixed import paths for renamed files
  + Added proper error handling and loading states
  + Implemented song reordering in playlists

**Oussama**: 27-04-2025
- 🔷 Fixed playlist path imports in remaining files
- 🔷 Updated `PlaylistDetailScreen` to work with the new architecture
- 🔷 Enhanced error handling in song deletion from playlists

### Authentication
<span style="color:gray">**Atae**: 12-04-2025
- <span style="color:gray">🟩 Add "Remember Me" functionality
    + Files added:
        - `models/credentials.dart`: Model for storing login credentials
    + Files modified:
        - `repositories/auth_repository.dart`: Add credential persistence methods
        - `views/auth/login.dart`: Add remember me checkbox and persistence logic
    + Features implemented:
        - Add remember me checkbox to login screen
        - Implement credential persistence using SharedPreferences
        - Auto-fill credentials on app launch if previously saved
    + Dependencies added:
        - 🟩 Add `shared_preferences` package
    + UI improvements:
        - 🔷 Adjust checkbox padding and visual density
        - 🔷 Improve form validation and error handling

### Chat Feature
**Oussama**: 20-04-2025
- 🟩 Implement AI assistant chat feature:
  + Create chat message UI with sender-specific styling
  + Add `ChatViewModel` for managing chat state and interaction logic
  + Implement `ChatService` for chat business logic
  + Add `ChatRepository` for Supabase database interactions
  + Create `ChatMessage` model for structured message data
  + Add `AiService` to interface with OpenRouter API (using Gemma model)
  + Add configuration file (`assets/ai_config.yaml`) for AI personality and behavior
  + Register `ChatViewModel` provider in `main.dart`
  + Add `OPENROUTER_API_KEY` environment variable in `.env`
  + Implement chat history persistence and retrieval
  + Add option to clear chat history

**Oussama**: 27-04-2025
- 🔷 Enhanced chat functionality:
  + Improved error handling for AI service connectivity issues
  + Added auto-scroll to bottom when new messages are added
  + Fixed issue with message rendering when AI service is slow
  + Optimized chat history retrieval to reduce bandwidth usage
  + Added loading indicator during AI response generation
  + Implemented graceful fallbacks when AI service fails

### Documentation
**Oussama**: 20-04-2025
- 🔷 Update `DATABASE.md` to include the `chats` table schema with proper foreign key constraints
- 🔷 Add AI Assistant section to `NOTES.md` with feature ideas and improvements

**Oussama**: 27-04-2025
- 🔷 Updated `NOTES.md` with additional AI assistant feature ideas
- 🔷 Fixed formatting in `DATABASE.md` to improve readability
- 🟩 Added environment variable documentation in a new `ENVIRONMENT.md` file
