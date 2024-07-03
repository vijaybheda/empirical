---

# pverify

A new Flutter project.

---

# Automated Android and iOS App Build Script

This script automates the build process for Android and iOS apps, generating APKs and IPAs
respectively. It utilizes Flutter for cross-platform development and jq for JSON processing. The
script now automatically increments the build number in pubspec.yaml with each build and includes
OS-specific behavior.

## Prerequisites

Before running the script, ensure you have the following prerequisites installed:

- [Flutter](https://flutter.dev/docs/get-started/install)
- [jq](https://stedolan.github.io/jq/download/) (for JSON processing)
- [Transporter](https://apps.apple.com/us/app/transporter/id1450874784) (iOS App Deployment -
  Transporter)
- For iOS builds (macOS only):
    - [Xcode](https://developer.apple.com/xcode/)
    - [CocoaPods](https://cocoapods.org/)

## Usage

1. Clone this repository or download the script file (`deploy_script.sh`).
2. Ensure your Flutter environment is set up properly.
3. Place your Flutter project in the same directory as the script.
4. Create a `config.json` file in the same directory as the script with the following structure:

```json
{
  "ANDROID_APPLICATION_ID": "your_android_application_id",
  "APP_NAME": "your_app_name"
}
```

Replace `your_android_application_id` and `your_app_name` with the respective values for your app.

5. Ensure your `pubspec.yaml` file has the correct version and build number set:

```yaml
version: 1.0.0+1  # Format: <version>+<build_number>
```

6. Run the script:

```bash
./deploy_script.sh
```

This script will build both APKs and IPAs for the defined application IDs and app names.

## Output

After successful execution, the script will generate:

- **Android APK:** `output/app/${APP_NAME}_${version}_${build_number}.apk`
- **iOS IPA (macOS only):** `output/app/${APP_NAME}_${version}_${build_number}.ipa`

Where `${APP_NAME}` is derived from `config.json`, and `${version}` and `${build_number}` are
extracted from `pubspec.yaml`.

## Debugging

If you encounter any issues during the build process, please refer to the following tips:

- Ensure all prerequisites are installed correctly.
- Double-check the `config.json` file for any syntax errors or missing values.
- Verify that the package IDs and app names are correctly defined.
- Check the console output for any error messages during the build process.
- Ensure your `pubspec.yaml` file has the correct version and build number format.

## Setting Up Run/Debug Configurations

### Android Studio:

1. Open your Flutter project in Android Studio.
2. Navigate to "Run" > "Edit Configurations..." from the top menu.
3. In the "Run/Debug Configurations" dialog, select your Flutter run configuration.
4. In the "Additional run args" field, add `--dart-define-from-file=config.json`.
5. Click "Apply" then "OK" to save the configuration.

### Visual Studio Code:

1. Open your Flutter project in Visual Studio Code.
2. Navigate to the "Run and Debug" view (Ctrl+Shift+D or Cmd+Shift+D).
3. Click on "create a launch.json file" or open the existing one.
4. Add or modify the Flutter configuration to include:

```json
{
  "name": "Flutter",
  "request": "launch",
  "type": "dart",
  "args": [
    "--dart-define-from-file=config.json"
  ]
}
```

5. Save `launch.json`.

## Notes

- This script detects the operating system and adjusts its behavior accordingly.
- On Windows and Linux, only Android APKs can be built. iOS IPAs require a macOS environment.
- The script will prompt for confirmation on Windows and Linux before proceeding with Android-only
  builds.
- Ensure you have the necessary Android SDK and build tools installed for Android builds on all
  platforms.
- For iOS builds on macOS, make sure you have Xcode and CocoaPods properly set up.
- This script assumes a specific project structure and may need modifications to fit your project's
  layout.
- The script dynamically names the output files based on the app name, version, and build number.
- For iOS builds, ensure you have run `pod install` in the `ios` directory before running the
  script, or let the script handle it.
- The script will continue to the next app if one fails to build, allowing for partial successful
  builds in a multi-app setup.
- Customization of build settings and configurations can be done by modifying the script as needed.
- For more advanced usage and customization, refer to the Flutter, jq, and Xcode documentation.

---