#!/bin/bash

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

  if ([[ ${OPENPYPE_VERSION,,} == "latest" ]] || [[ -z $OPENPYPE_VERSION ]]) && [[ -z ${TAG_VERSION} ]]; then
    echo -e "${BIYellow}Checking what's the latest version of OpenPype is.${RST}"
    export OPENPYPE_VERSION=$(curl --silent https://api.github.com/repos/ynput/OpenPype/releases/latest | jq -r '.tag_name')

    if [[ ${OPENPYPE_VERSION,,} == "null" ]]; then
      echo -e "${BIRed}Github API rate limit exceeded. Can't check for later versions. Please try again later${RST}"
      echo -e "${BIRed}Will launch with the old version. If you want to update, please set the wanted version on ${YELLOW}OPENPYPE_VERSION${RST}"
    fi
  fi

  cd /opt/
  export install=false
  export openpype_root="/opt/openpype"
  if [ -f "openpype/openpype_console" ] || [ -f "openpype/start.py" ]; then
    echo -e "${BIGreen}OpenPype already installed${RST}"

    export version=$(grep __version__ $openpype_root/openpype/version.py | awk -F'"' '{print $2}')
    if [ "$version" != $OPENPYPE_VERSION ]; then
      echo -e "${BIYellow}The current installed version runs $version while you're requesting $OPENPYPE_VERSION.${RST}"
      echo -e "${BIYellow}The old version will be removed and your requested version will be downloaded.${RST}"
      export install=true
    fi
  else
    if [[ ${OPENPYPE_VERSION,,} == "null" ]]; then
      echo -e "${BIYellow}OpenPype NOT INSTALLED. Can't launch.${RST}"
    else
      echo -e "${BIYellow}OpenPype NOT INSTALLED. Installing...${RST}"
      export install=true
    fi
  fi

  if [ "$install" = true ]; then
    if [ -f ${TAG_VERSION} ]; then
      # Download OpenPype
      export releaseURL=https://github.com/ynput/OpenPype/releases/download/$OPENPYPE_VERSION/openpype-$OPENPYPE_VERSION-ubuntu.zip
      wget $releaseURL
      if [[ ! -f "openpype-$OPENPYPE_VERSION-ubuntu.zip" ]]; then
        echo -e "${BIRed}No file found at $releaseURL${RST}"
        echo -e "${BIRed}Please check the github repo if the release contains a ubuntu asset${RST}"
        return
      fi
      
      # Remove any files that might exist in the op folder already
      shopt -s dotglob
      rm -rf /opt/openpype/*

      unzip openpype-$OPENPYPE_VERSION-ubuntu.zip
      # Copy over all files from the unzipped folder
      cp -a openpype-$OPENPYPE_VERSION/. openpype/

      # Remove the zip and the unzipped folder
      rm -rf openpype-$OPENPYPE_VERSION
      rm openpype-$OPENPYPE_VERSION-ubuntu.zip
    else
      # Remove any files that might exist in the op folder already
      shopt -s dotglob
      rm -rf /opt/openpype/*

      # Download OpenPype from a tag
      git clone -b "$TAG_VERSION" --single-branch --depth 1 https://github.com/ynput/OpenPype openpype
      
      chmod +x /opt/openpype/tools/create_env.sh
      chmod +x /opt/openpype/tools/fetch_thirdparty_libs.sh
    
      # set local python version
      cd /opt/openpype
      source $HOME/init_pyenv.sh
      pyenv local ${OPENPYPE_PYTHON_VERSION}

      # fetch third party tools/libraries
      ./tools/create_env.sh
      ./tools/fetch_thirdparty_libs.sh
    fi
  fi

  echo -e "${BIGreen}>>>${RST} Installed version of OpenPype is ${BIGreen}$OPENPYPE_VERSION${RST} ..."
  echo -e "${BIGreen}>>>${RST} Running OpenPype Kitsu Sync with debug verbose ..."
  if [ -f ${TAG_VERSION} ]; then
    openpype/openpype_console module kitsu sync-service -l $KITSU_USERNAME -p $KITSU_PASSWORD --verbose debug --debug
  else
    # Set the OP version as $OPENPYPE_VERSION but after the last /. Eg cl/3.15.1-nightly.5 should be 3.15.1-nightly.5
    export POETRY_HOME="$openpype_root/.poetry"
    pushd "$openpype_root" > /dev/null || return > /dev/null
    
    "$POETRY_HOME/bin/poetry" run python3 -u "$openpype_root/start.py" module kitsu sync-service -l $KITSU_USERNAME -p $KITSU_PASSWORD --verbose debug --debug
  fi
}

main