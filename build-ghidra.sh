#!/bin/bash

APP_NAME="Ghidra.app"
INFO_PLIST="$APP_NAME/Contents/Info.plist"

GHIDRA_APP_DIR="ghidra-app/"
TEMP_SCPT="main.scpt"

cat > $TEMP_SCPT <<EOF
set scriptPath to POSIX path of (path to me as text)
set parentPath to POSIX path of (do shell script "dirname " & quoted form of scriptPath)
do shell script (parentPath & "/$APP_NAME/Contents/Resources/$GHIDRA_APP_DIR/ghidraRun")
EOF

osacompile -o "$APP_NAME" -x "main.scpt"
/usr/libexec/PlistBuddy -c "Add NSUIElement String 1" "$INFO_PLIST"
/usr/libexec/PlistBuddy -c "Set CFBundleIconFile ghidra" "$INFO_PLIST"
/usr/libexec/PlistBuddy -c "Add CFBundleVersion String 101" "$INFO_PLIST"
/usr/libexec/PlistBuddy -c "Add CFBundleShortVersionString String 1.0.0" "$INFO_PLIST"
/usr/libexec/PlistBuddy -c "Add NSHumanReadableCopyright String '© 2023 LarsND'" "$INFO_PLIST"

rm "$APP_NAME/Contents/Resources/applet.icns"
cp "ghidra.icns" "$APP_NAME/Contents/Resources/"
cp -r $GHIDRA_APP_DIR "$APP_NAME/Contents/Resources/$GHIDRA_APP_DIR/"

# Clean
rm $TEMP_SCPT