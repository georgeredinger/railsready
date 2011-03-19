#!/bin/bash
#

shopt -s nocaseglob
set -e

ruby_version="1.9.2"
ruby_version_string="1.9.2p180"
ruby_source_url="ftp://ftp.ruby-lang.org//pub/ruby/1.9/ruby-1.9.2-p180.tar.gz"
ruby_source_tar_name="ruby-1.9.2-p180.tar.gz"
ruby_source_dir_name="ruby-1.9.2-p180"
script_runner=$(whoami)
railsready_path=$(cd && pwd)/railsready
log_file="$railsready_path/install.log"
distro_sig=$(cat /etc/issue)

control_c()
{
  echo -en "\n\n*** Exiting ***\n\n"
  exit 1
}

# trap keyboard interrupt (control-c)
trap control_c SIGINT

distro="ubuntu"

#now check if user is root
if [ $script_runner == "root" ] ; then
  echo -e "\nThis script must be run as a normal user with sudo privileges\n"
  exit 1
fi

# Check if the user has sudo privileges.
sudo -v >/dev/null 2>&1 || { echo $script_runner has no sudo privileges ; exit 1; }
#install ruby from source
whichRuby=1

echo -e "\n=> Creating install dir..."
cd && mkdir -p railsready/src && cd railsready && touch install.log
echo "==> done..."

echo -e "\n=> Ensuring there is a .bashrc and .bash_profile..."
touch $HOME/.bashrc && touch $HOME/.bash_profile

pm="apt-get"

echo -e "\nUsing $pm for package installation\n"

# Update the system before going any further
echo -e "\n=> Updating system (this may take awhile)..."
sudo $pm update >> $log_file 2>&1 \
 && sudo $pm -y upgrade >> $log_file 2>&1

# Install build tools
echo -e "\n=> Installing build tools..."
sudo $pm -y install \
    wget curl build-essential \
    bison openssl zlib1g \
    libxslt1.1 libssl-dev libxslt1-dev \
    libxml2 libffi-dev libyaml-dev \
    libxslt-dev autoconf libc6-dev \
    libreadline6-dev zlib1g-dev libcurl4-openssl-dev >> $log_file 2>&1
echo "==> done..."

echo -e "\n=> Installing libs needed for sqlite and mysql..."
sudo $pm -y install  libmysqlclient16-dev libmysqlclient16 >> $log_file 2>&1
echo "==> done..."

echo -e "\n=> Installing git..."
sudo $pm -y install git-core >> $log_file 2>&1
echo "==> done..."

#now that all the distro specific packages are installed lets get Ruby
  # Install Ruby
  echo -e "\n=> Downloading Ruby $ruby_version_string \n"
  cd $railsready_path/src && wget $ruby_source_url
  echo -e "\n==> done..."
  echo -e "\n=> Extracting Ruby $ruby_version_string"
  tar -xzf $ruby_source_tar_name >> $log_file 2>&1
  echo "==> done..."
  echo -e "\n=> Building Ruby $ruby_version_string (this will take awhile)..."
  cd  $ruby_source_dir_name && ./configure --prefix=/usr/local >> $log_file 2>&1 \
   && make >> $log_file 2>&1 \
    && sudo make install >> $log_file 2>&1
  echo "==> done..."

# Reload bash
echo -e "\n=> Reloading shell so ruby and rubygems are available..."
source ~/.bashrc
source ~/.bash_profile
echo "==> done..."

echo -e "\n=> Installing Bundler, Passenger and Rails.."
  sudo gem install bundler passenger rails --no-ri --no-rdoc >> $log_file 2>&1
echo "==> done..."

echo -e "\n#################################"
echo    "### Installation is complete! ###"
echo -e "#################################\n"

echo -e "\n !!! logout and back in to access Ruby or run source ~/.bash_profile !!!\n"


