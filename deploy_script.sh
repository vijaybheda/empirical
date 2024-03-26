#!/bin/bash

# Functions for colored output
info() {
    printf "\n\033[0;32m[INFO]\033[0m  \033[0;32m$1\033[0m \n"
}
error() {
    printf "\033[0;31m[ERROR]\033[0m $1\n"
}


# Check if jq is installed
if ! command -v jq &>/dev/null; then
    error "jq could not be found. Please install jq for JSON processing."
    exit 1
fi

# List of package IDs
package_ids=(
    "com.trt.verify"
)

# Define common paths
#flutter_version_required="3.19.2"

# Check Flutter version
#info "Checking Flutter version..."
#FLUTTER_VERSION=$(fvm flutter --version | grep 'Flutter' | cut -d' ' -f2)
#if [[ "$FLUTTER_VERSION" != "$flutter_version_required" ]]; then
#    error "Flutter version must be $flutter_version_required"
#    exit 1
#fi

# Loop through package IDs and perform the necessary tasks
for package_id in "${package_ids[@]}"; do
    PACKAGE_NAME="$package_id"

    info "Building $PACKAGE_NAME..."

    # here declare or assign config.json file path
    CONFIG_JSON_PATH="$(dirname "${BASH_SOURCE[0]}")/config.json"

    # Append new properties from config.json to gradle.properties
    {
        echo "org.gradle.jvmargs=-Xmx1536M"
        echo "android.useAndroidX=true"
        echo "android.enableJetifier=true"
        echo "ANDROID_APPLICATION_ID=$(jq -r '.ANDROID_APPLICATION_ID' $CONFIG_JSON_PATH)"
        echo "APP_SUFFIX=$(jq -r '.APP_SUFFIX' $CONFIG_JSON_PATH)"
        echo "APP_NAME=$(jq -r '.APP_NAME' $CONFIG_JSON_PATH)"

        # Add other properties similarly...
    } >android/gradle.properties
    info "gradle.properties updated."

    # Replace PRODUCT_BUNDLE_IDENTIFIER with PACKAGE_NAME in ios/Runner.xcodeproj/project.pbxproj
    info "Replacing PRODUCT_BUNDLE_IDENTIFIER in project.pbxproj..."
    sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = [^;]*;/PRODUCT_BUNDLE_IDENTIFIER = ${PACKAGE_NAME};/g" ios/Runner.xcodeproj/project.pbxproj

    info "Running flutter clean..."
    fvm flutter clean

    info "Running flutter pub get..."
    fvm flutter pub get

    info "Building app bundle..."
    fvm flutter build appbundle --dart-define-from-file $CONFIG_JSON_PATH

    build_output_dir="build_output/$PACKAGE_NAME"
    mkdir -p "$build_output_dir"
    cp build/app/outputs/bundle/release/app-release.aab "$build_output_dir/app-release.aab"

    pod install
    info "Running pod install..."
    (cd ios && pod install)

    info "Building IPA..."
    fvm flutter build ipa --no-pub --dart-define-from-file $CONFIG_JSON_PATH

    # Copy the generated .ipa file to the build_output directory
    info "Copying generated .ipa file to the build_output directory..."
    cp build/ios/ipa/pverify.ipa "$build_output_dir/pverify.ipa"
done
