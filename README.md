# NCRPT Project

## SwiftFormat Command Documentation

## `swift-format format -i EncryptFile --configuration swiftformat --recursive`

The `swift-format format` command is utilized to format Swift source code files using SwiftFormat. This command has several parameters and options:

- **`-i` or `--in-place`:**
  - **Description:** Modifies the files in place.
  - **Usage:** When specified, the original source files will be formatted, and changes will be applied directly to those files.

- **`EncryptFile`:**
  - **Description:** Specifies the target file or directory to be formatted.
  - **Usage:** Replace "EncryptFile" with the path to the Swift file or directory you want to format.

- **`--configuration swiftformat`:**
  - **Description:** Specifies the SwiftFormat configuration file.
  - **Usage:** Indicates that the configuration for the formatting rules should be read from the "swiftformat" configuration file. Adjust the path accordingly if the configuration file is located in a different directory.

- **`--recursive`:**
  - **Description:** Recursively formats all Swift files in the specified directory.
  - **Usage:** When specified, the formatting process is applied not only to the specified file or directory but also to all Swift files found in its subdirectories.

## Example:

```bash
swift-format format -i EncryptFile --configuration swiftformat --recursive
