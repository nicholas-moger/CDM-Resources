#!/bin/bash

# DRR Prerequisites Installation Script - Linux
# This script installs Java 21, Maven 3.9.9, and Node.js 22.14.0 for the DRR training environment

set -e  # Exit on any error

# Default values
FORCE=false
SKIP_JAVA=false
SKIP_MAVEN=false
SKIP_NODE=false
QUIET=false

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    if [ "$QUIET" = false ]; then
        echo -e "${color}${message}${NC}"
    fi
}

# Function to print usage
print_usage() {
    cat << EOF
DRR Prerequisites Installation Script - Linux

USAGE:
    sudo ./install_drr_prerequisites.sh [OPTIONS]

OPTIONS:
    --force          Force reinstallation even if components exist
    --skip-java      Skip Java installation
    --skip-maven     Skip Maven installation  
    --skip-node      Skip Node.js installation
    --quiet          Suppress non-essential output
    --help           Show this help message

EXAMPLES:
    sudo ./install_drr_prerequisites.sh                    # Install all components
    sudo ./install_drr_prerequisites.sh --force            # Force reinstall all
    sudo ./install_drr_prerequisites.sh --skip-java        # Skip Java, install Maven and Node.js
    sudo ./install_drr_prerequisites.sh --skip-maven --skip-node # Install only Java

NOTE: This script must be run with sudo privileges.
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --force)
            FORCE=true
            shift
            ;;
        --skip-java)
            SKIP_JAVA=true
            shift
            ;;
        --skip-maven)
            SKIP_MAVEN=true
            shift
            ;;
        --skip-node)
            SKIP_NODE=true
            shift
            ;;
        --quiet)
            QUIET=true
            shift
            ;;
        --help|-h)
            print_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            print_usage
            exit 1
            ;;
    esac
done

# Check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_color "$RED" "ERROR: This script must be run as root (use sudo)"
        print_color "$YELLOW" "Please run: sudo ./install_drr_prerequisites.sh"
        exit 1
    fi
}

# Detect Linux distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        VERSION=$VERSION_ID
    elif [ -f /etc/redhat-release ]; then
        DISTRO="centos"
    elif [ -f /etc/debian_version ]; then
        DISTRO="debian"
    else
        print_color "$RED" "ERROR: Cannot detect Linux distribution"
        exit 1
    fi
    
    print_color "$CYAN" "Detected distribution: $DISTRO $VERSION"
}

# Update package manager
update_packages() {
    print_color "$CYAN" "Updating package manager..."
    
    case $DISTRO in
        ubuntu|debian)
            apt update
            ;;
        centos|rhel)
            yum update -y
            ;;
        fedora)
            dnf update -y
            ;;
        *)
            print_color "$YELLOW" "WARNING: Unknown distribution, skipping package update"
            ;;
    esac
}

# Install required packages
install_prerequisites() {
    print_color "$CYAN" "Installing prerequisite packages..."
    
    case $DISTRO in
        ubuntu|debian)
            apt install -y wget curl tar gzip software-properties-common apt-transport-https ca-certificates gnupg lsb-release
            ;;
        centos|rhel)
            yum install -y wget curl tar gzip which
            ;;
        fedora)
            dnf install -y wget curl tar gzip which
            ;;
        *)
            print_color "$YELLOW" "WARNING: Unknown distribution, skipping prerequisite installation"
            ;;
    esac
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Download file with progress
download_file() {
    local url=$1
    local output=$2
    
    print_color "$CYAN" "Downloading: $url"
    
    if command_exists wget; then
        wget -q --show-progress "$url" -O "$output"
    elif command_exists curl; then
        curl -L -o "$output" "$url"
    else
        print_color "$RED" "ERROR: Neither wget nor curl is available"
        return 1
    fi
    
    if [ $? -eq 0 ]; then
        print_color "$GREEN" "Downloaded successfully: $output"
        return 0
    else
        print_color "$RED" "Download failed: $url"
        return 1
    fi
}

