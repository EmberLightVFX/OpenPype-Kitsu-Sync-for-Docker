# Colors for terminal

RST='\033[0m'             # Text Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

# Bold
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White

# Bold High Intensity
BIBlack='\033[1;90m'      # Black
BIRed='\033[1;91m'        # Red
BIGreen='\033[1;92m'      # Green
BIYellow='\033[1;93m'     # Yellow
BIBlue='\033[1;94m'       # Blue
BIPurple='\033[1;95m'     # Purple
BICyan='\033[1;96m'       # Cyan
BIWhite='\033[1;97m'      # White

# Main
main () {

  if [[ -z $KITSU_USERNAME ]]; then
    echo -e "${BIRed}KITSU_USERNAME not set. Please add it as an environment${RST}"
    return
  fi
  if [[ -z $KITSU_PASSWORD ]]; then
    echo -e "${BIRed}KITSU_PASSWORD not set. Please add it as an environment${RST}"
    return
  fi
  if [[ ${OPENPYPE_VERSION,,} == "latest" ]] || [[ -z $OPENPYPE_VERSION ]]; then
    echo -e "${BIYellow}Grabbing the latest version of OpenPype${RST}"
    export OPENPYPE_VERSION=$(curl --silent https://api.github.com/repos/ynput/OpenPype/releases/latest | jq -r '.tag_name')
    echo -e "${Green}$OPENPYPE_VERSION"
  fi

  cd /opt/
  export install=false
  if [ -f "openpype/openpype_console" ]; then
    echo -e "${BIGreen}OpenPype already installed${RST}"
    export string=$(openpype/openpype_console --list-versions)
    export version="${string##*version }"
    if [ "$version" != $OPENPYPE_VERSION ]; then
      echo -e "${BIYellow}The current installed version runs $version while you're requesting $OPENPYPE_VERSION.${RST}"
      echo -e "${BIYellow}Will remove the old version and download the requested version.${RST}"
      export install=true
    fi
  else
    echo -e "${BIYellow}OpenPype NOT FOUND. Installing...${RST}"
    export install=true
  fi

  if [ "$install" = true ]; then
    # Download OpenPype
    export releaseURL=https://github.com/ynput/OpenPype/releases/download/$OPENPYPE_VERSION/openpype-$OPENPYPE_VERSION-ubuntu.zip
    wget $releaseURL
    if [[ ! -f "openpype-$OPENPYPE_VERSION-ubuntu.zip" ]]; then
      echo -e "${BIRed}No file found at $releaseURL${RST}"
      echo -e "${BIRed}Please check the github repo if the release contains a ubuntu asset${RST}"
      return
    fi

    unzip openpype-$OPENPYPE_VERSION-ubuntu.zip
    # Remove any files that might exist in the op folder already
    rm -rfv openpype/*
    # Copy over all files from the unzipped folder
    cp -a openpype-$OPENPYPE_VERSION/. openpype/

    # Remove the zip and the unzipped folder
    rm -r openpype-$OPENPYPE_VERSION
    rm openpype-$OPENPYPE_VERSION-ubuntu.zip
  fi

  echo -e "${BIGreen}>>>${RST} Running OpenPype Kitsu Sync with debug verbose ..."
  echo -e "${BIGreen}>>>${RST} Installed version of OpenPype is ${BIGreen}$OPENPYPE_VERSION${RST} ..."
  openpype/openpype_console module kitsu sync-service -l $KITSU_USERNAME -p $KITSU_PASSWORD --verbose debug
}

main