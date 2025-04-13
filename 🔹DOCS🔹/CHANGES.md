This file contains the latest changes made to the project. It is recommended to keep this file updated with each change to ensure that all contributors are aware of the latest modifications. When making changes to the project, please follow the format below to document the changes made. Add your name and the date of the change, and use emojis to indicate the type of change made. This will help keep the changelog organized and easy to read.

Keep in mind that not all changes need to be documented here. Only document changes that are significant or affect the overall functionality of the project.

When checking the changes made, please confirm that you have read everything by adding your initial followed by a checkmark (e.g., "A ✅" for Atae, "N ✅" for Najat, etc.) at the end of each section. This will help ensure that all contributors are aware of the changes made, and thus, we can clear the outdated changes from the file to keep it clean and organized.

# Changes Log

## Dependency Updates
**Oussama**: 29-03-2025 - _(add your confirmation here)_ **A ✅**
- 🟩 Add Supabase dependencies
- 🟥 Remove Firebase dependencies
- 🟩 Add `flutter_dotenv` for environment variable management
- 🔷 Change AGP version to `8.4.2` in `android/build.gradle`, `android/gradle.properties`, and `android/gradle/wrapper/gradle-wrapper.properties` due to compatibility issues with the latest Gradle version
- 🟩 Add `provider` dependency for state management and MVVM architecture

## Folder Structure and Naming Conventions
### Folders and Files
**Oussama**: 30-03-2025 - _(add your confirmation here)_ **A ✅**
- 🔄 Rename `Widget/` directory to `widgets/`
- 🔄 Rename `Playlist/` directory to `playlists/`
- 🔄 Rename `pages/` directory to `views/`
- 🟥 Remove `Services/` directory
- 🔄 Rename `authentication.dart` to `auth_service.dart`
- ↪️ Move `views/login.dart` and `views/signup.dart` to `views/auth/`
- 🟩 Add `.env` file to the root directory for environment variables
- 🟩 Implement an MVVM architecture for the project
	+ 🟩 Add `viewmodels/` directory for view models, and add view models for authentication and favorites
	+ 🟩 Add `models/` directory for data models, and add a song model
	+ 🔷 Initialize providers in `main.dart` for view models
		
### Code
**Oussama**: 29-03-2025 - _(add your confirmation here)_ **A ✅**
- 🔄 Rename `signupUser()` to `signUp()` in `auth_service.dart`
- 🔄 Rename `loginUser()` to `login()` in `auth_service.dart`

## Code Changes
### Authentication
**Oussama**: 29-03-2025 - _(add your confirmation here)_ **A ✅**
- 🔷 Update authentication logic to use Supabase instead of Firebase
	+ Files affected:
		- `auth_service.dart`: `signUp()` and `login()` methods
		- `main.dart`: Initialize Supabase client

### Favorites
**Oussama**: 30-03-2025 - _(add your confirmation here)_ **A ✅**
- 🟩 Add a view model for favorites in `viewmodels/favorites_viewmodel.dart` with the logic to add and remove songs from favorites
- 🟩 Add a model for songs in `models/song.dart`
- 🟩 Create a `song_widget.dart` file in `widgets/` to display song information
- 🟩 Create a `song_list_widget.dart` file in `widgets/` to display a list of songs
- 🔷 Improve the UX of the favorites screen by keeping the unfavorited songs in the list until the user refreshes the page or navigates away from the screen
- 🟩 Add a loading indicator while fetching the list of songs

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
        - 🟩 Create new playlists
        - 🟩 View list of playlists
        - 🟩 Edit playlist details
        - 🟩 Delete playlists
        - 🔷 Add loading states and error handling
        - 🟩 Implement pull-to-refresh functionality
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
        - 🟩 Add remember me checkbox to login screen
        - 🟩 Implement credential persistence using SharedPreferences
        - 🟩 Auto-fill credentials on app launch if previously saved
    + Dependencies added:
        - 🟩 Add shared_preferences package
    + UI improvements:
        - 🟩 Adjust checkbox padding and visual density
        - 🟩 Improve form validation and error handling





## code

	
## najat ##- (Updated authentication and settings management)

🔷 Added fetchUserProfile, updatePassword, updateDisplayName, and updateEmail methods in AuthViewModel

🔷 Added updatePassword, updateDisplayName, and updateEmail methods in AuthRepository

🔷 Added settings view to manage user profile updates

