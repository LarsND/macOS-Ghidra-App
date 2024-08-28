#!/bin/bash

# Vragen of er al een icns bestand is
read -p "Is there an existing .icns file? (y/n): " hasIcnsFile

if [ "$hasIcnsFile" = "y" ]; then
  # Vragen naar de locatie van het bestaande icns bestand
  read -p "Enter the path to the .icns file: " icnsFilePath
  if [ ! -f "$icnsFilePath" ]; then
    echo "Icon file not found: $icnsFilePath"
    exit 1
  fi
  ICN="$icnsFilePath"
else
  # Vragen of er een icns bestand gegenereerd moet worden van een afbeelding
  read -p "Do you want to generate a .icns file from an image? (y/n): " generateIcns

  if [ "$generateIcns" = "y" ]; then
    # Vragen om de naam en extensie van het icoonbestand
    read -p "Enter the name of the icon (with extension, e.g., icon.png): " iconName
    iconFile="$iconName"
    if [ ! -f "$iconFile" ]; then
      echo "Icon file not found: $iconFile"
      exit 1
    fi

    # Iconset map aanmaken
    mkdir "${iconName}.iconset"

    # Genereren van de icoongroottes
    sips -z 16 16     "$iconFile" --out "${iconName}.iconset/icon_16x16.png"
    sips -z 32 32     "$iconFile" --out "${iconName}.iconset/icon_16x16@2x.png"
    sips -z 32 32     "$iconFile" --out "${iconName}.iconset/icon_32x32.png"
    sips -z 64 64     "$iconFile" --out "${iconName}.iconset/icon_32x32@2x.png"
    sips -z 128 128   "$iconFile" --out "${iconName}.iconset/icon_128x128.png"
    sips -z 256 256   "$iconFile" --out "${iconName}.iconset/icon_128x128@2x.png"
    sips -z 256 256   "$iconFile" --out "${iconName}.iconset/icon_256x256.png"
    sips -z 512 512   "$iconFile" --out "${iconName}.iconset/icon_256x256@2x.png"
    sips -z 512 512   "$iconFile" --out "${iconName}.iconset/icon_512x512.png"
    cp "$iconFile" "${iconName}.iconset/icon_512x512@2x.png"

    # Converteren naar icns
    iconutil -c icns "${iconName}.iconset"

    # Verwijderen van de iconset map
    rm -R "${iconName}.iconset"

    # Verplaatsen van het gegenereerde icns bestand naar de juiste locatie
    ICN="${iconName}.icns"
  fi
fi

# Applicatie naam en plist pad definiëren
APP_NAME="Ghidra.app"
INFO_PLIST="$APP_NAME/Contents/Info.plist"

# Dynamisch AppleScript genereren
TEMP_SCPT="main.scpt"
CMD_PREFIX=""
CMD_FILE="ghidraRun"
APP_DIR="ghidra-app"

cat > $TEMP_SCPT <<EOF
set UnixPath to POSIX path of ((path to me as text) & "::")
set appName to name of current application

do shell script "$CMD_PREFIX " & quoted form of (UnixPath & appName & ".app/Contents/Resources/$APP_DIR/$CMD_FILE")
EOF

# AppleScript compileren
osacompile -o "$APP_NAME" -x "$TEMP_SCPT" || { echo "Compilatie mislukt, script wordt afgebroken."; exit 1; }

ICN_NAME="AppIcon"

# Wijzigen van Info.plist
/usr/libexec/PlistBuddy -c "Add NSUIElement String 1" "$INFO_PLIST"
/usr/libexec/PlistBuddy -c "Set CFBundleIconFile $ICN_NAME" "$INFO_PLIST"
/usr/libexec/PlistBuddy -c "Add CFBundleVersion String 101" "$INFO_PLIST"
/usr/libexec/PlistBuddy -c "Add CFBundleShortVersionString String 1.0.1" "$INFO_PLIST"
/usr/libexec/PlistBuddy -c "Add NSHumanReadableCopyright String '© 2024 LarsND'" "$INFO_PLIST"

# Verwijderen van het oude icoon en plaatsen van het nieuwe icoon
rm "$APP_NAME/Contents/Resources/applet.icns"
cp "$ICN" "$APP_NAME/Contents/Resources/$ICN_NAME.icns"

# Controleren of de extra resources map bestaat
if [ ! -d "$APP_DIR" ]; then
  mkdir "$APP_DIR"
  echo -e "\033[1mWarning: The directory $APP_DIR did not exist and has been created as an empty directory.\033[0m"
fi

# Kopiëren van de extra resources
cp -r "$APP_DIR" "$APP_NAME/Contents/Resources/$APP_DIR/"

# Opruimen
rm "$TEMP_SCPT"