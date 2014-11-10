#!/bin/bash
set -e
# brew bundle 叩く
brew bundle || true

# 設定ファイルのシンボリックを作成
echo "start to make sym link"
files=("gitconfig" "vimrc" "zshrc" "ctags" "tmux.conf" "atom" "zprofile" "vrapperrc" "rubocop.yml", "oh-my-zsh")

# to home dir
for file in ${files[*]}
do
  filepath="${PWD}/${file}"
  homefile="${HOME}/.${file}"
  ln -sf "${filepath}" "${homefile}"
  echo "made symlink: ${homefile}"
done

# karabiner
karabiner_file="${PWD}/private.xml"
to_karabiner_file=~/Library/Application\ Support/Karabiner/private.xml
ln -sf "${karabiner_file}" "${to_karabiner_file}"
echo "made symlink: ${to_karabiner_file}"

# mkdir vim backup dir
vim_backup_dir="${HOME}/.vim-backup"
if test -e "${vim_backup_dir}"; then
  echo "${vim_backup_dir} is exists"
else
  mkdir "${vim_backup_dir}"
  echo "made dir: ${vim_backup_dir}"
fi

echo "completed!"
