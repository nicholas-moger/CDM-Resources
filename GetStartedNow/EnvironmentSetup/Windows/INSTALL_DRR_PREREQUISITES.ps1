# DRR Prerequisites Installation Script
# Simple installation script for Java 21, Maven 3.9.9, and Node.js (latest version OK)
# No admin rights required - uses user-level installations

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "DRR Build Environment Setup" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Helper function to check if command exists
function Test-Command {
    param([string]$Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    } catch {
        return $false
    }
}

# Check current installations
Write-Host "Checking current installations..." -ForegroundColor Yellow

$javaOK = $false
$mavenOK = $false
$nodeOK = $false

# Check Java
if (Test-Command "java") {
    try {
        $javaVersion = & java -version 2>&1 | Select-String "openjdk version"
        if ($javaVersion -match "21\.0\.") {
            Write-Host "[OK] Java 21 is installed" -ForegroundColor Green
            $javaOK = $true
        } else {
            Write-Host "[!] Java is installed but not version 21" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "[!] Java found but version check failed" -ForegroundColor Yellow
    }
} else {
    Write-Host "[X] Java not found" -ForegroundColor Red
}

# Check Maven
if (Test-Command "mvn") {
    try {
        $mavenVersion = & mvn -version 2>&1 | Select-String "Apache Maven"
        if ($mavenVersion -match "3\.9\.9") {
            Write-Host "[OK] Maven 3.9.9 is installed" -ForegroundColor Green
            $mavenOK = $true
        } else {
            Write-Host "[!] Maven is installed but not version 3.9.9" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "[!] Maven found but version check failed" -ForegroundColor Yellow
    }
} else {
    Write-Host "[X] Maven not found" -ForegroundColor Red
}

# Check Node.js (any recent version is OK)
if (Test-Command "node") {
    try {
        $nodeVersion = & node --version
        Write-Host "[OK] Node.js $nodeVersion is installed" -ForegroundColor Green
        $nodeOK = $true
    } catch {
        Write-Host "[!] Node.js found but version check failed" -ForegroundColor Yellow
    }
} else {
    Write-Host "[X] Node.js not found" -ForegroundColor Red
}

Write-Host ""

# If everything is OK, exit
if ($javaOK -and $mavenOK -and $nodeOK) {
    Write-Host "All prerequisites are already installed!" -ForegroundColor Green
    Write-Host "Your DRR build environment is ready." -ForegroundColor Green
    exit 0
}

# Install Java 21 (Eclipse Temurin)
function Install-Java {
    Write-Host "`n=== Installing Java 21 ===" -ForegroundColor Magenta
    Write-Host "Opening Java download page..." -ForegroundColor Yellow
    
    $javaUrl = "https://adoptium.net/temurin/releases/?version=21&os=windows&arch=x64&package=jdk"
    Start-Process $javaUrl
    
    Write-Host ""
    Write-Host "MANUAL INSTALLATION REQUIRED:" -ForegroundColor Yellow
    Write-Host "1. Download the Windows x64 JDK (.msi file)" -ForegroundColor White
    Write-Host "2. Run the installer as Administrator" -ForegroundColor White
    Write-Host "3. Follow the installation wizard" -ForegroundColor White
    Write-Host "4. Make sure to check 'Set JAVA_HOME' and 'Update PATH' options" -ForegroundColor White
    Write-Host ""
    
    do {
        $response = Read-Host "Have you completed the Java installation? (y/n)"
    } while ($response -notin @('y', 'yes', 'n', 'no'))
    
    if ($response -in @('y', 'yes')) {
        Write-Host "Please restart VS Code and run this script again to verify the installation." -ForegroundColor Yellow
        return $true
    } else {
        Write-Host "Java installation skipped. You'll need to install it manually later." -ForegroundColor Red
        return $false
    }
}

# Install Maven 3.9.9
function Install-Maven {
    Write-Host "`n=== Installing Maven 3.9.9 ===" -ForegroundColor Magenta
    Write-Host "Opening Maven download page..." -ForegroundColor Yellow
    
    $mavenUrl = "https://maven.apache.org/download.cgi"
    Start-Process $mavenUrl
    
    Write-Host ""
    Write-Host "MANUAL INSTALLATION REQUIRED:" -ForegroundColor Yellow
    Write-Host "1. Download 'Binary zip archive' (apache-maven-3.9.9-bin.zip)" -ForegroundColor White
    Write-Host "2. Extract to C:\Program Files\apache-maven-3.9.9" -ForegroundColor White
    Write-Host "3. Add C:\Program Files\apache-maven-3.9.9\bin to your PATH" -ForegroundColor White
    Write-Host "4. Set MAVEN_HOME environment variable to C:\Program Files\apache-maven-3.9.9" -ForegroundColor White
    Write-Host ""
    Write-Host "Alternative: Use chocolatey 'choco install maven --version=3.9.9'" -ForegroundColor Cyan
    Write-Host ""
    
    do {
        $response = Read-Host "Have you completed the Maven installation? (y/n)"
    } while ($response -notin @('y', 'yes', 'n', 'no'))
    
    if ($response -in @('y', 'yes')) {
        Write-Host "Please restart VS Code and run this script again to verify the installation." -ForegroundColor Yellow
        return $true
    } else {
        Write-Host "Maven installation skipped. You'll need to install it manually later." -ForegroundColor Red
        return $false
    }
}

# Install Node.js (latest LTS)
function Install-NodeJS {
    Write-Host "`n=== Installing Node.js ===" -ForegroundColor Magenta
    Write-Host "Opening Node.js download page..." -ForegroundColor Yellow
    
    $nodeUrl = "https://nodejs.org/en/download"
    Start-Process $nodeUrl
    
    Write-Host ""
    Write-Host "MANUAL INSTALLATION REQUIRED:" -ForegroundColor Yellow
    Write-Host "1. Download the Windows Installer (.msi) - LTS version recommended" -ForegroundColor White
    Write-Host "2. Run the installer (no admin rights needed)" -ForegroundColor White
    Write-Host "3. Follow the installation wizard (default settings are fine)" -ForegroundColor White
    Write-Host "4. This will also install npm automatically" -ForegroundColor White
    Write-Host ""
    Write-Host "Alternative: Use chocolatey 'choco install nodejs'" -ForegroundColor Cyan
    Write-Host ""
    
    do {
        $response = Read-Host "Have you completed the Node.js installation? (y/n)"
    } while ($response -notin @('y', 'yes', 'n', 'no'))
    
    if ($response -in @('y', 'yes')) {
        Write-Host "Please restart VS Code and run this script again to verify the installation." -ForegroundColor Yellow
        return $true
    } else {
        Write-Host "Node.js installation skipped. You'll need to install it manually later." -ForegroundColor Red
        return $false
    }
}

# Verify installations
function Test-Installation {
    Write-Host "`n=== Verifying Installation ===" -ForegroundColor Magenta

    $success = $true

    # Test Java
    try {
        $javaOutput = & java -version 2>&1
        if ($javaOutput -match "openjdk version `"21\.") {
            Write-Host "[OK] Java 21.x verified" -ForegroundColor Green
        } else {
            Write-Host "[FAIL] Java verification failed - found: $($javaOutput | Select-Object -First 1)" -ForegroundColor Red
            $success = $false
        }
    } catch {
        Write-Host "[ERROR] Java not found in PATH" -ForegroundColor Red
        $success = $false
    }

    # Test Maven
    try {
        $mavenOutput = & mvn -version 2>&1
        if ($mavenOutput -match "Apache Maven 3\.9\.9") {
            Write-Host "[OK] Maven 3.9.9 verified" -ForegroundColor Green
        } else {
            Write-Host "[FAIL] Maven verification failed - found: $($mavenOutput | Select-Object -First 1)" -ForegroundColor Red
            $success = $false
        }
    } catch {
        Write-Host "[ERROR] Maven not found in PATH" -ForegroundColor Red
        $success = $false
    }

    # Test Node.js
    try {
        $nodeOutput = & node --version
        Write-Host "[OK] Node.js $nodeOutput verified" -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Node.js not found in PATH" -ForegroundColor Red
        $success = $false
    }

    # Test npm
    try {
        $npmOutput = & npm --version
        Write-Host "[OK] npm $npmOutput verified" -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] npm not found in PATH" -ForegroundColor Red
        $success = $false
    }

    return $success
}

# Main installation flow
Write-Host "Prerequisites Installation Guide" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

# Install missing components
if (-not $javaOK) {
    Install-Java
    Write-Host "`nIMPORTANT: Please restart VS Code now and run this script again." -ForegroundColor Red
    Write-Host "Press any key to exit..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 0
}

if (-not $mavenOK) {
    Install-Maven
    Write-Host "`nIMPORTANT: Please restart VS Code now and run this script again." -ForegroundColor Red
    Write-Host "Press any key to exit..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 0
}

if (-not $nodeOK) {
    Install-NodeJS
    Write-Host "`nIMPORTANT: Please restart VS Code now and run this script again." -ForegroundColor Red
    Write-Host "Press any key to exit..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 0
}

# Final verification
Write-Host "`n=== Final Verification ===" -ForegroundColor Magenta
if (Test-Installation) {
    Write-Host "`n🎉 SUCCESS! All DRR prerequisites are installed and verified!" -ForegroundColor Green
    Write-Host "`nYou can now:" -ForegroundColor Cyan
    Write-Host "• Build and run DRR projects" -ForegroundColor White
    Write-Host "• Use Maven commands (mvn)" -ForegroundColor White
    Write-Host "• Use Java development tools" -ForegroundColor White
    Write-Host "• Use Node.js and npm" -ForegroundColor White
} else {
    Write-Host "`n❌ Some installations may have failed." -ForegroundColor Red
    Write-Host "Please check the error messages above and try installing manually." -ForegroundColor Yellow
}

Write-Host "`nPress any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
