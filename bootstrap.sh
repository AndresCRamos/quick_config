#!/usr/bin/env sh

set -e

echo "Install nala"
sudo apt update
sudo apt install -y nala

echo "Install zsh (this has to be done to avoid problems)"
sudo nala install -y zsh

echo Add gh repo
sudo mkdir -p -m 755 /etc/apt/keyrings \
&& curl -fsLS https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \

echo Installing OhMyZSH
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo Installing Power10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
sed -i 's/ZSH_THEME="[a-zA-Z0-9]*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/g' "$HOME/.zshrc"

echo Installing nvm
curl -fsSLo- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | zsh

echo "Install pyenv"
curl -fsSLo https://pyenv.run | zsh

echo "Install gvm"
sudo nala install bison  golang-go -y
curl -fsSLo- https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer| zsh

echo Installing nala packages:
sudo nala update
packages_file="apt_packages"

# Read the contents of the file line by line and install each package
set +e
while IFS= read -r pkg || [ -n "$pkg" ]; do
    echo Install $pkg
    sudo nala install $pkg -y
done < "$packages_file"

echo "All packages installed successfully."
sudo nala autoremove

echo Copying config dotfiles
dir="dotfiles"


for file in "$dir"/.* "$dir"/*; do
    if [ -f "$file" ]; then
        real_file="${file#"$dir"/}"
        echo "$real_file"
        rm "$HOME/$real_file"
        ln -s "$(realpath "$file")" "$HOME"
    fi
done

echo Logging to github
gh auth login

# Change default gh browser to ms edge
PATH=$PATH:/mnt/c/"Program Files (x86)"/Microsoft/Edge/Application
gh config set browser msedge.exe

echo Finished