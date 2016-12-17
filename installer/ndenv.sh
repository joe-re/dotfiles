if [ ! -d ${HOME}/.ndenv ]; then
  git clone https://github.com/riywo/ndenv ~/.ndenv
  git clone https://github.com/riywo/node-build.git $(ndenv root)/plugins/node-build
fi
