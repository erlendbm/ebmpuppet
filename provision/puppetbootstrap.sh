#!/bin/bash
# Script to find OS

# See if we have ran before
if [ -e /local/ebmpuppet/bootstrap ]; then
    exit 0
fi

if uname -a | grep SunOS >/dev/null; then
    OS="sunos_5_10"
    OSFAMILY="sunos"
elif grep -q 'Ubuntu 14.04' /etc/issue; then
    OS="trusty"
    OSFAMILY="ubuntu"
elif grep -q 'Ubuntu 12.04' /etc/issue; then
    OS="precise"
    OSFAMILY="ubuntu"
elif grep -q 'Ubuntu 10.04' /etc/issue; then
    OS="lucid"
    OSFAMILY="ubuntu"
elif grep -q 'SUSE LINUX Enterprise Server 9' /etc/issue; then
    OS="sles9"
    OSFAMILY="sles"
elif grep -q 'Red Hat Enterprise Linux Server release 7' /etc/redhat-relase; then
    OS="redhat_s_7"
    OSFAMILY="redhat"
    MAJOR=7
    MINOR=5
elif grep -q 'Red Hat Enterprise Linux Server release 6' /etc/redhat-relase; then
    OS="redhat_s_6"
    OSFAMILY="redhat"
    MAJOR=6
    MINOR=8
elif grep -q 'Red Hat Enterprise Linux Server release 5' /etc/redhat-relase; then
    OS="redhat_s_5"
    OSFAMILY="redhat"
    MAJOR=5
    MINOR=4
else
    echo "Unknown OS."
    hostname
    cat /etc/issue
    uname -a
    exit 1
fi

case $OSFAMILY in
    redhat)
         # RHEL, CentOS, Fedora
         rpm -ivh http://download.fedoraproject.org/epel/$MAJOR/x86_64/e/epel-release-$MAJOR-$MINOR.noarch.rpm
         rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-$MAJOR.noarch.rpm
         yum -y update
         yum install -y puppet facter rubygems rubygem-deep_merge \
           rubygem-puppet-lint git vim inotify-tools
         ;;
    sles)
         echo "Nothing to do here"
         exit 0
         ;;
    sunos)
         echo "Nothing to do here"
         exit 0
         ;;
    ubuntu)
         export DEBIAN_FRONTEND=noninteractive
         apt-get -y install ca-certificates
         wget https://apt.puppetlabs.com/puppetlabs-release-$OS.deb
         dpkg -i puppetlabs-release-$OS.deb
         rm -f puppetlabs-release-$OS.deb
         apt-get update && apt-get -y install puppet git ruby-puppet-lint
         ;;
    *)
         echo "Unknown OSFAMILY: $OSFAMILY"
         exit 3
         ;;
esac

gem install r10k --no-ri --no-rdoc

# file locations
rm -rf /etc/puppet/manifests
ln -sfT /local/ebmpuppet/manifests /etc/puppet/manifests
ln -sfT /local/ebmpuppet/hieradata /etc/puppet/hieradata
ln -sfT /local/ebmpuppet/hiera.yaml /etc/puppet/hiera.yaml
ln -sfT /etc/puppet/hiera.yaml /etc/hiera.yaml

# Let puppetrun.sh pick up that we are now in bootstrap mode
touch /local/ebmpuppet/bootstrap && echo "Created bootstrap marker: /local/ebmpuppet/bootstrap"

