#!/usr/bin/env bash

# Update source repository so that it includes python3.11
sudo apt update && sudo apt upgrade -y
sudo apt install software-properties-common -y
sudo add-apt-repository ppa:deadsnakes/ppa

# Install Python3.11
sudo apt install python3.11

# Set 3.11 as the default
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1
sudo update-alternatives --config python3

# Fix python3-apt, pip and distutils
sudo apt remove --purge python3-apt
sudo apt autoclean
sudo apt install python3-apt
sudo apt install python3.11-distutils

# Install and update pip
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
sudo python3.11 get-pip.py
pip install --upgrade pip
if [ -f get-pip.py ]; then
    # n.b.: write protected file
    rm -f get-pip.py
fi

# Install some dependencies
sudo apt install python3.11-venv python3.11-dev
