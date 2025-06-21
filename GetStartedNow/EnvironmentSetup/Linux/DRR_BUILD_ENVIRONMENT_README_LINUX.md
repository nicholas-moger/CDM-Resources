# DRR Build Environment Setup - Linux

This document describes the build environment setup for the DRR (Disaster Risk Reduction) training project on Linux systems.

## Required Tools and Versions

Based on the reference build environment, the following tools and versions are required:

### Java Development Kit (JDK)
- **Version**: OpenJDK 21.0.7 LTS (Eclipse Temurin)
- **Vendor**: Eclipse Adoptium
- **Architecture**: 64-bit
- **Installation Path**: `/opt/eclipse-adoptium/jdk-21.0.7+6` or `/usr/lib/jvm/temurin-21-jdk-amd64`
- **Environment Variable**: `JAVA_HOME=/opt/eclipse-adoptium/jdk-21.0.7+6`

### Apache Maven
- **Version**: 3.9.9
- **Installation Path**: `/opt/apache-maven-3.9.9`
- **Environment Variable**: `MAVEN_HOME=/opt/apache-maven-3.9.9`

### Node.js
- **Version**: 22.14.0
- **Package Manager**: npm 10.9.2

## Manual Installation Steps

### 1. Install Java 21 (Eclipse Temurin)

#### Option A: Using Package Manager (Recommended)

**Ubuntu/Debian:**
```bash
# Add Eclipse Adoptium repository
wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | sudo apt-key add -
echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | sudo tee /etc/apt/sources.list.d/adoptium.list

# Update package list and install
sudo apt update
sudo apt install temurin-21-jdk
```

**CentOS/RHEL/Fedora:**
```bash
# Add Eclipse Adoptium repository
sudo rpm --import https://packages.adoptium.net/artifactory/api/gpg/key/public
echo -e "[Adoptium]\nname=Adoptium\nbaseurl=https://packages.adoptium.net/artifactory/rpm/centos/\$releasever/\$basearch\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.adoptium.net/artifactory/api/gpg/key/public" | sudo tee /etc/yum.repos.d/adoptium.repo

# Install
sudo yum install temurin-21-jdk  # CentOS/RHEL
# OR
sudo dnf install temurin-21-jdk  # Fedora
```

#### Option B: Manual Installation
```bash
# Download and extract
cd /tmp
wget https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.7%2B6/OpenJDK21U-jdk_x64_linux_hotspot_21.0.7_6.tar.gz
sudo mkdir -p /opt/eclipse-adoptium
sudo tar -xzf OpenJDK21U-jdk_x64_linux_hotspot_21.0.7_6.tar.gz -C /opt/eclipse-adoptium
sudo mv /opt/eclipse-adoptium/jdk-21.0.7+6 /opt/eclipse-adoptium/jdk-21.0.7+6
```

#### Verify Installation:
```bash
java -version
```

### 2. Install Apache Maven

```bash
# Download Maven
cd /tmp
wget https://archive.apache.org/dist/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz

# Extract to /opt
sudo tar -xzf apache-maven-3.9.9-bin.tar.gz -C /opt
sudo ln -s /opt/apache-maven-3.9.9 /opt/maven

# Verify installation
mvn -version
```

### 3. Install Node.js 22.14.0

#### Option A: Using NodeSource Repository (Recommended)
```bash
# Add NodeSource repository
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -

# Install Node.js
sudo apt-get install -y nodejs  # Ubuntu/Debian
# OR
sudo yum install -y nodejs npm   # CentOS/RHEL
# OR  
sudo dnf install -y nodejs npm   # Fedora
```

#### Option B: Using Node Version Manager (nvm)
```bash
# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc

# Install Node.js 22.14.0
nvm install 22.14.0
nvm use 22.14.0
nvm alias default 22.14.0
```

#### Option C: Manual Installation
```bash
# Download and install
cd /tmp
wget https://nodejs.org/dist/v22.14.0/node-v22.14.0-linux-x64.tar.xz
sudo tar -xJf node-v22.14.0-linux-x64.tar.xz -C /opt
sudo ln -s /opt/node-v22.14.0-linux-x64 /opt/nodejs
```

#### Verify Installation:
```bash
node --version
npm --version
```

## Environment Variables Setup

Add the following to your shell profile (`~/.bashrc`, `~/.zshrc`, or `/etc/environment`):

