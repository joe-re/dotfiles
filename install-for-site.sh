#!/bin/bash

files=("vimrc" "ctags" "tmux.conf" "rubocop.yml")

for file in ${files[*]}
do
  filepath="${PWD}/home_symlinks/${file}"
  homefile="${HOME}/.${file}"
  ln -fs "${filepath}" "${homefile}"
done
