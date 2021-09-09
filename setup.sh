#!/usr/bin/env bash
# sudo amazon-linux-extras install epel -y
sudo yum remove -y $(yum list installed | grep @amzn2extra-lamp | awk '{ print $1 }')
sudo amazon-linux-extras disable lamp-mariadb10.2-php7.2
sudo yum-config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
sudo yum install -y gh

# https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html#linux
# EKS_UTILS="kubectl aws-iam-authenticator"
EKS_UTILS="kubectl"
EKS_VERSION="1.21.2/2021-07-05"
EKS_BUCKET_URL="https://amazon-eks.s3.us-west-2.amazonaws.com"
curl --remote-name-all "$EKS_BUCKET_URL/$EKS_VERSION/bin/linux/amd64/{${EKS_UTILS// /$','}}" &&
    chmod +x $EKS_UTILS &&
    mkdir -p $HOME/bin &&
    cp $EKS_UTILS $HOME/bin/ &&
    rm $EKS_UTILS
export PATH=$PATH:$HOME/bin
echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc

sudo yum install -y jq
python3 -m pip install --user pipx
python3 -m pipx ensurepath
pipx install yq

git config --global --unset credential.helper
git config --global credential.https://github.com.helper ''
git config --add --global credential.https://github.com.helper '!'$(which gh)' auth git-credential'

cd ~/environment

gh auth login --hostname github.com --web

gh repo clone ZSuiteTech/fintech_devcon_charts ~/environment/fintech_devcon_charts

cd ~/environment/fintech_devcon_charts

gh repo fork --remote

export GH_USER=$(yq -r '."github.com".user' ~/.config/gh/hosts.yml)
echo "export GH_USER=\$(yq -r '.\"github.com\".user' ~/.config/gh/hosts.yml)" >> ~/.bashrc
