# macOS-Ghidra-App
Creates Ghidra.app bundle for macOS. Uses Java-JDK present on your system.

This repository provides a shell script to build a macOS application bundle for [Ghidra](https://github.com/NationalSecurityAgency/ghidra) using the open-source reverse engineering tool's provided `ghidraRun` script.

## Prerequisites

- `iconutil` and `sips` commands
- `osacompile` and `PlistBuddy` commands

## Usage

1. Clone the repository.
2. Download Ghidra ZIP archive from [here](https://github.com/NationalSecurityAgency/ghidra/releases)
3. Extract the ZIP archive to the cloned repository's root directory
4. Rename the extracted directory to `ghidra-app`
5. Place your custom `icon.png` file in the repository's root directory
6. Run the `build-ghidra.sh` script: `./build-ghidra.sh`
7. The generated macOS application bundle `Ghidra.app` will be in the root directory.

## Notes

- The `png-to-icns.sh` script should be run before `build-ghidra.sh` to convert the `icon.png` file to the required `.icns` format.
- The resulting application bundle is tested to work on macOS Ventura (13.2.1).
- The scripts are provided as-is, without warranty of any kind. Use at your own risk.
