# Provision Desktop cloud instance

## Install zsh 

```bash
sudo apt update
sudo apt install zsh
```

## Install oh-my-zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

## Install nvm

```bash
export $PROFILE=~/.zshrc
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
```

## Install node

```bash
nvm install 20
```

## Install cf8-cli

```bash
 sudo apt update
 sudo curl -fsSL https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | sudo gpg --dearmor -o /usr/share/keyrings/cloudfoundry-keyring.gpg\n
echo "deb [signed-by=/usr/share/keyrings/cloudfoundry-keyring.gpg] https://packages.cloudfoundry.org/debian stable main" | sudo tee /etc/apt/sources.list.d/cloudfoundry.list
sudo apt update
sudo apt install --yes cf8-cli
```

## Install mbt

```bash
npm install -g mbt
```
