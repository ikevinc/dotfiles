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

# Log in to 1Password after installation
# Email: kevin.cao.me@gmail.com
# Sign-in address: my.1password.com
eval $(op signin my.1password.com kevin.cao.me@gmail.com)