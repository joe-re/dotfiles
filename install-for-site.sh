#!/bin/bash
 
files=("vimrc")
 
for file in ${files[*]}
do
   filepath="${PWD}/${file}"
   homefile="${HOME}/.${file}"
 
  # . と .. .git は抜かす
  test $file == ".git" && continue
  test $file == "." && continue
  test $file == ".." && continue
 
  if [ -e "${homefile}" ]; then
     echo "${file} exist. then rm ${homefile} and make sysmbolic link from ${filepath} "
     rm "${homefile}"
  else
     echo "${file} not exis, make symbolic link to ${homefile}"
  fi
  ln -s "${filepath}" "${homefile}"
done
