#!/bin/bash

tred=$(tput setaf 1); tgreen=$(tput setaf 2); tyellow=$(tput setaf 3); tblue=$(tput setaf 4); tmagenta=$(tput setaf 5); tcyan=$(tput setaf 6); treset=$(tput sgr0); tclear=$(tput clear); twbg=$(tput setab 7)

function updates {
	echo -e "$tyellow""Preparing the VPS to setup. It's gonna take some time."
	apt-get update >/dev/null 2>&1
	DEBIAN_FRONTEND=noninteractive apt-get update > /dev/null 2>&1
	DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y -qq upgrade >/dev/null 2>&1
	apt install -y software-properties-common >/dev/null 2>&1
	echo -e "$tgreen""Complete"
	echo -e "$tyellow""Adding bitcoin PPA repository"
	apt-add-repository -y ppa:bitcoin/bitcoin >/dev/null 2>&1
	echo -e "$tgreen""Complete"
	echo -e "$tyellow""Installing required packages, it may take some time to finish"
	apt-get update >/dev/null 2>&1
	apt-get install libzmq3-dev -y >/dev/null 2>&1
	apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" make software-properties-common \
	build-essential libtool autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev libboost-program-options-dev \
	libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git wget curl libdb4.8-dev bsdmainutils libdb4.8++-dev \
	libminiupnpc-dev libgmp3-dev ufw pkg-config libevent-dev  libdb5.3++ unzip libzmq5 >/dev/null 2>&1
	echo -e "$tgreen""Complete"
	if [ "$?" -gt "0" ];
		then
		echo -e "$tred""Not all required packages were installed properly. Try to install them manually by running the following commands:"
		echo "apt-get update"
		echo "apt -y install software-properties-common"
		echo "apt-add-repository -y ppa:bitcoin/bitcoin"
		echo "apt-get update"
		echo "apt install -y make build-essential libtool software-properties-common autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev \
		libboost-program-options-dev libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git curl libdb4.8-dev \
		bsdmainutils libdb4.8++-dev libminiupnpc-dev libgmp3-dev ufw pkg-config libevent-dev libdb5.3++ unzip libzmq5"
	exit 1
	fi
}

function download_unpack_install {
	# grabbing the new release
	echo -e "$tyellow""Downloading WAVI Daemon"
	cd >/dev/null 2>&1
	mkdir wavi >/dev/null 2>&1
	cd wavi >/dev/null 2>&1
	wget https://github.com/wavicom/wavi/releases/download/v0.12.2.4reup/wavicore-0.12.2.4-ubuntu18.tar.gz >/dev/null 2>&1
	tar -xvf wavicore-0.12.2.4-ubuntu18.tar.gz >/dev/null 2>&1
	rm wavicore-0.12.2.4-ubuntu18.tar.gz >/dev/null 2>&1
	cd >/dev/null 2>&1
	echo -e "$tgreen""Complete"
}

function setup_initial_config {
	mkdir .wavicore >/dev/null 2>&1
	
	current_ip=$(curl -s https://v4.ifconfig.co/)
	
	cat <<- EOF > ~/.wavicore/wavi.conf
	#--------------------
	rpcuser=waviexplorer
	rpcpassword=wYRVcNX80iosRMu48NV1
	externalip=$current_ip:9983
	maxconnections=200
	#--------------------
	addnode=80.211.202.16
	addnode=81.2.254.162
	addnode=194.182.72.133
	addnode=35.237.108.220
	addnode=145.239.139.2
	addnode=149.28.37.197
	addnode=89.40.3.27
	addnode=183.250.175.209
	#--------------------
	EOF
}

function download_unpack_blockchain_database {
	echo -e "$tyellow""Downloading WAVI blockchain database"
	cd >/dev/null 2>&1
	cd .wavicore >/dev/null 2>&1
	find ! -name wavi.conf -delete
	wget http://explorer.wavicom.info/downloads/blockchain_database.tar >/dev/null 2>&1
	tar -xvf blockchain_database.tar >/dev/null 2>&1 
	rm blockchain_database.tar >/dev/null 2>&1
	cd >/dev/null 2>&1
	echo -e "$tgreen""Complete"
}

function install_sentinel {

		echo -e "$tyellow""Install WAVI Sentinel"
		sudo apt-get update >/dev/null 2>&1
		sudo apt-get -y install python-virtualenv virtualenv >/dev/null 2>&1
		git clone https://github.com/wavicom/sentinel.git >/dev/null 2>&1 
		cd sentinel >/dev/null 2>&1
		virtualenv ./venv >/dev/null 2>&1
		./venv/bin/pip install -r requirements.txt >/dev/null 2>&1
		crontab /etc/crontab
		crontab -l | { cat; echo "* * * * * cd ~/sentinel && SENTINEL_DEBUG=1 ./venv/bin/python bin/sentinel.py >> sentinel.log 2>&1" ;} | crontab -
		cd >/dev/null 2>&1
		echo -e "$tgreen""Complete"
}
clear
echo "$tgreen""Masternode Install Script for WAVI"
updates
download_unpack_install
setup_initial_config
wavi/wavid -daemon >/dev/null 2>&1
sleep 10
wavi/wavi-cli stop >/dev/null 2>&1
download_unpack_blockchain_database
install_sentinel
wavi/wavid -daemon -txindex >/dev/null 2>&1

echo -e "\n"
echo -e "WAVI setup is done.\n"
rm setup_wavi_for_explorer.sh >/dev/null 2>&1
