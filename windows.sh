#!/bin/bash
#
# Windows provisioner for Trellis
# heavily modified and based on KSid/windows-vagrant-ansible
# @author Andrea Brandi
# @version 1.0

ANSIBLE_PATH="$(find /vagrant -name 'windows.sh' -printf '%h' -quit)"
export PYTHONUNBUFFERED=1

# Create an ssh key if not already created.
if [ ! -f ~/.ssh/id_rsa ]; then
  echo -e "\n\n\n" | ssh-keygen -t rsa
fi

# Check SSH forwarding agent
echo '
printf "\033[1;33m"
if ! ssh-add -l >/dev/null; then
    printf "See: https://roots.io/trellis/docs/windows/#ssh-forwarding"
fi
printf "\033[0m\n\n"
' >> /home/vagrant/.profile

# Check that add-apt-repository is installed for non-standard Vagrant boxes
if [ ! -f /usr/bin/add-apt-repository ]; then
  sudo apt-get -y update
  echo "Adding add-apt-repository..."
  sudo apt-get -y install software-properties-common
fi

# Install Ansible and its dependencies if not installed.
if [ ! -f /usr/bin/ansible ]; then
  # echo "Adding Ansible repository..."
  # sudo apt-add-repository -y ppa:ansible/ansible
  # echo "Updating system..."
  # sudo apt-get -y update
  # echo "Installing Ansible..."
  # sudo apt-get -y install ansible
  echo "Installing pip..."
  sudo apt-get -y install python-pip
  echo "Installing Ansible with pip..."
  sudo pip install ansible=='2.0.2.0'
  echo "Installing markupsafe with pip..."
  sudo pip install markupsafe
  echo "Installing dopy with pip..."
  # current version is 0.3.7
  sudo pip install dopy 
  # sudo pip install 'dopy>=0.3.5,<=0.3.5'
fi

if [ ! -d ${ANSIBLE_PATH}/vendor ]; then
  echo "Running Ansible Galaxy install"
  ansible-galaxy install -r ${ANSIBLE_PATH}/requirements.yml -p ${ANSIBLE_PATH}/vendor/roles
fi

echo "Running Ansible Playbooks"
cd ${ANSIBLE_PATH}/
ansible-playbook dev.yml -e vagrant_version=$1
