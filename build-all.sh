#!/bin/bash

# PROMPT Genie - Multi-Platform Build Script
# Builds for iOS, Android, and Web platforms
# Usage: ./build-all.sh [platform] [environment]
# Examples:
#   ./build-all.sh all production
#   ./build-all.sh ios development
#   ./build-all.sh android release
#   ./build-all.sh web production

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PLATFORM=${1:-all}
ENVIRONMENT=${2:-production}
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${PROJECT_DIR}/build"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="${PROJECT_DIR}/build_${TIMESTAMP}.log"

# Version from pubspec.yaml
APP_VERSION=$(grep 'version:' "${PROJECT_DIR}/pubspec.yaml" | head -1 | awk '{print $NF}')
VERSION_NAME="${APP_VERSION%%+*}"
VERSION_CODE="${APP_VERSION##*+}"

echo -e "${BLUE}===============================================${NC}"
echo -e "${BLUE}PROMPT Genie - Multi-Platform Build Script${NC}"
echo -e "${BLUE}===============================================${NC}"
echo -e "Platform:    ${YELLOW}${PLATFORM}${NC}"
echo -e "Environment: ${YELLOW}${ENVIRONMENT}${NC}"
echo -e "Version:     ${YELLOW}${VERSION_NAME} (${VERSION_CODE})${NC}"
echo -e "Timestamp:   ${YELLOW}${TIMESTAMP}${NC}"
echo -e "Log:         ${YELLOW}${LOG_FILE}${NC}"
echo -e "${BLUE}===============================================${NC}\n"

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(development|staging|production)$ ]]; then
    echo -e "${RED}✗ Invalid environment: $ENVIRONMENT${NC}"
    echo "  Valid options: development, staging, production"
    exit 1
fi

# Validate platform
if [[ ! "$PLATFORM" =~ ^(all|ios|android|web)$ ]]; then
    echo -e "${RED}✗ Invalid platform: $PLATFORM${NC}"
    echo "  Valid options: all, ios, android, web"
    exit 1
fi

# Helper function for section headers
print_section() {
    echo -e "\n${BLUE}▶ $1${NC}"
}

# Helper function for success message
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Helper function for error message
print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Helper function for warning message
print_warning() {
    echo -e "${YELLOW}! $1${NC}"
}

# Pre-build checks
print_section "Pre-Build Checks"

# Check Flutter
if ! command -v flutter &> /dev/null; then
    print_error "Flutter not found. Please install Flutter SDK."
    exit 1
fi
print_success "Flutter SDK found"

# Check Flutter version
FLUTTER_VERSION=$(flutter --version | head -1 | awk '{print $2}')
print_success "Flutter version: $FLUTTER_VERSION"

# Check dependencies
print_section "Checking Dependencies"

if ! command -v git &> /dev/null; then
    print_warning "Git not found (optional)"
else
    print_success "Git found"
fi

case "$PLATFORM" in
    ios|all)
        if ! command -v xcode-select &> /dev/null; then
            print_warning "Xcode not found (needed for iOS)"
        else
            print_success "Xcode found"
        fi
        ;;
    android|all)
        if [[ -z "$ANDROID_HOME" ]]; then
            print_warning "ANDROID_HOME not set (needed for Android)"
        else
            print_success "Android SDK found at $ANDROID_HOME"
        fi
        ;;
esac

# Clean project
print_section "Cleaning Project"
flutter clean
print_success "Project cleaned"

# Get dependencies
print_section "Getting Dependencies"
flutter pub get
print_success "Dependencies fetched"

