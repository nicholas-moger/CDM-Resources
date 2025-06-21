# DRR Prerequisites Installation Script
# This script installs Java 21, Maven 3.9.9, and Node.js 22.14.0 for the DRR training environment

param(
    [switch]$Force,
    [switch]$SkipJava,
    [switch]$SkipMaven,
    [switch]$SkipNode,
    [switch]$Quiet
)

# Check if running as Administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Write colored output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )    if (-not $Quiet) {
        Write-Information $Message -InformationAction Continue
        Write-Host $Message -ForegroundColor $Color
    }
}

# Download file with progress
function Get-FileDownload {
    param(
        [string]$Url,
        [string]$OutputPath
    )

    Write-ColorOutput "Downloading: $Url" "Cyan"

    try {
        # Use BITS transfer for better progress tracking
        Import-Module BitsTransfer -ErrorAction SilentlyContinue
        if (Get-Module -Name BitsTransfer) {
            Start-BitsTransfer -Source $Url -Destination $OutputPath -DisplayName "Downloading $(Split-Path $OutputPath -Leaf)"
        } else {
            # Fallback to Invoke-WebRequest
            $ProgressPreference = 'Continue'
            Invoke-WebRequest -Uri $Url -OutFile $OutputPath -UseBasicParsing
        }
        Write-ColorOutput "Downloaded successfully: $OutputPath" "Green"
        return $true
    } catch {
        Write-ColorOutput "Download failed: $($_.Exception.Message)" "Red"
        return $false
    }
}