# Install Java 21 (Eclipse Temurin)
install_java() {
    print_color "$MAGENTA" ""
    print_color "$MAGENTA" "=== Installing Java 21 (Eclipse Temurin) ==="
    
    local java_home="/opt/eclipse-adoptium/jdk-21.0.7+6"
    local java_bin="$java_home/bin/java"
    
    # Check if already installed
    if [ -f "$java_bin" ] && [ "$FORCE" = false ]; then
        print_color "$GREEN" "Java 21 already installed at: $java_home"
        setup_java_env "$java_home"
        return 0
    fi
    
    # Create temporary directory
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # Download Java
    local java_url="https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.7%2B6/OpenJDK21U-jdk_x64_linux_hotspot_21.0.7_6.tar.gz"
    local java_archive="OpenJDK21-linux.tar.gz"
    
    if download_file "$java_url" "$java_archive"; then
        print_color "$YELLOW" "Installing Java 21..."
        
        # Create installation directory
        mkdir -p /opt/eclipse-adoptium
        
        # Extract Java
        tar -xzf "$java_archive" -C /opt/eclipse-adoptium
        
        if [ -d "$java_home" ]; then
            print_color "$GREEN" "Java 21 installed successfully!"
            setup_java_env "$java_home"
            
            # Cleanup
            rm -rf "$temp_dir"
            return 0
        else
            print_color "$RED" "Java installation failed - directory not found: $java_home"
            rm -rf "$temp_dir"
            return 1
        fi
    else
        rm -rf "$temp_dir"
        return 1
    fi
}

# Setup Java environment variables
setup_java_env() {
    local java_home=$1
    
    print_color "$YELLOW" "Setting up Java environment variables..."
    
    # Add to system environment
    echo "export JAVA_HOME=$java_home" > /etc/profile.d/java.sh
    echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/profile.d/java.sh
    chmod +x /etc/profile.d/java.sh
    
    # Set for current session
    export JAVA_HOME="$java_home"
    export PATH="$JAVA_HOME/bin:$PATH"
    
    print_color "$GREEN" "Java environment configured"
}

# Install Maven 3.9.9
install_maven() {
    print_color "$MAGENTA" ""
    print_color "$MAGENTA" "=== Installing Apache Maven 3.9.9 ==="
    
    local maven_version="3.9.9"
    local maven_home="/opt/apache-maven-$maven_version"
    local maven_bin="$maven_home/bin/mvn"
    
    # Check if already installed
    if [ -f "$maven_bin" ] && [ "$FORCE" = false ]; then
        print_color "$GREEN" "Maven 3.9.9 already installed at: $maven_home"
        setup_maven_env "$maven_home"
        return 0
    fi
    
    # Create temporary directory
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # Download Maven
    local maven_url="https://archive.apache.org/dist/maven/maven-3/$maven_version/binaries/apache-maven-$maven_version-bin.tar.gz"
    local maven_archive="apache-maven-$maven_version-bin.tar.gz"
    
    if download_file "$maven_url" "$maven_archive"; then
        print_color "$YELLOW" "Installing Maven..."
        
        # Extract Maven
        tar -xzf "$maven_archive" -C /opt
        
        if [ -d "$maven_home" ]; then
            print_color "$GREEN" "Maven 3.9.9 installed successfully!"
            setup_maven_env "$maven_home"
            
            # Cleanup
            rm -rf "$temp_dir"
            return 0
        else
            print_color "$RED" "Maven installation failed - directory not found: $maven_home"
            rm -rf "$temp_dir"
            return 1
        fi
    else
        rm -rf "$temp_dir"
        return 1
    fi
}

# Setup Maven environment variables
setup_maven_env() {
    local maven_home=$1
    
    print_color "$YELLOW" "Setting up Maven environment variables..."
    
    # Add to system environment
    echo "export MAVEN_HOME=$maven_home" > /etc/profile.d/maven.sh
    echo "export PATH=\$MAVEN_HOME/bin:\$PATH" >> /etc/profile.d/maven.sh
    chmod +x /etc/profile.d/maven.sh
    
    # Set for current session
    export MAVEN_HOME="$maven_home"
    export PATH="$MAVEN_HOME/bin:$PATH"
    
    print_color "$GREEN" "Maven environment configured"
}

