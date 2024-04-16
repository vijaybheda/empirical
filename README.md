# pverify

A new Flutter project.

---

# Automated Android and iOS App Build Script

This script automates the build process for Android and iOS apps, generating APKs and IPAs respectively. It utilizes Flutter for cross-platform development and jq for JSON processing.

## Prerequisites

Before running the script, ensure you have the following prerequisites installed:

- [Flutter](https://flutter.dev/docs/get-started/install)
- [jq](https://stedolan.github.io/jq/download/) (for JSON processing)

## Usage

1. Clone this repository or download the script file.
2. Ensure your Flutter environment is set up properly.
3. Place your Flutter project in the same directory as the script.
4. Modify the `package_ids` array in the script to include the package IDs of your Flutter apps.
5. Create a `config.json` file in the same directory as the script with the following structure:

```json
{
    "ANDROID_APPLICATION_ID": "your_android_application_id",
    "APP_SUFFIX": "your_app_suffix",
    "APP_NAME": "your_app_name"
}
```

Replace `your_android_application_id`, `your_app_suffix`, and `your_app_name` with the respective values for your app.

6. Run the script:

```bash
./build_script.sh
```

This script will build both APKs and IPAs for each package ID defined in the `package_ids` array.

Alternatively, to generate APKs specifically, you can run:

```bash
flutter build apk --dart-define-from-file=config.json --profile
```

This command will generate APKs based on the configurations provided in the `config.json` file.

## Debugging

If you encounter any issues during the build process, please refer to the following tips:

- Ensure all prerequisites are installed correctly.
- Double-check the `config.json` file for any syntax errors or missing values.
- Verify that the package IDs in the `package_ids` array are correct.
- Check the console output for any error messages during the build process.

## Generating Apps

Once the script has completed successfully, you can find the generated APKs and IPAs in the `build_output` directory. Each app's output is stored in a separate subdirectory named after its package ID.

## Setting Up Run/Debug Configurations

### Android Studio:

1. Open your Flutter project in Android Studio.
2. Navigate to "Run" > "Edit Configurations..." from the top menu.
3. In the "Run/Debug Configurations" dialog, select your Flutter run configuration.
4. In the "Arguments" field, add `--dart-define-from-file=config.json` as an additional argument.
5. Click "OK" to save the configuration.

### Visual Studio Code:

1. Open your Flutter project in Visual Studio Code.
2. Navigate to the "Run and Debug" view by clicking on the debug icon in the Activity Bar on the side.
3. Click on the gear icon to open `launch.json`, which contains your debug configurations.
4. Find your Flutter debug configuration.
5. Add `"--dart-define-from-file=config.json"` under the `"args"` section of your configuration.
6. Save `launch.json`.

With these configurations in place, you can easily run and debug your Flutter app on real devices with the specified argument.

## Notes

- This script assumes a specific project structure and may need modifications to fit your project's layout.
- Customization of build settings and configurations can be done by modifying the script as needed.
- For more advanced usage and customization, refer to the Flutter and jq documentation.

---