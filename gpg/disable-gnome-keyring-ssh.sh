#!/bin/bash
set -e
mkdir -p ~/.config/autostart/
cp /etc/xdg/autostart/gnome-keyring-ssh.desktop ~/.config/autostart/
echo Hidden=true >> ~/.config/autostart/gnome-keyring-ssh.desktop

echo '# Add the following lines to ~/.xprofile, and relogin to apply the changes:'
echo 'export SSH_AGENT_PID='
echo 'export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/gnupg/S.gpg-agent.ssh"'
