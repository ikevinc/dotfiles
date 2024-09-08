#!/bin/sh

# Exit immediately if 1Password is already installed and in $PATH
type op >/dev/null 2>&1 && exit 0

# Hardcoded 1Password email and account URL
OP_ACCOUNT_EMAIL="kevin.cao.me@gmail.com"
OP_ACCOUNT_URL="https://my.1password.com"

install_1password_on_linux() {
    echo "Installing 1Password CLI on Linux..."

    # Use sudo for commands that require root access
    sudo curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
    sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] \
    https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | \
    sudo tee /etc/apt/sources.list.d/1password.list

    # Set up debsig policy and keyrings
    sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/ /usr/share/debsig/keyrings/AC2D62742012EA22

    sudo curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | \
    sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol

    sudo curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
    sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg

    # Update package list and install 1Password CLI
    sudo apt-get update && sudo apt-get install -y 1password-cli

    # Ensure installation success
    if ! command -v op >/dev/null 2>&1; then
        echo "1Password CLI installation failed!"
        exit 1
    fi

    echo "1Password CLI installed successfully."
}

login_to_1password() {
    # Prompt for secret key and password
    read -p "Enter your 1Password secret key: " OP_ACCOUNT_SECRET
    read -sp "Enter your 1Password password: " OP_ACCOUNT_PASSWORD
    echo ""

    # Sign in to 1Password CLI
    eval $(echo "$OP_ACCOUNT_PASSWORD" | op account add --email "$OP_ACCOUNT_EMAIL" --secret-key "$OP_ACCOUNT_SECRET" --url "$OP_ACCOUNT_URL")

    if [ $? -ne 0 ]; then
        echo "1Password CLI login failed! Please check your credentials."
        exit 1
    fi

    echo "1Password CLI logged in successfully."
}

case "$(uname -s)" in
    Linux)
        install_1password_on_linux
        login_to_1password
        ;;
    *)
        echo "Unsupported OS"
        exit 1
        ;;
esac