# Build for each platform
case "$PLATFORM" in
    all)
        print_section "Building for All Platforms"
        
        # iOS
        echo -e "\n${BLUE}Building for iOS...${NC}"
        ./build-all.sh ios "$ENVIRONMENT" 2>&1 | tee -a "$LOG_FILE"
        
        # Android
        echo -e "\n${BLUE}Building for Android...${NC}"
        ./build-all.sh android "$ENVIRONMENT" 2>&1 | tee -a "$LOG_FILE"
        
        # Web
        echo -e "\n${BLUE}Building for Web...${NC}"
        ./build-all.sh web "$ENVIRONMENT" 2>&1 | tee -a "$LOG_FILE"
        ;;
        
    ios)
        print_section "Building for iOS"
        
        # Determine build type
        case "$ENVIRONMENT" in
            development)
                print_warning "Building iOS Debug APK (development)"
                flutter build ios --debug \
                    --build-name="$VERSION_NAME" \
                    --build-number="$VERSION_CODE" \
                    2>&1 | tee -a "$LOG_FILE"
                print_success "iOS Debug build complete"
                ;;
            staging|production)
                print_warning "Building iOS Release Archive"
                flutter build ios --release \
                    --build-name="$VERSION_NAME" \
                    --build-number="$VERSION_CODE" \
                    2>&1 | tee -a "$LOG_FILE"
                print_success "iOS Release build complete"
                
                # Create archive
                print_section "Creating iOS Archive"
                cd ios
                xcode-select --switch /Applications/Xcode.app/Contents/Developer
                xcodebuild archive \
                    -workspace Runner.xcworkspace \
                    -scheme Runner \
                    -configuration Release \
                    -archivePath "Runner.xcarchive" \
                    -derivedDataPath "DerivedData" \
                    | tail -20 | tee -a "$LOG_FILE"
                cd ..
                print_success "iOS Archive created"
                ;;
        esac
        
        # Output location
        echo -e "\n${YELLOW}Build output: ${BUILD_DIR}/ios/${ENVIRONMENT}${NC}"
        ;;
        
    android)
        print_section "Building for Android"
        
        # Determine build type
        case "$ENVIRONMENT" in
            development)
                print_warning "Building Android Debug APK (development)"
                flutter build apk --debug \
                    --build-name="$VERSION_NAME" \
                    --build-number="$VERSION_CODE" \
                    2>&1 | tee -a "$LOG_FILE"
                print_success "Android Debug APK complete"
                
                # Copy output
                mkdir -p "${BUILD_DIR}/android/debug"
                cp build/app/outputs/apk/debug/app-debug.apk \
                    "${BUILD_DIR}/android/debug/app-${VERSION_NAME}-debug.apk"
                ;;
            staging)
                print_warning "Building Android Release APK (staging)"
                flutter build apk --release \
                    --build-name="$VERSION_NAME" \
                    --build-number="$VERSION_CODE" \
                    2>&1 | tee -a "$LOG_FILE"
                print_success "Android Release APK complete"
                
                # Copy output
                mkdir -p "${BUILD_DIR}/android/staging"
                cp build/app/outputs/apk/release/app-release.apk \
                    "${BUILD_DIR}/android/staging/app-${VERSION_NAME}-staging.apk"
                ;;
            production)
                print_warning "Building Android App Bundle (production)"
                flutter build appbundle --release \
                    --build-name="$VERSION_NAME" \
                    --build-number="$VERSION_CODE" \
                    2>&1 | tee -a "$LOG_FILE"
                print_success "Android App Bundle complete"
                
                # Copy output
                mkdir -p "${BUILD_DIR}/android/production"
                cp build/app/outputs/bundle/release/app-release.aab \
                    "${BUILD_DIR}/android/production/app-${VERSION_NAME}-production.aab"
                ;;
        esac
        
        # Output location
        echo -e "\n${YELLOW}Build output: ${BUILD_DIR}/android/${ENVIRONMENT}${NC}"
        ;;
        
    web)
        print_section "Building for Web"
        
        case "$ENVIRONMENT" in
            development)
                print_warning "Building Web Debug (development)"
                flutter build web --debug \
                    2>&1 | tee -a "$LOG_FILE"
                ;;
            staging|production)
                print_warning "Building Web Release (production-optimized)"
                flutter build web --release \
                    --dart-define=ENVIRONMENT="$ENVIRONMENT" \
                    2>&1 | tee -a "$LOG_FILE"
                ;;
        esac
        
        print_success "Web build complete"
        
        # Copy output
        mkdir -p "${BUILD_DIR}/web/${ENVIRONMENT}"
        cp -r build/web/* "${BUILD_DIR}/web/${ENVIRONMENT}/"
        
        # Create deployment package
        tar -czf "${BUILD_DIR}/web/promptgenie-web-${VERSION_NAME}-${ENVIRONMENT}.tar.gz" \
            -C "${BUILD_DIR}/web/${ENVIRONMENT}" .
        
        echo -e "\n${YELLOW}Build output: ${BUILD_DIR}/web/${ENVIRONMENT}${NC}"
        echo -e "${YELLOW}Archive: ${BUILD_DIR}/web/promptgenie-web-${VERSION_NAME}-${ENVIRONMENT}.tar.gz${NC}"
        ;;
esac

# Summary
print_section "Build Summary"

echo -e "${GREEN}Build completed successfully!${NC}\n"

if [[ "$PLATFORM" == "ios" || "$PLATFORM" == "all" ]]; then
    echo -e "📱 ${YELLOW}iOS${NC}"
    echo "   Build: $(ls -lh build/ios/Release-iphoneos/Runner.app 2>/dev/null | awk '{print $5}' || echo 'Not built')"
fi

if [[ "$PLATFORM" == "android" || "$PLATFORM" == "all" ]]; then
    echo -e "🤖 ${YELLOW}Android${NC}"
    
    if [[ "$ENVIRONMENT" == "production" ]]; then
        SIZE=$(ls -lh build/app/outputs/bundle/release/app-release.aab 2>/dev/null | awk '{print $5}' || echo 'Not built')
        echo "   AAB: $SIZE"
    else
        SIZE=$(ls -lh build/app/outputs/apk/release/app-release.apk 2>/dev/null | awk '{print $5}' || echo 'Not built')
        SIZE_DEBUG=$(ls -lh build/app/outputs/apk/debug/app-debug.apk 2>/dev/null | awk '{print $5}' || echo 'Not built')
        echo "   APK (Release): $SIZE"
        echo "   APK (Debug): $SIZE_DEBUG"
    fi
fi

if [[ "$PLATFORM" == "web" || "$PLATFORM" == "all" ]]; then
    echo -e "🌐 ${YELLOW}Web${NC}"
    SIZE=$(du -sh build/web 2>/dev/null | awk '{print $1}' || echo 'Not built')
    echo "   Output: $SIZE"
    
    # Gzip analysis
    GZIPPED=$(tar -czf /tmp/web-test.tar.gz -C build/web . 2>/dev/null && ls -lh /tmp/web-test.tar.gz | awk '{print $5}')
    echo "   Gzipped: $GZIPPED"
fi

echo -e "\n${BLUE}Build log saved to: ${LOG_FILE}${NC}\n"

# Next steps
print_section "Next Steps"

case "$ENVIRONMENT" in
    development)
        echo "1. Run app on emulator/simulator:"
        echo "   flutter run"
        ;;
    staging)
        echo "1. Test on staging device"
        echo "2. Run tests:"
        echo "   flutter test"
        ;;
    production)
        echo "1. Upload to app stores:"
        echo "   - iOS: Use Transporter or Xcode"
        echo "   - Android: Use Google Play Console"
        echo "   - Web: Use Firebase Hosting or Netlify"
        echo "2. Monitor deployment"
        echo "3. Announce release"
        ;;
esac

print_success "Build script completed"