# Check if a command exists
function Test-Command {
    param([string]$Command)
    try {
        Get-Command $Command -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# Set environment variable for both session and permanent
function Set-EnvironmentVariable {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$Name,
        [string]$Value,
        [string]$Scope = "Machine"
    )

    if ($PSCmdlet.ShouldProcess("Environment Variable: $Name", "Set to: $Value")) {
        Write-ColorOutput "Setting environment variable: $Name = $Value" "Yellow"
        [Environment]::SetEnvironmentVariable($Name, $Value, $Scope)
        Set-Item -Path "env:$Name" -Value $Value
    }
}

# Add to PATH if not already present
function Add-ToPath {
    param([string]$Path)

    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
    if ($currentPath -notlike "*$Path*") {
        Write-ColorOutput "Adding to PATH: $Path" "Yellow"
        $newPath = "$currentPath;$Path"
        [Environment]::SetEnvironmentVariable("PATH", $newPath, "Machine")
        $env:PATH = "$env:PATH;$Path"
    } else {
        Write-ColorOutput "Path already in PATH: $Path" "Gray"
    }
}

# Install Java 21 (Eclipse Temurin)
function Install-Java {
    Write-ColorOutput "`n=== Installing Java 21 (Eclipse Temurin) ===" "Magenta"

    $javaPath = "C:\Program Files\Eclipse Adoptium\jdk-21.0.7.6-hotspot"

    # Check if already installed
    if ((Test-Path $javaPath) -and -not $Force) {
        Write-ColorOutput "Java 21 already installed at: $javaPath" "Green"
        Set-EnvironmentVariable -Name "JAVA_HOME" -Value $javaPath
        Add-ToPath "$javaPath\bin"
        return $true
    }

    $tempDir = Join-Path $env:TEMP "drr_install"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

    $javaUrl = "https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.7%2B6/OpenJDK21U-jdk_x64_windows_hotspot_21.0.7_6.msi"
    $javaInstaller = Join-Path $tempDir "OpenJDK21-installer.msi"

    if (Get-FileDownload -Url $javaUrl -OutputPath $javaInstaller) {
        Write-ColorOutput "Installing Java 21..." "Yellow"
        try {
            $process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i", "`"$javaInstaller`"", "/quiet", "/norestart" -Wait -PassThru
            if ($process.ExitCode -eq 0) {
                Write-ColorOutput "Java 21 installed successfully!" "Green"
                Set-EnvironmentVariable -Name "JAVA_HOME" -Value $javaPath
                Add-ToPath "$javaPath\bin"
                Remove-Item $javaInstaller -Force
                return $true
            } else {
                Write-ColorOutput "Java installation failed with exit code: $($process.ExitCode)" "Red"
                return $false
            }
        } catch {
            Write-ColorOutput "Java installation error: $($_.Exception.Message)" "Red"
            return $false
        }
    }
    return $false
}

# Install Maven 3.9.9
function Install-Maven {
    Write-ColorOutput "`n=== Installing Apache Maven 3.9.9 ===" "Magenta"

    $mavenVersion = "3.9.9"
    $mavenPath = "C:\Program Files\apache-maven-$mavenVersion"

    # Check if already installed
    if ((Test-Path $mavenPath) -and -not $Force) {
        Write-ColorOutput "Maven 3.9.9 already installed at: $mavenPath" "Green"
        Set-EnvironmentVariable -Name "MAVEN_HOME" -Value $mavenPath
        Add-ToPath "$mavenPath\bin"
        return $true
    }

    $tempDir = Join-Path $env:TEMP "drr_install"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

    $mavenUrl = "https://archive.apache.org/dist/maven/maven-3/$mavenVersion/binaries/apache-maven-$mavenVersion-bin.zip"
    $mavenZip = Join-Path $tempDir "apache-maven-$mavenVersion-bin.zip"

    if (Get-FileDownload -Url $mavenUrl -OutputPath $mavenZip) {
        Write-ColorOutput "Extracting Maven..." "Yellow"
        try {
            $extractPath = "C:\Program Files"
            Expand-Archive -Path $mavenZip -DestinationPath $extractPath -Force

            if (Test-Path $mavenPath) {
                Write-ColorOutput "Maven 3.9.9 installed successfully!" "Green"
                Set-EnvironmentVariable -Name "MAVEN_HOME" -Value $mavenPath
                Add-ToPath "$mavenPath\bin"
                Remove-Item $mavenZip -Force
                return $true
            } else {
                Write-ColorOutput "Maven extraction failed - path not found: $mavenPath" "Red"
                return $false
            }
        } catch {
            Write-ColorOutput "Maven installation error: $($_.Exception.Message)" "Red"
            return $false
        }
    }
    return $false
}

# Install Node.js 22.14.0
function Install-NodeJS {
    Write-ColorOutput "`n=== Installing Node.js 22.14.0 ===" "Magenta"

    $nodeVersion = "22.14.0"

    # Check if already installed with correct version
    if ((Test-Command "node") -and -not $Force) {
        $currentNodeVersion = (node --version) -replace "v", ""
        if ($currentNodeVersion -eq $nodeVersion) {
            Write-ColorOutput "Node.js $nodeVersion already installed" "Green"
            return $true
        } else {
            Write-ColorOutput "Different Node.js version found: $currentNodeVersion" "Yellow"
            if (-not $Force) {
                Write-ColorOutput "Use -Force flag to reinstall" "Yellow"
                return $true
            }
        }
    }

    $tempDir = Join-Path $env:TEMP "drr_install"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

    $nodeUrl = "https://nodejs.org/dist/v$nodeVersion/node-v$nodeVersion-x64.msi"
    $nodeInstaller = Join-Path $tempDir "node-v$nodeVersion-x64.msi"

    if (Get-FileDownload -Url $nodeUrl -OutputPath $nodeInstaller) {
        Write-ColorOutput "Installing Node.js $nodeVersion..." "Yellow"
        try {
            $process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i", "`"$nodeInstaller`"", "/quiet", "/norestart" -Wait -PassThru
            if ($process.ExitCode -eq 0) {
                Write-ColorOutput "Node.js $nodeVersion installed successfully!" "Green"
                Remove-Item $nodeInstaller -Force

                # Refresh environment variables
                $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")

                return $true
            } else {
                Write-ColorOutput "Node.js installation failed with exit code: $($process.ExitCode)" "Red"
                return $false
            }
        } catch {
            Write-ColorOutput "Node.js installation error: $($_.Exception.Message)" "Red"
            return $false
        }
    }
    return $false
}

# Verify installations
function Test-Installation {
    Write-ColorOutput "`n=== Verifying Installation ===" "Magenta"

    $success = $true

    # Test Java
    try {
        $javaOutput = java -version 2>&1
        if ($javaOutput -match "openjdk version `"21\.0\.7`"") {
            Write-ColorOutput "✓ Java 21.0.7 verified" "Green"
        } else {
            Write-ColorOutput "✗ Java verification failed" "Red"
            $success = $false
        }
    } catch {
        Write-ColorOutput "✗ Java not found in PATH" "Red"
        $success = $false
    }

    # Test Maven
    try {
        $mavenOutput = mvn -version 2>&1
        if ($mavenOutput -match "Apache Maven 3\.9\.9") {
            Write-ColorOutput "✓ Maven 3.9.9 verified" "Green"
        } else {
            Write-ColorOutput "✗ Maven verification failed" "Red"
            $success = $false
        }
    } catch {
        Write-ColorOutput "✗ Maven not found in PATH" "Red"
        $success = $false
    }

    # Test Node.js
    try {
        $nodeOutput = node --version
        if ($nodeOutput -eq "v22.14.0") {
            Write-ColorOutput "✓ Node.js 22.14.0 verified" "Green"
        } else {
            Write-ColorOutput "✗ Node.js verification failed - found: $nodeOutput" "Red"
            $success = $false
        }
    } catch {
        Write-ColorOutput "✗ Node.js not found in PATH" "Red"
        $success = $false
    }

    # Test npm
    try {
        $npmOutput = npm --version
        Write-ColorOutput "✓ npm $npmOutput verified" "Green"
    } catch {
        Write-ColorOutput "✗ npm not found in PATH" "Red"
        $success = $false
    }

    return $success
}

# Main execution
function Main {
    Write-ColorOutput "DRR Build Environment Prerequisites Installation Script" "Cyan"
    Write-ColorOutput "=====================================================" "Cyan"

    # Check administrator privileges
    if (-not (Test-Administrator)) {
        Write-ColorOutput "ERROR: This script must be run as Administrator!" "Red"
        Write-ColorOutput "Please right-click PowerShell and select 'Run as Administrator'" "Yellow"
        exit 1
    }

    # Check PowerShell execution policy
    $executionPolicy = Get-ExecutionPolicy
    if ($executionPolicy -eq "Restricted") {
        Write-ColorOutput "WARNING: PowerShell execution policy is Restricted" "Yellow"
        Write-ColorOutput "You may need to run: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser" "Yellow"
    }

    $overallSuccess = $true

    # Install Java
    if (-not $SkipJava) {
        if (-not (Install-Java)) {
            $overallSuccess = $false
        }
    } else {
        Write-ColorOutput "Skipping Java installation" "Gray"
    }

    # Install Maven
    if (-not $SkipMaven) {
        if (-not (Install-Maven)) {
            $overallSuccess = $false
        }
    } else {
        Write-ColorOutput "Skipping Maven installation" "Gray"
    }

    # Install Node.js
    if (-not $SkipNode) {
        if (-not (Install-NodeJS)) {
            $overallSuccess = $false
        }
    } else {
        Write-ColorOutput "Skipping Node.js installation" "Gray"
    }

    # Verify installation
    Start-Sleep -Seconds 2  # Give time for installations to complete
    $verificationSuccess = Test-Installation

    Write-ColorOutput "`n=== Installation Summary ===" "Magenta"
    if ($overallSuccess -and $verificationSuccess) {
        Write-ColorOutput "✓ All components installed and verified successfully!" "Green"
        Write-ColorOutput "`nNext steps:" "Cyan"
        Write-ColorOutput "1. Close and reopen your PowerShell/Command Prompt" "White"
        Write-ColorOutput "2. Verify your environment with: java -version, mvn -version, node --version" "White"
        Write-ColorOutput "3. Your DRR build environment is ready!" "White"
        exit 0
    } else {
        Write-ColorOutput "✗ Some components failed to install or verify" "Red"
        Write-ColorOutput "Please check the error messages above and retry" "Yellow"
        exit 1
    }
}

# Script parameters help
if ($args -contains "-help" -or $args -contains "--help" -or $args -contains "/?" -or $args -contains "-h") {
    Write-Output @"
DRR Prerequisites Installation Script

USAGE:
    .\INSTALL_DRR_PREREQUISITES.ps1 [OPTIONS]

OPTIONS:
    -Force          Force reinstallation even if components exist
    -SkipJava       Skip Java installation
    -SkipMaven      Skip Maven installation
    -SkipNode       Skip Node.js installation
    -Quiet          Suppress non-essential output
    -help           Show this help message

EXAMPLES:
    .\INSTALL_DRR_PREREQUISITES.ps1                    # Install all components
    .\INSTALL_DRR_PREREQUISITES.ps1 -Force             # Force reinstall all
    .\INSTALL_DRR_PREREQUISITES.ps1 -SkipJava          # Skip Java, install Maven and Node.js
    .\INSTALL_DRR_PREREQUISITES.ps1 -SkipMaven -SkipNode # Install only Java

NOTE: This script must be run as Administrator.
"@
    exit 0
}

# Run main function
Main
