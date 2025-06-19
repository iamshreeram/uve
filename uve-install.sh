#!/usr/bin/env bash

set -euo pipefail

# Define colors
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    BOLD='\033[1m'
    NC='\033[0m' # No Color
else
    RED=''; GREEN=''; YELLOW=''; BLUE=''; BOLD=''; NC=''
fi

BASE_URL="https://github.com/iamshreeram/uve/releases/latest/download"
TEMP_DIR=$(mktemp -d)

# Detect OS and Architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case $ARCH in
    x86_64) ARCH="amd64" ;;
    arm64 | aarch64) ARCH="arm64" ;;
    *) echo -e "${RED}Unsupported architecture${NC}"; exit 1 ;;
esac

BIN_PATH="${HOME}/.local/bin"
mkdir -p "${BIN_PATH}"

case $OS in
    linux|darwin)
        BIN_NAME="uve-${OS}-${ARCH}"
        echo -e "${BLUE}Downloading UVE for ${OS}-${ARCH}...${NC}"
        curl -L "${BASE_URL}/${BIN_NAME}.tar.gz" -o "${TEMP_DIR}/uve.tar.gz"
        tar -xzf "${TEMP_DIR}/uve.tar.gz" -C "${TEMP_DIR}"
        mv "${TEMP_DIR}/${BIN_NAME}" "${BIN_PATH}/uve-bin"
        chmod +x "${BIN_PATH}/uve-bin"
        ln -sf "${BIN_PATH}/uve-bin" "${BIN_PATH}/uve"
        ;;
    msys*|mingw*|cygwin*)
        BIN_NAME="uve-windows-amd64.exe"
        echo -e "${BLUE}Downloading UVE for windows-amd64...${NC}"
        curl -L "${BASE_URL}/${BIN_NAME}.zip" -o "${TEMP_DIR}/uve.zip"
        unzip -o "${TEMP_DIR}/uve.zip" -d "${TEMP_DIR}"
        mv "${TEMP_DIR}/uve.exe" "${BIN_PATH}/uve-bin.exe"
        cp "${BIN_PATH}/uve-bin.exe" "${BIN_PATH}/uve.exe"
        ;;
    *)
        echo -e "${RED}Unsupported OS: ${OS}${NC}"; exit 1 ;;
esac

# Ensure ~/.local/bin is in PATH for the user's shell
if ! echo "$PATH" | grep -q "$HOME/.local/bin" ; then
    SHELL_NAME="$(basename "${SHELL:-}")"
    case "$SHELL_NAME" in
        bash) PROFILE="$HOME/.bashrc"; ADD_CMD='export PATH="$HOME/.local/bin:$PATH"' ;;
        zsh)  PROFILE="$HOME/.zshrc";  ADD_CMD='export PATH="$HOME/.local/bin:$PATH"' ;;
        fish) PROFILE="$HOME/.config/fish/config.fish"; ADD_CMD='set -gx PATH $HOME/.local/bin $PATH' ;;
        *)    PROFILE="$HOME/.profile"; ADD_CMD='export PATH="$HOME/.local/bin:$PATH"' ;;
    esac

    if [ ! -f "$PROFILE" ] || ! grep -Fq "$ADD_CMD" "$PROFILE"; then
        echo "$ADD_CMD" >> "$PROFILE"
        echo -e "${YELLOW}Added ~/.local/bin to PATH in ${PROFILE}${NC}"
    fi
    echo -e "${YELLOW}Please restart your shell or run: source ${PROFILE}${NC}"
fi

# Initialize shell
echo -e "${BLUE}Setting up shell integration...${NC}"
if [[ "$OS" == "linux" || "$OS" == "darwin" ]]; then
    "${BIN_PATH}/uve-bin" init
else
    "${BIN_PATH}/uve-bin.exe" init
fi

# Check for UV
echo -e "${BLUE}Checking for 'uv' binary...${NC}"

if ! command -v uv >/dev/null 2>&1; then
    echo -e "${YELLOW}'uv' not found. Attempting installation using the official script...${NC}"

    if [[ "$OS" == "darwin" || "$OS" == "linux" ]]; then
        if ! (curl -LsSf https://astral.sh/uv/install.sh | bash); then
            echo -e "${RED}❌ Error: Failed to install 'uv' using the official install script.${NC}" >&2
            echo -e "${RED}👉 'uve' requires 'uv' to be installed. Please install 'uv' manually.${NC}" >&2
            exit 3
        fi
    elif [[ "$OS" == "msys"* || "$OS" == "mingw"* || "$OS" == "cygwin"* ]]; then
        if ! powershell -NoProfile -Command "irm https://astral.sh/uv/install.ps1 | iex"; then
            echo -e "${RED}❌ Error: Failed to install 'uv' using the official PowerShell script.${NC}" >&2
            echo -e "${RED}👉 'uve' requires 'uv' to be installed. Please install 'uv' manually.${NC}" >&2
            exit 4
        fi
    else
        echo -e "${RED}❌ Error: Unsupported operating system.${NC}" >&2
        echo -e "${RED}👉 Unable to determine how to install 'uv'. Please install it manually.${NC}" >&2
        exit 5
    fi
else
    echo -e "${GREEN}'uv' is already installed.${NC}"
fi

echo -e "${GREEN}✅ UVE installed successfully to ${BIN_PATH}${NC}"
if [[ "$OS" == "linux" || "$OS" == "darwin" ]]; then
    echo -e "${YELLOW}Please restart your shell or run: source ~/.bashrc (or equivalent)${NC}"
else
    echo -e "${YELLOW}Please restart your shell or run: Import-Module uve in PowerShell${NC}"
fi
