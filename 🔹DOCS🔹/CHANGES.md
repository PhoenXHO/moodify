This file contains the latest changes made to the project. It is recommended to keep this file updated with each change to ensure that all contributors are aware of the latest modifications. When making changes to the project, please follow the format below to document the changes made. Add your name and the date of the change, and use emojis to indicate the type of change made. This will help keep the changelog organized and easy to read.

Keep in mind that not all changes need to be documented here. Only document changes that are significant or affect the overall functionality of the project.

_Note: Old changes will be grayed out to indicate that they are no longer relevant and will be removed after a certain period._

# Changes Log

## Dependency Updates
<span style="color:gray">**Oussama**: 29-03-2025
- <span style="color:gray">🟩 Add Supabase dependencies
- <span style="color:gray">🟥 Remove Firebase dependencies
- <span style="color:gray">🟩 Add `flutter_dotenv` for environment variable management
- <span style="color:gray">🔷 Change AGP version to `8.4.2` in `android/build.gradle`, `android/gradle.properties`, and `android/gradle/wrapper/gradle-wrapper.properties` due to compatibility issues with the latest Gradle version
- <span style="color:gray">🟩 Add `provider` dependency for state management and MVVM architecture

**Oussama**: 09-04-2025
- 🟩 Add `just_audio` dependency for audio playback
- 🟩 Add `audio_session` dependency for audio session management
- 🟩 Add `just_audio_background` dependency for background audio playback
- 🟩 Add `rxdart` dependency for reactive programming with streams

## Folder Structure and Naming Conventions
### Folders and Files
<span style="color:gray">**Oussama**: 30-03-2025
- <span style="color:gray">🔄 Rename `Widget/` directory to `widgets/`
- <span style="color:gray">🔄 Rename `Playlist/` directory to `playlists/`
- <span style="color:gray">🔄 Rename `pages/` directory to `views/`
- <span style="color:gray">🟥 Remove `Services/` directory
- <span style="color:gray">🔄 Rename `authentication.dart` to `auth_service.dart`
- <span style="color:gray">↪️ Move `views/login.dart` and `views/signup.dart` to `views/auth/`
- <span style="color:gray">🟩 Add `.env` file to the root directory for environment variables
- <span style="color:gray">🟩 Implement an MVVM architecture for the project
	+ 🟩 Add `viewmodels/` directory for view models, and add view models for authentication and favorites
	+ 🟩 Add `models/` directory for data models, and add a song model
	+ 🔷 Initialize providers in `main.dart` for view models

**Oussama**: 09-04-2025
- 🟩 Add `services/` directory for service classes
		
### Code
**Oussama**: 29-03-2025
- <span style="color:gray">🔄 Rename `signupUser()` to `signUp()` in `auth_service.dart`
- <span style="color:gray">🔄 Rename `loginUser()` to `login()` in `auth_service.dart`

## Code Changes
### Authentication
**Oussama**: 29-03-2025
- <span style="color:gray">🔷 Update authentication logic to use Supabase instead of Firebase
	+ Files affected:
		- `auth_service.dart`: `signUp()` and `login()` methods
		- `main.dart`: Initialize Supabase client

### Favorites
**Oussama**: 30-03-2025
- <span style="color:gray">🟩 Add a view model for favorites in `viewmodels/favorites_viewmodel.dart` with the logic to add and remove songs from favorites
- <span style="color:gray">🟩 Add a model for songs in `models/song.dart`
- <span style="color:gray">🟩 Create a `song_widget.dart` file in `widgets/` to display song information
- <span style="color:gray">🟩 Create a `song_list_widget.dart` file in `widgets/` to display a list of songs
- <span style="color:gray">🔷 Improve the UX of the favorites screen by keeping the unfavorited songs in the list until the user refreshes the page or navigates away from the screen
- <span style="color:gray">🟩 Add a loading indicator while fetching the list of songs

### Navigation
**Oussama**: 12-04-2025
- 🔷 Fixed an error when navigating away from the favorites screen.
	+ Files affected:
		- `widgets/bottomnav.dart`: Updated to handle navigation properly
		- `viewmodels/favorites_viewmodel.dart`: Added a method to clear the favorites list silently without notifying listeners
		- `views/favorites.dart`: Updated to use the new method in the view model

### Audio Playback
**Oussama**: 11-04-2025
- 🟩 Implement audio playback functionality with a mini-player
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
**Atae**: 11-04-2025
- 🟩 Add playlist functionality
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

### Authentication
**Atae**: 12-04-2025
- 🟩 Add "Remember Me" functionality
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





## code

	
## najat ##- (Updated authentication and settings management)

🔷 Added fetchUserProfile, updatePassword, updateDisplayName, and updateEmail methods in AuthViewModel

🔷 Added updatePassword, updateDisplayName, and updateEmail methods in AuthRepository

🔷 Added settings view to manage user profile updates

