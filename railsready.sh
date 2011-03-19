#!/bin/bash
#
# Rails Ready
#
# Author: Josh Frye <joshfng@gmail.com>
# Licence: MIT
#
# Contributions from: Wayne E. Seguin <wayneeseguin@gmail.com>
# Contributions from: Ryan McGeary <ryan@mcgeary.org>
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

echo -e "\n\n"
echo "#################################"
echo "########## Rails Ready ##########"
echo "#################################"

distro="ubuntu"

#now check if user is root
if [ $script_runner == "root" ] ; then
  echo -e "\nThis script must be run as a normal user with sudo privileges\n"
  exit 1
fi

echo -e "\n\n"
echo "!!! This script will update your system! Run on a fresh install only !!!"
echo "run tail -f $log_file in a new terminal to watch the install"

echo -e "\n"
echo "What this script gets you:"
echo " * An updated system"
echo " * Ruby $ruby_version_string"
echo " * Imagemagick"
echo " * libs needed to run Rails (sqlite, mysql, etc)"
echo " * Bundler, Passenger, and Rails gems"
echo " * Git"

echo -e "\nThis script is always changing."
echo "Make sure you got it from https://github.com/joshfng/railsready"

# Check if the user has sudo privileges.
sudo -v >/dev/null 2>&1 || { echo $script_runner has no sudo privileges ; exit 1; }
#install ruby from source
whichRuby=1

echo -e "\n=> Creating install dir..."
cd && mkdir -p railsready/src && cd railsready && touch install.log
echo "==> done..."

echo -e "\n=> Ensuring there is a .bashrc and .bash_profile..."
touch $HOME/.bashrc && touch $HOME/.bash_profile
echo "==> done..."

echo -e "\n=> Downloading and running recipe for $distro...\n"
#Download the distro specific recipe and run it, passing along all the variables as args
wget --no-check-certificate -O $railsready_path/src/$distro.sh https://github.com/georgeredinger/railsready/raw/master/recipes/$distro.sh && cd $railsready_path/src && bash $distro.sh $ruby_version $ruby_version_string $ruby_source_url $ruby_source_tar_name $ruby_source_dir_name $whichRuby $railsready_path $log_file
echo -e "\n==> done running $distro specific commands..."

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

echo -e "\n Thanks!\n-Josh\n"

