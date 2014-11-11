#!/bin/bash
set -e

# oh-my-zsh install
oh_my_sh=~/.oh-my-zsh/oh-my-zsh.sh
if test -e "${oh_my_sh}"; then
  echo "${oh_my_sh} is exists"
else
  curl -L http://install.ohmyz.sh | sh
  echo "installed oh-my-zsh"
fi

# brew bundle 叩く
brew bundle || true

# 設定ファイルのシンボリックを作成
echo "start to make sym link"
files=("gitconfig" "vimrc" "zshrc" "ctags" "tmux.conf" "atom" "zprofile" "vrapperrc" "rubocop.yml" "z")

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

# neobundle install
neobundle_dir=~/.vim/bundle
if test -e "${neobundle_dir}"; then
  echo "${neobundle_dir} is exists"
else
  mkdir -p ${neobundle_dir}
  git clone git://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim
  echo "installed neobundle"
fi

# go modules install
go get github.com/motemen/ghq
go get github.com/lestrrat/peco/cmd/peco/
echo "installed go modules"

echo "completed!"
