# DRR Build Environment Setup - Windows

This document describes the build environment setup for the DRR (Disaster Risk Reduction) training project on Windows systems.

## Required Tools and Versions

Based on the reference build environment, the following tools and versions are required:

### Java Development Kit (JDK)
- **Version**: OpenJDK 21.0.7 LTS (Eclipse Temurin)
- **Vendor**: Eclipse Adoptium
- **Architecture**: 64-bit
- **Installation Path**: `C:\Program Files\Eclipse Adoptium\jdk-21.0.7.6-hotspot`
- **Environment Variable**: `JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-21.0.7.6-hotspot`

### Apache Maven
- **Version**: 3.9.9
- **Installation Path**: `C:\Program Files\apache-maven-3.9.9`
- **Environment Variable**: `MAVEN_HOME=C:\Program Files\apache-maven-3.9.9`

### Node.js
- **Version**: 22.14.0 or higher (any recent LTS version is acceptable)
- **Package Manager**: npm (included with Node.js)

## Manual Installation Steps

### 1. Install Java 21 (Eclipse Temurin)

1. Download Eclipse Temurin JDK 21 from: https://adoptium.net/temurin/releases/
2. Select:
   - Version: 21 - LTS
   - Operating System: Windows
   - Architecture: x64
   - Package Type: JDK
   - Format: .msi
3. Run the installer and follow the installation wizard
4. Verify installation by opening a new PowerShell window and running:
   ```powershell
   java -version
   ```

### 2. Install Apache Maven

1. Download Maven 3.9.9 from: https://maven.apache.org/download.cgi
2. Download the Binary zip archive: `apache-maven-3.9.9-bin.zip`
3. Extract to `C:\Program Files\apache-maven-3.9.9`
4. Add Maven to PATH and set MAVEN_HOME:
   - Open System Properties → Advanced → Environment Variables
   - Add new System Variable: `MAVEN_HOME = C:\Program Files\apache-maven-3.9.9`
   - Edit PATH system variable and add: `%MAVEN_HOME%\bin`
5. Verify installation by opening a new PowerShell window and running:
   ```powershell
   mvn -version
   ```

### 3. Install Node.js

1. Download Node.js LTS from: https://nodejs.org/
2. Download the Windows Installer (.msi) - LTS version recommended
3. Run the installer and follow the installation wizard (no admin rights needed)
4. Verify installation by opening a new PowerShell window and running:
   ```powershell
   node --version
   npm --version
   ```

## Installation Helper Script

For guided installation assistance, use the provided PowerShell script:

```powershell
.\INSTALL_DRR_PREREQUISITES.ps1
```

This script will:
- Check for existing installations
- Open download pages in your browser
- Provide step-by-step installation instructions
- Guide you through manual installation process
- Verify installations after each step
- Prompt you to restart VS Code between installations

**Note**: This is a helper script that guides manual installation - no admin privileges required.

## Environment Variables

After installation, the following environment variables should be set:

- `JAVA_HOME`: `C:\Program Files\Eclipse Adoptium\jdk-21.0.7.6-hotspot`
- `MAVEN_HOME`: `C:\Program Files\apache-maven-3.9.9`
- `PATH`: Should include `%JAVA_HOME%\bin`, `%MAVEN_HOME%\bin`, and Node.js installation path

## Verification

To verify your build environment is correctly set up, run the following commands in a PowerShell window:

```powershell
# Check Java
java -version
echo $env:JAVA_HOME

# Check Maven
mvn -version
echo $env:MAVEN_HOME

# Check Node.js and npm
node --version
npm --version
```

Expected output should match the versions specified in this document.

## Troubleshooting

### Common Issues

1. **Command not found errors**: Ensure the tools are added to your PATH environment variable
2. **Wrong Java version**: Make sure JAVA_HOME points to the correct JDK installation
3. **Maven configuration issues**: Verify MAVEN_HOME is set correctly
4. **Permission issues**: Run PowerShell as Administrator when installing

### Environment Variable Issues

If environment variables are not set correctly:

1. Open System Properties → Advanced → Environment Variables
2. Verify system variables are set as described above
3. Restart your PowerShell/Command Prompt session
4. Verify changes with `echo $env:VARIABLE_NAME`

## Notes

- Java and Maven installations may require Administrator privileges
- Node.js installation typically does not require admin privileges
- Restart your terminal/IDE after installation to ensure environment variables are loaded
- The helper script does not require PowerShell execution policy changes
- Internet connection is required for downloading the installation packages

## Support

For issues specific to the DRR project build environment, please contact the project maintainers.
