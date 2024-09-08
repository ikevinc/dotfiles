#!/bin/sh

# Exit immediately if 1Password CLI is already in $PATH
type op >/dev/null 2>&1 && exit

# Install 1Password CLI on Linux
sudo -s <<EOF
# Step 1: Add the 1Password GPG key
curl -sS https://downloads.1password.com/linux/keys/1password.asc | gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg

# Step 2: Add the 1Password apt repository
echo "deb [arch=\$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/\$(dpkg --print-architecture) stable main" | tee /etc/apt/sources.list.d/1password.list

# Step 3: Set up the debsig policy
mkdir -p /etc/debsig/policies/AC2D62742012EA22/
curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | tee /etc/debsig/policies/AC2D62742012EA22/1password.pol

# Step 4: Set up the debsig keyrings
mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
curl -sS https://downloads.1password.com/linux/keys/1password.asc | gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg

# Step 5: Update the package list and install 1Password CLI
apt update && apt install 1password-cli -y
EOF

# Hardcoded 1Password email and sign-in address
OP_ACCOUNT_EMAIL="kevin.cao.me@gmail.com"
OP_ACCOUNT_ADDRESS="my.1password.com"

# Function to add the 1Password account
add_1password_account() {
    # Prompt for secret key and password
    echo "Enter your 1Password secret key: "
    read OP_ACCOUNT_SECRET
    echo "Enter your 1Password password: "
    read OP_ACCOUNT_PASSWORD

    # Add the 1Password account
    echo "$OP_ACCOUNT_PASSWORD" | op account add --address "$OP_ACCOUNT_ADDRESS" --email "$OP_ACCOUNT_EMAIL" --secret-key "$OP_ACCOUNT_SECRET"

    if [ $? -ne 0 ]; then
        echo "1Password account addition failed! Please check your credentials."
        exit 1
    fi

    echo "1Password account added successfully."
}

# Function to sign into 1Password
sign_in_to_1password() {
    eval $(op signin --account my)

    if [ $? -ne 0 ]; then
        echo "1Password CLI sign-in failed!"
        exit 1
    fi

    echo "1Password CLI logged in successfully."
}

# Add the account, then sign in
add_1password_account
sign_in_to_1password