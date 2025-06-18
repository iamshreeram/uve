#!/usr/bin/env bash

set -euo pipefail

BASE_URL="https://github.com/iamshreeram/uve/releases/latest/download"
TEMP_DIR=$(mktemp -d)

# Detect OS and Architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case $ARCH in
    x86_64) ARCH="amd64" ;;
    arm64 | aarch64) ARCH="arm64" ;;
    *) echo "Unsupported architecture"; exit 1 ;;
esac

BIN_PATH="${HOME}/.local/bin"
mkdir -p "${BIN_PATH}"

case $OS in
    linux|darwin)
        BIN_NAME="uve-${OS}-${ARCH}"
        echo "Downloading UVE for ${OS}-${ARCH}..."
        curl -L "${BASE_URL}/${BIN_NAME}.tar.gz" -o "${TEMP_DIR}/uve.tar.gz"
        tar -xzf "${TEMP_DIR}/uve.tar.gz" -C "${TEMP_DIR}"
        mv "${TEMP_DIR}/${BIN_NAME}" "${BIN_PATH}/uve-bin"
        chmod +x "${BIN_PATH}/uve-bin"
        # Optional: also provide a user-friendly alias "uve"
        ln -sf "${BIN_PATH}/uve-bin" "${BIN_PATH}/uve"
        ;;
    msys*|mingw*|cygwin*)
        BIN_NAME="uve-windows-amd64.exe"
        echo "Downloading UVE for windows-amd64..."
        curl -L "${BASE_URL}/${BIN_NAME}.zip" -o "${TEMP_DIR}/uve.zip"
        unzip -o "${TEMP_DIR}/uve.zip" -d "${TEMP_DIR}"
        mv "${TEMP_DIR}/uve.exe" "${BIN_PATH}/uve-bin.exe"
        # Optional: also copy as uve.exe for user-friendliness
        cp "${BIN_PATH}/uve-bin.exe" "${BIN_PATH}/uve.exe"
        ;;
    *)
        echo "Unsupported OS: ${OS}"; exit 1 ;;
esac

# Ensure ~/.local/bin is in PATH for the user's shell
if ! echo "$PATH" | grep -q "$HOME/.local/bin" ; then
    SHELL_NAME="$(basename "${SHELL:-}")"
    case "$SHELL_NAME" in
        bash)
            PROFILE="$HOME/.bashrc"
            ADD_CMD='export PATH="$HOME/.local/bin:$PATH"'
            ;;
        zsh)
            PROFILE="$HOME/.zshrc"
            ADD_CMD='export PATH="$HOME/.local/bin:$PATH"'
            ;;
        fish)
            PROFILE="$HOME/.config/fish/config.fish"
            ADD_CMD='set -gx PATH $HOME/.local/bin $PATH'
            ;;
        *)
            PROFILE="$HOME/.profile"
            ADD_CMD='export PATH="$HOME/.local/bin:$PATH"'
            ;;
    esac

    # Only add if not already present in the config file
    if [ ! -f "$PROFILE" ] || ! grep -Fq "$ADD_CMD" "$PROFILE"; then
        echo "$ADD_CMD" >> "$PROFILE"
        echo "Added ~/.local/bin to PATH in $PROFILE"
    fi
    echo "Please restart your shell or run: source $PROFILE"
fi

# Initialize shell
echo "Setting up shell integration..."
if [[ "$OS" == "linux" || "$OS" == "darwin" ]]; then
    "${BIN_PATH}/uve-bin" init
else
    "${BIN_PATH}/uve-bin.exe" init
fi

echo "UVE installed successfully to ${BIN_PATH}"
if [[ "$OS" == "linux" || "$OS" == "darwin" ]]; then
    echo "Please restart your shell or run: source ~/.bashrc (or equivalent)"
else
    echo "Please restart your shell or run: Import-Module uve in PowerShell"
fi