# Install Node.js 22.14.0
install_nodejs() {
    print_color "$MAGENTA" ""
    print_color "$MAGENTA" "=== Installing Node.js 22.14.0 ==="
    
    local node_version="22.14.0"
    
    # Check if already installed with correct version
    if command_exists node && [ "$FORCE" = false ]; then
        local current_version=$(node --version | sed 's/v//')
        if [ "$current_version" = "$node_version" ]; then
            print_color "$GREEN" "Node.js $node_version already installed"
            return 0
        else
            print_color "$YELLOW" "Different Node.js version found: $current_version"
            if [ "$FORCE" = false ]; then
                print_color "$YELLOW" "Use --force flag to reinstall"
                return 0
            fi
        fi
    fi
    
    # Install Node.js using NodeSource repository
    case $DISTRO in
        ubuntu|debian)
            install_nodejs_nodesource_deb "$node_version"
            ;;
        centos|rhel|fedora)
            install_nodejs_nodesource_rpm "$node_version"
            ;;
        *)
            install_nodejs_manual "$node_version"
            ;;
    esac
}

# Install Node.js using NodeSource repository (Debian/Ubuntu)
install_nodejs_nodesource_deb() {
    local node_version=$1
    
    print_color "$YELLOW" "Installing Node.js via NodeSource repository..."
    
    # Add NodeSource repository
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
    
    # Install Node.js
    apt-get install -y nodejs
    
    verify_nodejs_installation "$node_version"
}

# Install Node.js using NodeSource repository (CentOS/RHEL/Fedora)
install_nodejs_nodesource_rpm() {
    local node_version=$1
    
    print_color "$YELLOW" "Installing Node.js via NodeSource repository..."
    
    # Add NodeSource repository
    curl -fsSL https://rpm.nodesource.com/setup_22.x | bash -
    
    # Install Node.js
    case $DISTRO in
        centos|rhel)
            yum install -y nodejs
            ;;
        fedora)
            dnf install -y nodejs
            ;;
    esac
    
    verify_nodejs_installation "$node_version"
}

# Install Node.js manually
install_nodejs_manual() {
    local node_version=$1
    
    print_color "$YELLOW" "Installing Node.js manually..."
    
    # Create temporary directory
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # Download Node.js
    local node_url="https://nodejs.org/dist/v$node_version/node-v$node_version-linux-x64.tar.xz"
    local node_archive="node-v$node_version-linux-x64.tar.xz"
    
    if download_file "$node_url" "$node_archive"; then
        print_color "$YELLOW" "Extracting Node.js..."
        
        # Extract Node.js
        tar -xJf "$node_archive" -C /opt
        ln -sf "/opt/node-v$node_version-linux-x64" /opt/nodejs
        
        # Add to PATH
        echo "export PATH=/opt/nodejs/bin:\$PATH" > /etc/profile.d/nodejs.sh
        chmod +x /etc/profile.d/nodejs.sh
        export PATH="/opt/nodejs/bin:$PATH"
        
        # Cleanup
        rm -rf "$temp_dir"
        
        verify_nodejs_installation "$node_version"
    else
        rm -rf "$temp_dir"
        return 1
    fi
}

# Verify Node.js installation
verify_nodejs_installation() {
    local expected_version=$1
    
    # Reload environment
    source /etc/profile.d/nodejs.sh 2>/dev/null || true
    
    if command_exists node; then
        local installed_version=$(node --version | sed 's/v//')
        if [ "$installed_version" = "$expected_version" ]; then
            print_color "$GREEN" "Node.js $expected_version installed successfully!"
            return 0
        else
            print_color "$RED" "Node.js installation failed - expected: $expected_version, got: $installed_version"
            return 1
        fi
    else
        print_color "$RED" "Node.js installation failed - command not found"
        return 1
    fi
}

