#!/bin/bash

# Functions for colored output
info() {
    printf "\n\033[0;32m[INFO]\033[0m  \033[0;32m$1\033[0m \n"
}

error() {
    printf "\033[0;31m[ERROR]\033[0m $1\n"
}

warning() {
    printf "\033[0;33m[WARNING]\033[0m $1\n"
}

# Check operating system
check_os() {
    case "$(uname -s)" in
        Darwin*)    echo 'mac';;
        Linux*)     echo 'linux';;
        CYGWIN*)    echo 'windows';;
        MINGW*)     echo 'windows';;
        *)          echo 'unknown';;
    esac
}

OS=$(check_os)

# Display warning for Windows users
if [ "$OS" = "windows" ]; then
    warning "You are running this script on a Windows PC."
    warning "iOS IPA generation is not supported on Windows."
    warning "The script will only generate the Android APK."
    read -p "Do you want to continue? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check if jq is installed
if ! command -v jq &>/dev/null; then
    error "jq could not be found. Please install jq for JSON processing."
    exit 1
fi

# Function to extract version and build number from pubspec.yaml
get_version_info() {
    local pubspec_path="$1"
    local version=$(grep 'version:' "$pubspec_path" | awk '{print $2}' | cut -d'+' -f1)
    local build_number=$(grep 'version:' "$pubspec_path" | awk '{print $2}' | cut -d'+' -f2)
    echo "${version}_${build_number}"
}

# List of package IDs
package_ids=(
    "com.trt.verify"
)

# Define common paths
CONFIG_JSON_PATH="$(dirname "${BASH_SOURCE[0]}")/config.json"
output_dir="output/app"

# Loop through package IDs and perform the necessary tasks
for package_id in "${package_ids[@]}"; do
    PACKAGE_NAME="$package_id"
    info "Building $PACKAGE_NAME..."

    # Update gradle.properties
    {
        echo "org.gradle.jvmargs=-Xmx1536M"
        echo "android.useAndroidX=true"
        echo "android.enableJetifier=true"
        echo "ANDROID_APPLICATION_ID=$(jq -r '.ANDROID_APPLICATION_ID' $CONFIG_JSON_PATH)"
        echo "APP_NAME=$(jq -r '.APP_NAME' $CONFIG_JSON_PATH)"
        # Add other properties similarly...
    } > android/gradle.properties
    info "gradle.properties updated."

    # Update iOS configuration
    info "Replacing PRODUCT_BUNDLE_IDENTIFIER in project.pbxproj..."
    sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = [^;]*;/PRODUCT_BUNDLE_IDENTIFIER = ${PACKAGE_NAME};/g" ios/Runner.xcodeproj/project.pbxproj

    APP_NAME=$(jq -r '.APP_NAME' $CONFIG_JSON_PATH)
    sed -i '' "s/\\$(APP_NAME)/${APP_NAME}/g" ios/Runner/Info.plist

    info "Running flutter clean..."
    flutter clean

    info "Running flutter pub get..."
    flutter pub get

    # Get version info
    version_info=$(get_version_info "pubspec.yaml")

    # Build Android APK
    info "Building app apk..."
    if flutter build apk --dart-define-from-file $CONFIG_JSON_PATH; then
        mkdir -p "$output_dir"
        cp build/app/outputs/flutter-apk/app-release.apk "$output_dir/${APP_NAME}_${version_info}.apk"
        info "Android APK built successfully and renamed."
    else
        error "Failed to build Android APK."
        continue  # Skip to the next iteration if APK build fails
    fi

    # Build iOS IPA (only on macOS)
    if [ "$OS" = "mac" ]; then
        # Build iOS IPA
        info "Running pod install..."
        (cd ios && pod install)

        info "Building IPA..."
        if flutter build ipa --no-pub --dart-define-from-file $CONFIG_JSON_PATH; then
            info "Copying and renaming generated .ipa file..."
            mkdir -p "$output_dir"
            cp build/ios/ipa/pverify.ipa "$output_dir/${APP_NAME}_${version_info}.ipa"
            info "iOS IPA built successfully and renamed."
        else
            error "Failed to build iOS IPA."
        fi
    else
        warning "Skipping iOS IPA build as it's not supported on this operating system."
    fi
done

info "Build process completed."
