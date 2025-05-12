#!/bin/bash

# Automatic installation script for Node.js LTS version
# Supports Ubuntu/Debian/CentOS systems

# Define variables
NODE_PREFIX="/usr/local/nodejs"
TMP_DIR="/tmp/nodejs_install_$(date +%s)"

# Create temporary directory
mkdir -p $TMP_DIR && cd $TMP_DIR || exit 1

# Get latest LTS version from Node.js official API
LATEST_LTS=$(curl -s https://nodejs.org/dist/index.json | \
    grep -E '"version":"v[0-9]+\.' | \
    grep '"lts":' | \
    head -n 1 | \
    cut -d'"' -f4 | \
    sed 's/v//')

[ -z "$LATEST_LTS" ] && { echo "Error: Failed to get LTS version"; exit 1; }

# Detect system architecture
ARCH=$(uname -m)
case $ARCH in
    x86_64) ARCH_SUFFIX="linux-x64" ;;
    aarch64) ARCH_SUFFIX="linux-arm64" ;;
    *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

# Download and extract binary package
DOWNLOAD_URL="https://nodejs.org/dist/v${LATEST_LTS}/node-v${LATEST_LTS}-${ARCH_SUFFIX}.tar.xz"
echo "Downloading: $DOWNLOAD_URL"
wget -q --show-progress $DOWNLOAD_URL || { echo "Download failed"; exit 1; }

echo "Extracting to system directory..."
sudo tar -xJf node-v${LATEST_LTS}-${ARCH_SUFFIX}.tar.xz -C /usr/local/ || { echo "Extraction failed"; exit 1; }

# Create symbolic links
sudo ln -sf /usr/local/node-v${LATEST_LTS}-${ARCH_SUFFIX}/bin/node /usr/local/bin/node
sudo ln -sf /usr/local/node-v${LATEST_LTS}-${ARCH_SUFFIX}/bin/npm /usr/local/bin/npm
sudo ln -sf /usr/local/node-v${LATEST_LTS}-${ARCH_SUFFIX}/bin/npx /usr/local/bin/npx

# Configure environment variables
echo "Setting up environment variables..."
echo "export PATH=\"/usr/local/node-v${LATEST_LTS}-${ARCH_SUFFIX}/bin:\$PATH\"" | sudo tee /etc/profile.d/nodejs.sh >/dev/null
source /etc/profile.d/nodejs.sh

# Verify installation
echo -e "\nVerifying installation:"
node -v || { echo "Node.js installation failed"; exit 1; }
npm -v || { echo "npm installation failed"; exit 1; }

# Cleanup temporary files
rm -rf $TMP_DIR

echo -e "\n✅ Node.js v${LATEST_LTS} installed successfully"
echo "Binary path: /usr/local/node-v${LATEST_LTS}-${ARCH_SUFFIX}/bin"
echo "Tip: Consider configuring npm registry (run: npm config set registry https://registry.npmmirror.com)"
