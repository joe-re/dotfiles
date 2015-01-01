#!/bin/bash

files=("vimrc" "ctags" "tmux.conf" "atom" "rubocop.yml")

for file in ${files[*]}
do
   filepath="${PWD}/home_symlinks/${file}"
   homefile="${HOME}/.${file}"

  if [ -e "${homefile}" ]; then
     echo "${file} exist. then rm ${homefile} and make sysmbolic link from ${filepath} "
     rm "${homefile}"
  else
     echo "${file} not exis, make symbolic link to ${homefile}"
  fi
  ln -s "${filepath}" "${homefile}"
done