```bash
# Java
export JAVA_HOME=/opt/eclipse-adoptium/jdk-21.0.7+6
export PATH=$JAVA_HOME/bin:$PATH

# Maven
export MAVEN_HOME=/opt/apache-maven-3.9.9
export PATH=$MAVEN_HOME/bin:$PATH

# Node.js (if installed manually)
export PATH=/opt/nodejs/bin:$PATH
```

After adding these lines, reload your shell:
```bash
source ~/.bashrc
# OR
source ~/.zshrc
```

## Automated Installation

For automated installation, use the provided shell script:

```bash
chmod +x install_drr_prerequisites.sh
sudo ./install_drr_prerequisites.sh
```

This script will:
- Detect your Linux distribution
- Install the required versions of Java, Maven, and Node.js
- Configure environment variables
- Verify the installation

## Distribution-Specific Notes

### Ubuntu/Debian
- Use `apt` package manager
- May require `sudo apt update` before installation
- Environment variables can be set in `/etc/environment` for system-wide access

### CentOS/RHEL
- Use `yum` (CentOS 7/RHEL 7) or `dnf` (CentOS 8+/RHEL 8+)
- May require EPEL repository for some packages
- SELinux may need to be configured for Java applications

### Fedora
- Use `dnf` package manager
- Generally has more recent package versions available

### Arch Linux
- Use `pacman` package manager
- AUR (Arch User Repository) may have specific versions
- Consider using `jdk-openjdk` and `maven` from official repositories

## Verification

To verify your build environment is correctly set up, run:

```bash
# Check Java
java -version
echo $JAVA_HOME

# Check Maven  
mvn -version
echo $MAVEN_HOME

# Check Node.js and npm
node --version
npm --version

# Check environment variables
env | grep -E "(JAVA_HOME|MAVEN_HOME|PATH)"
```

Expected output should match the versions specified in this document.

## Troubleshooting

### Common Issues

1. **Command not found errors**: 
   - Ensure tools are in your PATH
   - Reload shell configuration: `source ~/.bashrc`
   - Check if `/usr/local/bin` is in your PATH

2. **Permission denied errors**:
   - Use `sudo` for system-wide installations
   - Consider installing in user directory (`~/local`) if sudo access is limited

3. **Java version conflicts**:
   - Use `update-alternatives` to manage multiple Java versions:
     ```bash
     sudo update-alternatives --config java
     sudo update-alternatives --config javac
     ```

4. **Maven not finding Java**:
   - Ensure JAVA_HOME is set correctly
   - Check that JAVA_HOME points to JDK, not JRE

5. **Node.js/npm permission issues**:
   - Configure npm to use a different directory for global packages:
     ```bash
     mkdir ~/.npm-global
     npm config set prefix '~/.npm-global'
     echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
     source ~/.bashrc
     ```

### Environment Variable Issues

If environment variables are not persisting:

1. **For current user**: Add to `~/.bashrc` or `~/.zshrc`
2. **System-wide**: Add to `/etc/environment` or `/etc/profile`
3. **Verify**: Use `echo $VARIABLE_NAME` to check values
4. **Reload**: Use `source ~/.bashrc` or restart terminal

### Package Manager Issues

If package installation fails:

```bash
# Update package lists
sudo apt update          # Ubuntu/Debian
sudo yum update          # CentOS/RHEL
sudo dnf update          # Fedora

# Clean package cache
sudo apt clean           # Ubuntu/Debian
sudo yum clean all       # CentOS/RHEL
sudo dnf clean all       # Fedora
```

## Security Considerations

- Always download packages from official sources
- Verify checksums when downloading manually
- Keep software updated for security patches
- Consider using package managers over manual installation
- Review permissions on installed software

## Notes

- The automated script requires sudo privileges
- Some distributions may have different default paths
- Virtual environments (Docker, containers) may require additional configuration
- Consider using package managers specific to your distribution for easier updates
- Internet connection is required for downloading packages

## Support

For issues specific to the DRR project build environment, please contact the project maintainers.

For distribution-specific issues, consult:
- Ubuntu/Debian: https://help.ubuntu.com/ or https://www.debian.org/support/
- CentOS/RHEL: https://www.centos.org/help/ or https://access.redhat.com/support/
- Fedora: https://fedoraproject.org/wiki/Communicating_and_getting_help
