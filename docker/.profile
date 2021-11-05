if [ -n "$BASH_VERSION" ]; then
  if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
  fi
else
  # .local/bin (used by pip for instance)
  PATH="${PATH}:~/.local/bin"
fi
