#!/bin/bash
set -exu
set -o pipefail

# Checking if either OpenDoas or Sudo is installed.
if [ -f /usr/bin/doas ]; then
    root=$(/usr/bin/doas)
elif [ -f /usr/bin/sudo ]; then
# Checking installed OS (to use package manager)
case $(awk -F= '$1 ~ /ID|VERSION_ID/ {print $2;}' /etc/os-release)
    arch)
        $root -Syy
        pkgmgr='pacman -S'
        
        # Nvim package name
        nvimpkg='neovim'
        NVIM_CONFIG_DIR='/usr/share/nvim'
        
        # Python packages
        pythonpackages='python python-pip'
        
        # NodeJS packages
        nodejspackages='nodejs npm'
        
        # Lua language server
        lualangpackages='lua-language-server'
        
        # Ripgrep
        ripgreppkg='ripgrep'
        
        # Ctags
        ctagspkg='ctags'
        ;;
esac

# Installing packages
$root $pkgmgr $nvimpkg $pythonpackages $nodejspackages $lualangpackages $ripgreppkg $ctagspkg
# Whether python3 has been installed on the system
PYTHON_INSTALLED=false
if [ -f /usr/bin/python3 ]; then
    PYTHON_INSTALLED=true
fi

if [[ ! -d "$HOME/packages/" ]]; then
    mkdir -p "$HOME/packages/"
fi

if [[ ! -d "$HOME/tools/" ]]; then
    mkdir -p "$HOME/tools/"
fi

# Install some Python packages used by Nvim plugins.
echo "Installing Python packages"
pyPackages="pynvim python-lsp-server[all] black vim-vint pyls-isort pylsp-mypy"
pip install --user $pyPackages

# Install vim-language-server and bash-language-server
$root npm install -g vim-language-server bash-language-server


echo "Setting up config and installing plugins"
if [[ -d "$NVIM_CONFIG_DIR" ]]; then
    $root rm -rf "$NVIM_CONFIG_DIR.backup"
    $root mv "$NVIM_CONFIG_DIR" "$NVIM_CONFIG_DIR.backup"
fi

$root git clone --depth=1 https://github.com/jdhao/nvim-config.git "$NVIM_CONFIG_DIR"

echo "Installing packer.nvim"
if [[ ! -d ~/.local/share/nvim/site/pack/packer/opt/packer.nvim ]]; then
    $root git clone --depth=1 https://github.com/wbthomason/packer.nvim \
        ~/.local/share/nvim/site/pack/packer/opt/packer.nvim
fi

echo "Installing nvim plugins, please wait"
nvim -c "autocmd User PackerComplete quitall" -c "PackerSync"

echo "Finished installing Nvim and its dependencies!"
