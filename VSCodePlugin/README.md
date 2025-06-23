# Rune DSL VS Code Extension

> ⚠️ **EXPERIMENTAL EXTENSION - USE AT YOUR OWN RISK**
> 
> This extension is currently in experimental development and is incomplete. It is provided for testing and evaluation purposes only. Features may not work as expected, and the extension may cause instability in VS Code. 
>
> A formal, production-ready version will be published through official channels in due course. Use this experimental version at your own discretion and risk.

Visual Studio Code extension providing language support for the Rune DSL (Rosetta Domain Specific Language). This extension enables syntax highlighting, error checking, auto-completion, and other language features for `.rosetta` files.

## Features

- **Syntax Highlighting**: Rich syntax highlighting for Rosetta DSL files
- **Error Checking**: Real-time diagnostics and error reporting
- **Auto-completion**: Intelligent code completion suggestions
- **Hover Information**: Detailed information on hover for symbols and types
- **Code Formatting**: Automatic code formatting capabilities
- **Quick Fixes**: Automated code actions and refactoring suggestions
- **Copy Basic Types**: Command to copy basic Rosetta types to your workspace
- **Remote GitHub Integration**: Automatically download latest basic types from GitHub
- **Java Code Generation**: Configurable automatic Java code generation from Rosetta files
- **Startup Prompts**: Optional popups for basic types and code generation settings
- **Cross-platform Support**: Works on Windows, WSL, Linux, and macOS
- **🤖 GitHub Copilot Integration**: Enhanced support for AI-powered coding assistance
- **📝 Rich Code Snippets**: Comprehensive snippet library for common Rune DSL patterns
- **🎯 Context-Aware Suggestions**: Improved language configuration for better AI understanding
- **⚡ Smart Code Templates**: Quick insertion of common patterns and structures
- **🔧 Copilot-Optimized Settings**: Specialized configuration options for AI assistance

## Prerequisites

### Required Software

- **Java 11+**: Required for the language server (tested with OpenJDK 21.0.7 LTS)
- **Maven 3.6+**: For building the project (tested with Apache Maven 3.9.9)
- **Node.js 18+**: For building the VS Code extension (tested with Node.js 22.16.0)
- **Git**: For cloning the repository
- **VS Code**: Version 1.73.0 or higher

### Platform-Specific Setup

