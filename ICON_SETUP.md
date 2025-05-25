# Icon and Splash Screen Setup Instructions

## Required Steps:

1. **Create PNG version of the app icon:**
   - Convert your SVG icon (`assets/icons/app_icon.svg`) to a PNG file with dimensions of 1024x1024 pixels
   - Save it as `assets/icons/app_icon.png`

2. **Generate app icons:**
   ```
   flutter pub run flutter_launcher_icons
   ```

3. **Generate splash screen:**
   ```
   flutter pub run flutter_native_splash:create
   ```

## Note:
- The app has been renamed to "Moodify" in both Android and iOS configurations
- The icon will have your primary color (#DB324F) as background with a white musical note
- The splash screen will have a black background with your app icon centered

## If you need to make changes:
- Edit the `flutter_launcher_icons` and `flutter_native_splash` sections in `pubspec.yaml`
- Run the generation commands again
