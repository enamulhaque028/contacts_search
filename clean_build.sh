#!/bin/bash

# -----------------------------------------------------------------------------
# Script: clean_build.sh
# Created by: MD ENAMUL HAQUE
# Description:
# This script automates the process of cleaning the Flutter project, fetching
# the necessary dependencies, and setting up the iOS environment based on the 
# user's platform choice. It supports Android, iOS, and both platforms.
# -----------------------------------------------------------------------------
# Usage:
# 1. Grant execute permissions: `chmod +x ./clean_build.sh`
# 2. Run the script: `./clean_build.sh`
# -----------------------------------------------------------------------------

# Define color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'  # No Color

# Function to clean the project and fetch dependencies
clean_and_fetch_dependencies() {
  echo -e "${GREEN}🔧 Cleaning project and fetching dependencies...${NC}"
  flutter clean
  flutter pub get
  dart run build_runner build --delete-conflicting-outputs
  # flutter gen-l10n
}

# Function to install CocoaPods. Flutter only creates ios/Podfile when a
# package has native iOS code, so without it there is nothing to install.
install_pods() {
  if [ ! -f ios/Podfile ]; then
    echo -e "${YELLOW}ℹ️ No ios/Podfile (no native iOS plugins), skipping pod install.${NC}"
    return
  fi

  cd ios
  pod install
  cd ..
}

# Function to configure Android
configure_android() {
  echo -e "${GREEN}✔️ Configuring Android 📱...${NC}"
  # No further tasks for Android
  echo -e "${GREEN}✅ Android configuration completed successfully!${NC}"
}

# Function to configure iOS
configure_ios() {
  echo -e "${GREEN}✔️ Configuring iOS 🍏...${NC}"
  install_pods
  echo -e "${GREEN}✅ iOS configuration completed successfully!${NC}"
}

# Function to configure Both Android and iOS
configure_both() {
  echo -e "${GREEN}✔️ Configuring Both Android 📱 and iOS 🍏...${NC}"
  install_pods
  echo -e "${GREEN}✅ Both Android 📱 and iOS 🍏 configuration completed successfully!${NC}"
}

# Function to show the main menu and get the user input
show_menu() {
  echo -e "${BLUE}🚀 Select the platform(s) to configure:${NC}"
  echo -e "${YELLOW}1. Android 📱${NC}"
  echo -e "${YELLOW}2. iOS 🍏${NC}"
  echo -e "${YELLOW}3. Both 📱🍏${NC}"
  echo -e "${YELLOW}4. Exit ❌${NC}"
}

# Loop to keep asking until a valid choice is made
while true; do
  # Show the menu
  show_menu
  read -p "Enter your choice (1/2/3/4): " choice

  # Validate the user's choice and call the appropriate function
  case $choice in
    1)
      clean_and_fetch_dependencies
      configure_android
      break
      ;;
    2)
      clean_and_fetch_dependencies
      configure_ios
      break
      ;;
    3)
      clean_and_fetch_dependencies
      configure_both
      break
      ;;
    4)
      echo -e "${RED}❌ Exiting the script. Goodbye!${NC}"
      exit 0
      ;;
    *)
      echo -e "${RED}❌ Invalid choice. Please select a valid option (1/2/3/4).${NC}"
      ;;
  esac
done