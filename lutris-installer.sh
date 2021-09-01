#!/bin/bash
#
# Description : Lutris Installer
# Author      : Supreme Team
# Version     : 1.0
#
clear

setup_start() {
echo "$(tput setaf 6)
  _   _   _     _   _   _   _   _   _     _   _   _   _   _   _   _   _   _
 / \ / \ / \   / \ / \ / \ / \ / \ / \   / \ / \ / \ / \ / \ / \ / \ / \ / \ 
( T | H | E ) ( L | U | T | R | I | S ) ( I | N | S | T | A | L | L | E | R )
 \_/ \_/ \_/   \_/ \_/ \_/ \_/ \_/ \_/   \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/
  _   _     _   _   _     _   _   _   _   _   _   _     _   _   _   _  
 / \ / \   / \ / \ / \   / \ / \ / \ / \ / \ / \ / \   / \ / \ / \ / \ 
( B | Y ) ( T | H | E ) ( S | U | P | R | E | M | E ) ( T | E | A | M )
 \_/ \_/   \_/ \_/ \_/   \_/ \_/ \_/ \_/ \_/ \_/ \_/   \_/ \_/ \_/ \_/ 

$(tput sgr0)"
sleep 5
update_check
}

function update_check() { 
echo -e "$(tput setaf 2)
***Please note this install could take up to 30 mins*** 
$(tput sgr0)"
sleep 10

echo -e "$(tput setaf 2)
Lets first make sure your up to date!
$(tput sgr0)"
sleep 3

#Basic Update
sudo apt -y clean
sleep 2
sudo apt-get -y update --allow-releaseinfo-change
sleep 2
#Double check update on clean RetroPie.
sudo apt -y update
sleep 2
sudo apt -y upgrade
sleep 2

echo -e "$(tput setaf 2)
Done!
$(tput sgr0)"
sleep 3
clear

#Installer Steps
install_retropie_scriptmodules
install_lutris
}

install_retropie_scriptmodules() {
echo -e "$(tput setaf 2)
Lets Now Install Needed RetroPie Scriptmodules.
$(tput sgr0)"
sleep 3

cd $HOME/RetroPie-Setup
git fetch --quiet
git reset --hard HEAD --quiet
git clean -d -f --quiet
git merge '@{u}' --quiet

git clone --branch emulator https://github.com/GeorgeMcMullen/rp-box86wine /home/pi/RetroPie-Setup/ext/rp-box86wineemu/ --quiet

cd $HOME/RetroPie-Setup
sudo ./retropie_packages.sh raspbiantools lxde
sudo ./retropie_packages.sh mesa
sudo ./retropie_packages.sh box86
sudo ./retropie_packages.sh wine
sudo ./retropie_packages.sh raspbiantools package_cleanup
}