#### Windows
- Install Java from [Adoptium](https://adoptium.net/) or similar
- Install Maven from [Apache Maven](https://maven.apache.org/download.cgi)
- Install Node.js from [nodejs.org](https://nodejs.org/)
- Ensure all tools are in your PATH

#### WSL (Windows Subsystem for Linux)
If you're using WSL, you need to install the Linux versions of the tools within WSL:

```bash
# Install Java (OpenJDK 21)
sudo apt update
sudo apt install openjdk-21-jdk

# Install Maven
sudo apt install maven

# Install Node.js (latest LTS)
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify installations
java -version    # Should show OpenJDK 21.0.7 or similar
mvn --version    # Should show Apache Maven 3.9.9 or similar  
node --version   # Should show v22.x.x or similar
npm --version    # Should show 10.x.x or similar
```

#### Linux/macOS
- Use your package manager to install Java, Maven, and Node.js
- Or install from the official websites linked above

## Quick Start (Standalone Build)

⚠️ **Important**: This repository comes in a **clean/unbuilt state**. You must run a build script before the extension will work.

👉 **For step-by-step instructions, see [QUICKSTART.md](QUICKSTART.md)**

This extension can now be built completely standalone by automatically pulling from the GitHub repository:

### Option 1: Automatic Build (Recommended)

```bash
# Clone just the extension directory or download it separately
# Navigate to the extension directory
cd path/to/rune-dsl-vscode-extension

# Run the build script (Linux/macOS/WSL)
./build-extension.sh

# Or on Windows (PowerShell - recommended)
pwsh -ExecutionPolicy Bypass -File build-extension.ps1

# The script will:
# 1. Clone the latest Rune DSL from https://github.com/finos/rune-dsl
# 2. Build it with Maven
# 3. Copy all required files into the extension
# 4. Compile the TypeScript extension
```

> **Note for Windows Users**: PowerShell is the recommended build environment for Windows. The legacy batch script (`build-extension.bat`) has been deprecated due to reliability issues.

### Option 2: Development in Full Repository

If you want to develop within the full Rune DSL repository:

```bash
# Clone the full repository
git clone https://github.com/finos/rune-dsl.git
cd rune-dsl

# Build the entire project
mvn clean install -DskipTests

# Navigate to the VS Code extension
cd rosetta-ide/vscode

# Install npm dependencies and compile
npm install
npm run compile
```

## Build Scripts

The extension provides several build commands:

### Cross-Platform Build Scripts

- **`./build-extension.sh`** (Linux/macOS/WSL): Complete standalone build
- **`build-extension.ps1`** (Windows PowerShell): Complete standalone build for PowerShell
- **`npm run build-extension`**: Calls the shell script version
- **`npm run build-extension-ps`**: Calls the Windows PowerShell version

### Development Scripts

- **`npm run compile`**: Compile TypeScript only
- **`npm run watch`**: Watch mode for TypeScript compilation
- **`npm run clean`**: Clean all build artifacts (Unix)
- **`npm run clean-ps`**: Clean all build artifacts (Windows PowerShell)
- **`npm run build`**: Build extension and create VSIX package

### Environment Variables

- **`RUNE_DSL_BRANCH`**: Specify which branch to build from (default: `main`)

```bash
# Build from a specific branch
RUNE_DSL_BRANCH=develop ./build-extension.sh
```

## Development Testing

### F5 Testing (Development)

For development and testing, you can use the built-in VS Code Extension Development Host:

#### Prerequisites for Development
1. Ensure all dependencies are built:
   ```bash
   # Run the build script first
   ./build-extension.sh
   
   # Or if already built, just compile TypeScript
   ./node_modules/.bin/tsc
   ```

2. Open the extension directory in VS Code

#### Testing Process
1. **Press `F5`** - This launches a new Extension Development Host window
2. **Create or open a `.rosetta` file** in the new window to test the extension
3. **Test all features**:
   - Syntax highlighting should work immediately
   - Language server features (errors, completions, etc.) should activate
   - Try the "Copy Basic Rosetta Types to Workspace" command
   - Test the "Restart Language Server" command

#### Development Tips
- **Watch Mode**: Use `./node_modules/.bin/tsc --watch` for automatic TypeScript compilation during development
- **Reload Extension**: Use `Ctrl+R` (Cmd+R on Mac) in the Extension Development Host to reload after changes
- **Debug Console**: Check the Debug Console in the main VS Code window for extension logs
- **Language Server Logs**: Set `runeDsl.languageServer.traceLevel` to `verbose` and check the Output panel

#### WSL Development Notes
- If you're developing in WSL, make sure to run all commands within the WSL environment
- The extension will automatically handle WSL/Windows path conversions at runtime
- Use `./node_modules/.bin/tsc` instead of `npx tsc` to avoid path issues

### VSIX Package Creation

```bash
# Build and create installable package
./build-extension.sh --create-vsix

# Or using npm (builds first, then creates VSIX)
npm run build-vsix

# This creates: rune-language-5.0.0.vsix
```

## File Structure (After Build)

After running the build script, the extension will have this structure:

```
plugin/
├── src/
│   ├── extension.ts          # Main extension code
│   ├── rosetta/              # Embedded language server
│   │   ├── bin/              # Executables (rune-dsl-ls, rune-dsl-ls.bat)
│   │   └── repo/             # JAR dependencies
│   ├── generated/            # Generated code (when enabled)
│   └── test/                 # Test files
├── syntaxes/                 # Syntax highlighting rules
│   └── rosetta.tmLanguage.json
├── resources/                # Embedded templates and config
│   ├── templates/            # Basic type templates
│   │   ├── basictypes.rosetta
│   │   └── annotations.rosetta
│   └── config/               # Configuration files
├── snippets/                 # Code snippets for Copilot integration
│   └── rosetta.json
├── out/                      # Compiled TypeScript
│   └── extension.js
├── build-info.json          # Build metadata
├── language-configuration.json  # Language configuration for VS Code
└── package.json             # Extension manifest
```

## Configuration

The extension provides several configuration options accessible via VS Code settings:

### Language Features
- `runeDsl.linting.enableDiagnostics`: Enable real-time error checking
- `runeDsl.linting.enableSemanticHighlighting`: Enable advanced syntax highlighting
- `runeDsl.linting.enableHover`: Enable hover information
- `runeDsl.linting.enableCompletion`: Enable auto-completion
- `runeDsl.linting.enableFormatting`: Enable code formatting
- `runeDsl.linting.enableInlayHints`: Enable type hints
- `runeDsl.linting.enableCodeActions`: Enable quick fixes

### Language Server
- `runeDsl.languageServer.traceLevel`: Set communication trace level (`off`, `messages`, `verbose`)
- `runeDsl.languageServer.javaOpts`: Custom JVM options (default: `-Xmx8g -XX:+UseG1GC -XX:+UseStringDeduplication -Djava.awt.headless=true -Dfile.encoding=UTF-8`)
- `runeDsl.languageServer.timeout`: Timeout in seconds for language server startup (default: 60)
- `runeDsl.languageServer.semanticTokenTimeout`: Timeout in seconds for semantic token requests (default: 30)

### Performance Settings
- `runeDsl.performance.enableProgressReporting`: Show progress indicators for file scanning and workspace analysis (default: true)
- `runeDsl.performance.maxFilesForSemanticTokens`: Maximum number of Rosetta files before disabling semantic tokens (default: 1000)

### Code Generation
- `runeDsl.codeGeneration.enableJavaGeneration`: Enable automatic Java code generation (default: false)
- `runeDsl.codeGeneration.outputPath`: Output directory for generated Java code (default: `src/generated`)

### Templates
- `runeDsl.templates.basicTypesPath`: Custom path to basic types template files (leave empty to use embedded)

### Startup Behavior
- `runeDsl.startup.promptForBasicTypes`: Show startup prompt to copy basic types from GitHub
- `runeDsl.startup.showCodeGenerationInfo`: Show startup message about Java code generation settings

### GitHub Copilot Integration
- `runeDsl.copilot.enableContextEnhancement`: Enable automatic context enhancement for better AI suggestions (default: true)
- `runeDsl.copilot.showHintsOnTypeChange`: Show Copilot integration hints when editing files (default: false)
- `runeDsl.copilot.enableSmartComments`: Automatically add contextual comments for better AI understanding (default: true)

## Commands

The extension provides the following commands accessible via the Command Palette (`Ctrl+Shift+P`):

### Core Commands
- **Copy Basic Rosetta Types to Workspace**: Copies `basictypes.rosetta` and `annotations.rosetta` to your workspace
- **Copy Basic Rune DSL Types from GitHub**: Downloads latest `basictypes.rosetta` and `annotations.rosetta` directly from GitHub
- **Toggle Java Code Generation**: Quickly enable/disable Java code generation with automatic language server restart
- **Open Rune DSL Settings**: Quick access to extension settings
- **Restart Language Server**: Restart the language server if issues occur

### GitHub Copilot Integration Commands
- **Rune DSL: Enhance Context for Copilot**: Provides detailed context to AI about your current Rune DSL file
- **Rune DSL: Insert Template for Copilot**: Inserts structured templates optimized for AI assistance
- **Rune DSL: Configure Copilot Integration**: Quick access to Copilot-related settings and configuration

## Java Code Generation

The Rune DSL extension can automatically generate Java code from your Rosetta files. This feature is **disabled by default** to avoid cluttering your workspace.

### Configuration

- **Enable/Disable**: Set `runeDsl.codeGeneration.enableJavaGeneration` to `true` or `false`
- **Output Directory**: Configure the output path with `runeDsl.codeGeneration.outputPath` (default: `src/generated`)
- **Quick Toggle**: Use the "Toggle Java Code Generation" command for instant on/off switching

### Startup Behavior

When the extension first loads, it will show an informational message about the current Java code generation status:

- **If disabled**: "Java code generation is currently disabled. You can enable it in the extension settings if needed."
- **If enabled**: "Java code generation is enabled. Generated files will be placed in the configured output directory."

You can disable this startup message by setting `runeDsl.startup.showCodeGenerationInfo` to `false`.

### Generated Files

When enabled, Java files will be automatically generated in the configured output directory (default: `src/generated`) whenever you save Rosetta files. The generated code includes:

- Java classes for Rosetta data types
- Validation logic
- Serialization/deserialization code
- Builder patterns for complex types

## Cross-Platform Support

This extension works seamlessly across different platforms:

### Windows
- Uses `.bat` scripts for language server execution
- Automatic Java detection via PATH or JAVA_HOME
- PowerShell build script (`build-extension.ps1`) for reliable cross-platform support

### WSL (Windows Subsystem for Linux)
- Intelligent detection of WSL environment
- Path conversion between Windows and WSL formats
- Fallback to direct JAR execution if scripts fail

### Linux/macOS
- Uses shell scripts for language server execution
- Automatic executable permission handling
- Standard Unix path conventions

## Automatic Updates

The build script automatically pulls the latest version of Rune DSL from GitHub, ensuring you always get the latest language server features:

```bash
# This will pull the latest changes and rebuild
./build-extension.sh

# Or specify a branch
RUNE_DSL_BRANCH=develop ./build-extension.sh
```

## Troubleshooting

### Build Issues

1. **Prerequisites Missing**: Ensure Java 11+, Maven, Node.js, and Git are installed
2. **Network Issues**: Ensure you can access https://github.com/finos/rune-dsl.git
3. **Permission Issues**: On Unix systems, make sure the script is executable:
   ```bash
   chmod +x build-extension.sh
   ```

### Language Server Won't Start

1. **Java Not Found**: Ensure Java 11+ is installed and in PATH
2. **Build Issues**: Run the build script again to ensure all files are present
3. **Permission Issues**: The extension automatically handles executable permissions

### Debug Mode

Enable verbose logging by setting `runeDsl.languageServer.traceLevel` to `verbose` in VS Code settings, then check the Output panel for detailed logs.

## Build Information

After building, check `build-info.json` for details about the build:

```json
{
  "buildDate": "2025-06-20T12:00:00Z",
  "runeDslCommit": "abc123...",
  "runeDslCommitDate": "2025-06-20 11:30:00 +0000",
  "repository": "https://github.com/finos/rune-dsl.git",
  "branch": "main"
}
```

## Contributing

This extension is part of the [FINOS Rune DSL](https://github.com/finos/rune-dsl) project. Contributions are welcome!

## Documentation

- **[QUICKSTART.md](QUICKSTART.md)**: Step-by-step setup guide
- **[RUNE_DSL_CHEAT_SHEET.md](RUNE_DSL_CHEAT_SHEET.md)**: Comprehensive syntax reference with examples
- **[CHANGELOG.md](CHANGELOG.md)**: Version history and changes

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## GitHub Copilot Integration 🤖

This extension includes enhanced GitHub Copilot integration to improve AI-assisted development with Rune DSL:

### Features
- **Enhanced Language Configuration**: Improved bracket matching, auto-closing, and surrounding pairs for better Copilot context
- **Comprehensive Snippet Library**: 50+ code snippets covering common Rune DSL patterns and constructs
- **AI Context Enhancement**: Commands to provide better context to Copilot about your Rune DSL code
- **Template Insertion**: Quick insertion of common Rune DSL templates with Copilot-friendly structure

### Copilot Commands
The extension provides the following commands to enhance your AI-assisted development experience:

- **Rune DSL: Enhance Context for Copilot**: Provides AI with detailed context about your current file
- **Rune DSL: Insert Template for Copilot**: Inserts structured templates that work well with AI assistance  
- **Rune DSL: Configure Copilot Integration**: Quick access to Copilot-related settings

### Code Snippets
Type any of these prefixes in a `.rosetta` file and press Tab to expand:

#### Basic Constructs
- `enum` → Basic enumeration definition
- `type` → Data type with attributes
- `func` → Function with conditions
- `rule` → Business rule template
- `calc` → Calculation function

#### Control Flow
- `if`, `then`, `else` → Conditional logic patterns
- `condition` → Condition with description
- `rule` → Validation rule structure

#### Operations
- `sum`, `count`, `filter` → Common list operations
- `exists`, `absent` → Existence checks
- `one-of`, `choice` → Choice constraints

#### Advanced Patterns
- `reporting` → Reporting rule template
- `eligibility` → Eligibility condition template
- `calculation` → Complex calculation pattern
- `validation` → Data validation template

### Tips for Better AI Assistance
1. **Use descriptive comments** - The extension enhances comment recognition for Copilot
2. **Leverage snippets** - Start with snippets, then let Copilot complete the logic
3. **Use context commands** - Run "Enhance Context for Copilot" when working on complex files
4. **Template-driven development** - Use "Insert Template for Copilot" for structured patterns