# Verify all installations
verify_installation() {
    print_color "$MAGENTA" ""
    print_color "$MAGENTA" "=== Verifying Installation ==="
    
    local success=true
    
    # Source environment files
    source /etc/profile.d/java.sh 2>/dev/null || true
    source /etc/profile.d/maven.sh 2>/dev/null || true
    source /etc/profile.d/nodejs.sh 2>/dev/null || true
    
    # Test Java
    if command_exists java; then
        local java_output=$(java -version 2>&1)
        if echo "$java_output" | grep -q "openjdk version \"21.0.7\""; then
            print_color "$GREEN" "✓ Java 21.0.7 verified"
        else
            print_color "$RED" "✗ Java verification failed"
            success=false
        fi
    else
        print_color "$RED" "✗ Java not found in PATH"
        success=false
    fi
    
    # Test Maven
    if command_exists mvn; then
        local maven_output=$(mvn -version 2>&1)
        if echo "$maven_output" | grep -q "Apache Maven 3.9.9"; then
            print_color "$GREEN" "✓ Maven 3.9.9 verified"
        else
            print_color "$RED" "✗ Maven verification failed"
            success=false
        fi
    else
        print_color "$RED" "✗ Maven not found in PATH"
        success=false
    fi
    
    # Test Node.js
    if command_exists node; then
        local node_output=$(node --version)
        if [ "$node_output" = "v22.14.0" ]; then
            print_color "$GREEN" "✓ Node.js 22.14.0 verified"
        else
            print_color "$RED" "✗ Node.js verification failed - found: $node_output"
            success=false
        fi
    else
        print_color "$RED" "✗ Node.js not found in PATH"
        success=false
    fi
    
    # Test npm
    if command_exists npm; then
        local npm_output=$(npm --version)
        print_color "$GREEN" "✓ npm $npm_output verified"
    else
        print_color "$RED" "✗ npm not found in PATH"
        success=false
    fi
    
    if [ "$success" = true ]; then
        return 0
    else
        return 1
    fi
}

# Main execution function
main() {
    print_color "$CYAN" "DRR Build Environment Prerequisites Installation Script - Linux"
    print_color "$CYAN" "================================================================="
    
    # Check root privileges
    check_root
    
    # Detect distribution
    detect_distro
    
    # Update packages
    update_packages
    
    # Install prerequisites
    install_prerequisites
    
    local overall_success=true
    
    # Install Java
    if [ "$SKIP_JAVA" = false ]; then
        if ! install_java; then
            overall_success=false
        fi
    else
        print_color "$GRAY" "Skipping Java installation"
    fi
    
    # Install Maven
    if [ "$SKIP_MAVEN" = false ]; then
        if ! install_maven; then
            overall_success=false
        fi
    else
        print_color "$GRAY" "Skipping Maven installation"
    fi
    
    # Install Node.js
    if [ "$SKIP_NODE" = false ]; then
        if ! install_nodejs; then
            overall_success=false
        fi
    else
        print_color "$GRAY" "Skipping Node.js installation"
    fi
    
    # Verify installation
    sleep 2  # Give time for installations to complete
    if verify_installation; then
        verification_success=true
    else
        verification_success=false
    fi
    
    print_color "$MAGENTA" ""
    print_color "$MAGENTA" "=== Installation Summary ==="
    
    if [ "$overall_success" = true ] && [ "$verification_success" = true ]; then
        print_color "$GREEN" "✓ All components installed and verified successfully!"
        print_color "$CYAN" ""
        print_color "$CYAN" "Next steps:"
        print_color "$WHITE" "1. Reload your shell or run: source /etc/profile"
        print_color "$WHITE" "2. Verify your environment with: java -version, mvn -version, node --version"
        print_color "$WHITE" "3. Your DRR build environment is ready!"
        exit 0
    else
        print_color "$RED" "✗ Some components failed to install or verify"
        print_color "$YELLOW" "Please check the error messages above and retry"
        exit 1
    fi
}

# Run main function
main "$@"
