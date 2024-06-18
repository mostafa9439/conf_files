#!/bin/bash

# Function to prompt the user for yes/no input
ask_yes_no() {
    while true; do
        read -p "$1 [y/n]: " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# Prompt for PX4 toolchain installation
install_px4_toolchain=false
install_nuttx=true
install_sim_tools=true
if ask_yes_no "Do you want to install the PX4 toolchain?"; then
    install_px4_toolchain=true
    if ask_yes_no "Do you want to install NuttX?"; then
        install_nuttx=true
    else
        install_nuttx=false
    fi
    if ask_yes_no "Do you want to install simulation tools?"; then
        install_sim_tools=true
    else
        install_sim_tools=false
    fi
fi

# Update and upgrade the system
sudo apt update && sudo apt upgrade -y

# Install Slack
sudo snap install slack --classic

# Install Obsidian through snap
sudo snap install obsidian --classic

# Install Google Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb -y
rm google-chrome-stable_current_amd64.deb

# Install QGroundControl dependencies
sudo apt install gstreamer1.0-plugins-bad gstreamer1.0-libav gstreamer1.0-gl -y
sudo apt install libfuse2 -y
sudo apt install libxcb-xinerama0 libxkbcommon-x11-0 libxcb-cursor0 -y

# Install QGroundControl (skip removal of Modem Manager)
wget https://d176tv9ibo4jno.cloudfront.net/latest/QGroundControl.AppImage
chmod +x QGroundControl.AppImage
sudo mv QGroundControl.AppImage /usr/local/bin/QGroundControl

# Add alias for QGroundControl and Sublime Text
echo "alias qgc='/usr/local/bin/QGroundControl'" >> ~/.bashrc
echo "alias subl='/usr/bin/subl'" >> ~/.bashrc
echo "alias ovpn='sudo openvpn --config /etc/openvpn/client/client.conf'" >> ~/.bashrc
echo "alias novpn='sudo pkill openvpn'" >> ~/.bashrc
source ~/.bashrc

# Install tmux
sudo apt install tmux -y

# Install xclip
sudo apt install xclip -y

# Install Sublime Text
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
sudo apt update
sudo apt install sublime-text -y

# Install vim
sudo apt install vim -y

# Copy .vimrc and .tmux.conf to the home directory
cp .vimrc ~/
cp .tmux.conf ~/

# Copy client.conf to /etc/openvpn/client/
sudo cp client.conf /etc/openvpn/client/

# Set local RTC
sudo timedatectl set-local-rtc 1

# Install PX4 toolchain if selected
if [ "$install_px4_toolchain" = true ]; then
    git clone https://github.com/PX4/PX4-Autopilot.git --recursive
    cd PX4-Autopilot
    if [ "$install_nuttx" = false ] && [ "$install_sim_tools" = false ]; then
        bash ./Tools/setup/ubuntu.sh --no-nuttx --no-sim-tools
    elif [ "$install_nuttx" = false ]; then
        bash ./Tools/setup/ubuntu.sh --no-nuttx
    elif [ "$install_sim_tools" = false ]; then
        bash ./Tools/setup/ubuntu.sh --no-sim-tools
    else
        bash ./Tools/setup/ubuntu.sh
    fi
    cd ..
fi

echo "All applications have been installed successfully."