install_lutris() {
    if [[ ! -d /opt/retropie/ports ]]; then
        sudo mkdir /opt/retropie/ports
    fi
if [ -d /opt/retropie/ports/lutris ]; then
echo -e "$(tput setaf 2)
It looks like the Lutris is already installed!
$(tput sgr0)"
sleep 3 

else

echo -e "$(tput setaf 2)
Now Installing Lutris To Your PI 4!
$(tput sgr0)"
sleep 3

echo "deb http://download.opensuse.org/repositories/home:/strycore/Debian_10/ ./" | sudo tee /etc/apt/sources.list.d/lutris.list
wget -q https://download.opensuse.org/repositories/home:/strycore/Debian_10/Release.key -O- | sudo apt-key add -

sudo apt install -y lutris
sudo mkdir /opt/retropie/ports/lutris

mkdir /opt/retropie/configs/ports/lutris
cat <<\EOF55 > "/opt/retropie/configs/ports/lutris/emulators.cfg"
lutris = "XINIT:/opt/retropie/ports/lutris/lutris.sh"
default = "lutris"
EOF55
cp /opt/retropie/configs/ports/lxde/launching.png /opt/retropie/configs/ports/lutris/
sudo chown pi:pi /opt/retropie/ports/lutris/
cat <<\EOF88 > "/opt/retropie/ports/lutris/lutris.sh"
#!/bin/bash
xset -dpms s off s noblank
matchbox-window-manager &
lutris %U 
EOF88
sudo chmod +x /opt/retropie/ports/lutris/lutris.sh
sudo chown root:root /opt/retropie/ports/lutris
sudo chown root:root /opt/retropie/ports/lutris/*
echo
echo -e "$(tput setaf 2)
Lutris Is Now Installed On Your Desktop. Now Loading menu to Pick Retropie Location for launcher.
$(tput sgr0)"
sleep 3
pick_theme_or_ports
fi
}

pick_theme_or_ports() {
    local choice

    while true; do
       choice=$(dialog --backtitle "$BACKTITLE" --title " Pick Lutris RetroPie location " \
            --ok-label OK --cancel-label Exit \
            --menu "Pick Where To Add Lutris Launcher" 25 100 25 \
            1 "- Add Lutris to RetroPie Theme (No themes curently has lutris art)" \
            2 "- Add Lutris to RetroPie Ports" \
            2>&1 > /dev/tty)

        case "$choice" in
            1) add_lutris_to_theme ;;
            2) add_lutris_to_ports ;;
            *) break ;;
        esac
    done
}

add_lutris_to_theme() {
if [[ ! -e /home/pi/RetroPie/roms/lutris ]]; then
echo -e "$(tput setaf 2)
Now Adding Lutris To Theme. You Can Exit after it is finished.
$(tput sgr0)"
mkdir /home/pi/RetroPie/roms/lutris
cat <<\EOF99 > "/home/pi/RetroPie/roms/lutris/lutris.sh"
#!/bin/bash
/opt/retropie/supplementary/runcommand/runcommand.sh 0 _PORT_ lutris 
EOF99
sudo chmod +x /home/pi/RetroPie/roms/lutris/lutris.sh

sudo cp /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.bkp
sudo cp /etc/emulationstation/es_systems.cfg /tmp

sudo cat /tmp/es_systems.cfg |grep -v "</systemList>" > /tmp/templist.xml

ifexist=`cat /tmp/templist.xml |grep lutris |wc -l`
if [[ ${ifexist} > 0 ]]; then
  echo "lutris already in es_systems.cfg" > /tmp/exists
else
  echo "  <system>" >> /tmp/templist.xml
  echo "    <name>lutris</name>" >> /tmp/templist.xml
  echo "    <path>~/RetroPie/roms/lutris</path>" >> /tmp/templist.xml
  echo "    <extension>.sh .SH</extension>" >> /tmp/templist.xml
  echo "    <command>bash %ROM%</command>" >> /tmp/templist.xml
  echo "    <theme>lutris</theme>" >> /tmp/templist.xml
  echo "  </system>" >> /tmp/templist.xml
  echo "</systemList>" >> /tmp/templist.xml
  cp /tmp/templist.xml /opt/retropie/configs/all/emulationstation/es_systems.cfg
  sudo cp /tmp/templist.xml /opt/retropie/configs/all/emulationstation/es_systems.cfg
  sudo chown pi:pi -R /opt/retropie/configs/all/emulationstation/es_systems.cfg
fi

echo -e "$(tput setaf 2)
Done You Can Now Exit Or Add Lutris to The Ports as Well.
$(tput sgr0)"
sleep 3
else
echo -e "$(tput setaf 2)
Lutris Already Added To Theme You Can Now Exit.
$(tput sgr0)"
sleep 3
fi
}

add_lutris_to_ports() {
if [[ ! -e /home/pi/RetroPie/roms/ports/lutris ]]; then
echo -e "$(tput setaf 2)
Now Adding Lutris To Ports. You Can Exit after it is finished.
$(tput sgr0)"
sleep 3
mkdir /home/pi/RetroPie/roms/ports/lutris
cat <<\EOF99 > "/home/pi/RetroPie/roms/ports/lutris/lutris.sh"
#!/bin/bash
/opt/retropie/supplementary/runcommand/runcommand.sh 0 _PORT_ lutris 
EOF99
sudo chmod +x /home/pi/RetroPie/roms/ports/lutris/lutris.sh
echo -e "$(tput setaf 2)
Done You Can Now Exit Or Add Lutris to The Theme as Well.
$(tput sgr0)"
sleep 3
else
echo -e "$(tput setaf 2)
Lutris Already Added To Ports You Can Now Exit.
$(tput sgr0)"
sleep 3
fi
}

setup_start
