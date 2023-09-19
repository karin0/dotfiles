#!/bin/bash
set -e

dst=~/.config/autostart/gnome-keyring-ssh.desktop

if [ -f "$dst" ]; then
  echo "$dst already exists, not overwriting"
else
  mkdir -p ~/.config/autostart/
  cp /etc/xdg/autostart/gnome-keyring-ssh.desktop ~/.config/autostart/
  echo Hidden=true >> $dst
fi

echo
echo '# Before everything, import the secret keys from another machine:'
echo '# gpg --export-secret-keys --armor > secrets.asc # on another machine'
echo '# gpg --import secrets.asc'

echo
gpg --list-secret-keys --with-keygrip
echo '# - Add the desired keygrip from above to ~/.gnupg/sshcontrol with a trimming empty line'
echo '# - Add the following lines to ~/.xprofile:'
echo 'export SSH_AGENT_PID='
echo 'export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/gnupg/S.gpg-agent.ssh"'
echo '# - And relogin to apply the changes'

echo
echo '# - If a tty pinentry is used by default, add this line to ~/.gnupg/gpg-agent.conf:'
echo '# pinentry-program /usr/bin/pinentry-qt'
echo '# - And run `systemctl --user restart gpg-agent`'
