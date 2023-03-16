#!/bin/bash

APP_NAME="Ghidra.app"
ESC_APP_NAME=$(echo "$APP_NAME" | sed 's/ /\\\\ /g')
INFO_PLIST="$APP_NAME/Contents/Info.plist"

APP_DIR="ghidra-app"
ESC_APP_DIR=$(echo "$APP_DIR" | sed 's/ /\\\\ /g')
ICN_NAME="ghidra"
ICN_SRC=""
ICN="$ICN_SRC$ICN_NAME"
TEMP_SCPT="main.scpt"
CMD_PREFIX=""
CMD_FILE="ghidraRun"
ESC_CMD_FILE=$(echo "$CMD_FILE" | sed 's/ /\\\\ /g')

cat > $TEMP_SCPT <<EOF
set scriptPath to POSIX path of (path to me as text)
set parentPath to quoted form of POSIX path of (do shell script "dirname " & quoted form of scriptPath)
do shell script "$CMD_PREFIX " & parentPath & "/$ESC_APP_NAME/Contents/Resources/$ESC_APP_DIR/$ESC_CMD_FILE"
EOF

osacompile -o "$APP_NAME" -x "main.scpt"
/usr/libexec/PlistBuddy -c "Add NSUIElement String 1" "$INFO_PLIST"
/usr/libexec/PlistBuddy -c "Set CFBundleIconFile $ICN_NAME" "$INFO_PLIST"
/usr/libexec/PlistBuddy -c "Add CFBundleVersion String 101" "$INFO_PLIST"
/usr/libexec/PlistBuddy -c "Add CFBundleShortVersionString String 1.0.0" "$INFO_PLIST"
/usr/libexec/PlistBuddy -c "Add NSHumanReadableCopyright String '© 2023 LarsND'" "$INFO_PLIST"

rm "$APP_NAME/Contents/Resources/applet.icns"
cp "$ICN.icns" "$APP_NAME/Contents/Resources/"
cp -r $APP_DIR "$APP_NAME/Contents/Resources/$APP_DIR/"

# Clean
rm $TEMP_SCPT