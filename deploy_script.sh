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

# Define platform-specific package IDs and app names
android_package_id="com.shareify.inspections"
ios_package_id="com.trt.verify"
app_name="Ver-ify"

# Define common paths
CONFIG_JSON_PATH="$(dirname "${BASH_SOURCE[0]}")/config.json"
output_dir="output/app"

info "Starting build process for $app_name..."

# Update gradle.properties for Android
info "Updating gradle.properties for Android..."
{
    echo "org.gradle.jvmargs=-Xmx1536M"
    echo "android.useAndroidX=true"
    echo "android.enableJetifier=true"
    echo "ANDROID_APPLICATION_ID=$android_package_id"
    echo "APP_NAME=$app_name"
    # Add other properties similarly...
} > android/gradle.properties
info "gradle.properties updated."

# Update iOS configuration
if [ "$OS" = "mac" ]; then
    info "Replacing PRODUCT_BUNDLE_IDENTIFIER in project.pbxproj for iOS..."
    sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = [^;]*;/PRODUCT_BUNDLE_IDENTIFIER = ${ios_package_id};/g" ios/Runner.xcodeproj/project.pbxproj

    info "Updating Info.plist for iOS..."
    /usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $app_name" ios/Runner/Info.plist
fi

info "Running flutter clean..."
flutter clean

info "Running flutter pub get..."
flutter pub get

# Get version info
version_info=$(get_version_info "pubspec.yaml")

# Build Android APK
info "Building Android APK..."
if flutter build apk --dart-define-from-file $CONFIG_JSON_PATH; then
    mkdir -p "$output_dir"
    cp build/app/outputs/flutter-apk/app-release.apk "$output_dir/${app_name}_${version_info}.apk"
    info "Android APK built successfully and renamed."
else
    error "Failed to build Android APK."
fi

# Build iOS IPA (only on macOS)
if [ "$OS" = "mac" ]; then
    info "Running pod install for iOS..."
    (cd ios && pod install)

    info "Building iOS IPA..."
    if flutter build ipa --no-pub --dart-define-from-file $CONFIG_JSON_PATH; then
        mkdir -p "$output_dir"
        ipa_file=$(find build/ios/ipa -name "*.ipa")
        if [ -n "$ipa_file" ]; then
            cp "$ipa_file" "$output_dir/${app_name}_${version_info}.ipa"
            info "iOS IPA built successfully and renamed."
        else
            error "Failed to find the generated .ipa file."
        fi
    else
        error "Failed to build iOS IPA."
    fi
else
    warning "Skipping iOS IPA build as it's not supported on this operating system."
fi

info "Build process completed."
