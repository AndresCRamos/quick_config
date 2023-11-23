#!/usr/bin/env sh

set -e

echo "Install zsh (this has to be done to avoid problems)"
sudo apt update
sudo apt install zsh

echo Installing nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
{ 
  echo "export NVM_DIR=\"$HOME/.nvm\""
  echo "[ -s \"$NVM_DIR/nvm.sh\" ] && \. \"$NVM_DIR/nvm.sh\"  # This loads nvm"
  echo "[ -s \"$NVM_DIR/bash_completion\" ] && \. \"$NVM_DIR/bash_completion\"  # This loads nvm bash_completion"
} >> "$HOME/.zshrc"

echo Add gh repo
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
&& sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \

echo Add ngrok repo
curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null && echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list

echo Installing OhMyZSH
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo Installing Power10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
sed -i 's/ZSH_THEME="[a-zA-Z0-9]*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/g' "$HOME/.zshrc"

echo Installing Apt packages:
packages_file="apt_packages"
packages=$(cat $packages_file)
echo "$packages"

sudo apt update
sudo apt install -y "$packages"
sudo apt autoremove

echo Copying config dotfiles
dir="dotfiles"

set +e
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
