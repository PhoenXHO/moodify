# Emotion-Driven Music Player

## 🛠 Setup Instructions

### 1️⃣ Prerequisites
Make sure you have the following installed:
- **Flutter** (Stable version) → [Install Guide](https://flutter.dev/docs/get-started/install)
- **Android Studio** (for emulator & SDK)
- **VS Code** or **IntelliJ/Android Studio** (for development)
- **Git** (already installed if you cloned the repo)

### 2️⃣ Clone the Repository
```sh
git clone <repo-url>
cd <project-folder>
```

### 3️⃣ Install Dependencies
```sh
flutter pub get
```

### 4️⃣ Setup Android Emulator (or Connect a Physical Device)
#### 📱 **Option 1: Using an Emulator**
1. Open **Android Studio**
2. Go to **Tools > Device Manager**
3. Create and start an **Android Emulator** (API 35 recommended)
You are going to need to have the following installed:
- **Android SDK Platform 35**: Go to **Tools > SDK Manager > SDK Platforms**
- ***Android SDK Build-Tools** (latest)
- ***Android SDK Command-line Tools** (latest)
- ***Android Emulator 35**
- ***Android SDK Platform-Tools** (latest)

\* Go to **Tools > SDK Manager > SDK Tools**

#### 🔌 **Option 2: Using a Physical Device**
1. Enable **Developer Options** & **USB Debugging** on your phone
2. Connect it to your PC via USB
3. Run:
```sh
flutter devices
```
Ensure your device appears in the list.

### 5️⃣ Run the App
```sh
flutter run
```
Choose your emulator/device from the list.

### 🐞 Troubleshooting
- If Flutter doesn't detect your device/emulator:
  ```sh
  flutter doctor --android-licenses
  flutter doctor
  ```
- If you get dependency issues:
  ```sh
  flutter clean
  flutter pub get
  ```