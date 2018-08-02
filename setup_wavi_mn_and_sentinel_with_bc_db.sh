#!/bin/bash

tred=$(tput setaf 1); tgreen=$(tput setaf 2); tyellow=$(tput setaf 3); tblue=$(tput setaf 4); tmagenta=$(tput setaf 5); tcyan=$(tput setaf 6); treset=$(tput sgr0); tclear=$(tput clear); twbg=$(tput setab 7)

function randpw {
	< /dev/urandom tr -dc A-Za-z0-9 | head -c${1:-16};echo;
}

function updates {
	echo -e "$tyellow""Preparing the VPS to setup. It's gonna take some time."
	apt-get update
	DEBIAN_FRONTEND=noninteractive apt-get update
	DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y -qq upgrade
	apt install -y software-properties-common
	echo -e "$tgreen""Complete"
	echo -e "$tyellow""Adding bitcoin PPA repository"
	apt-add-repository -y ppa:bitcoin/bitcoin
	echo -e "$tgreen""Complete"
	echo -e "$tyellow""Installing required packages, it may take some time to finish"
	apt-get update
	apt-get install libzmq3-dev -y
	apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" make software-properties-common
	build-essential libtool autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev libboost-program-options-dev
	libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git wget curl libdb4.8-dev bsdmainutils libdb4.8++-dev
	libminiupnpc-dev libgmp3-dev ufw pkg-config libevent-dev  libdb5.3++ unzip libzmq5
	echo -e "$tgreen""Complete"
	if [ "$?" -gt "0" ];
		then
		echo -e "$tred""Not all required packages were installed properly. Try to install them manually by running the following commands:"
		echo "apt-get update"
		echo "apt -y install software-properties-common"
		echo "apt-add-repository -y ppa:bitcoin/bitcoin"
		echo "apt-get update"
		echo "apt install -y make build-essential libtool software-properties-common autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev
		libboost-program-options-dev libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git curl libdb4.8-dev
		bsdmainutils libdb4.8++-dev libminiupnpc-dev libgmp3-dev ufw pkg-config libevent-dev libdb5.3++ unzip libzmq5"
	exit 1
	fi
}

clear
echo "$tgreen""Masternode Install Script for WAVI"
updates
