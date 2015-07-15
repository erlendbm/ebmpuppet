#!/bin/bash

provision_from_puppetfile()
{
  export PUPPETFILE=/local/ebmpuppet/Puppetfile
  export PUPPETFILE_DIR=/etc/puppet/modules
  /usr/local/bin/r10k --verbose 4 puppetfile purge
  /usr/local/bin/r10k --verbose 4 puppetfile install
}

override_modules()
{
  # remove modules that exists in /local/ebmpuppet/modules
  for m in $local_ebmpuppet_modules; do
    echo "WARNING: Module $m overrides Puppetfile"
    rm -rf /etc/puppet/$(echo ${m#/local/ebmpuppet/}) 2>/dev/null
  done
}

etc_puppet_modules="$(ls -d /etc/puppet/modules/*/ 2>/dev/null)"
local_ebmpuppet_modules="$(ls -d /local/ebmpuppet/modules/*/ 2>/dev/null)"

# Source command line options as env vars
while [[ $# -gt 0 ]]; do
  case $1 in
    EBMPUPPET_*=*|FACTER_*=*)
      export $1
      shift
      ;;
    *)
      # unknown
      shift
      ;;
  esac
done

# Default value is to NOT provision from Puppetfile
# We provison Puppetfile if /etc/puppet/modules is empty, if EBMPUPPET_PUPPETFILE
# is set to 'deploy' or if puppetmodules.sh is given the 'deploy' parameter
puppetfile=false
[[ -z "$etc_puppet_modules" ]]      && puppetfile=true
[[ $EBMPUPPET_PUPPETFILE = "deploy" ]] && puppetfile=true
[[ "$puppetfile" = "true" ]] && provision_from_puppetfile

# If /local/ebmpuppet/modules contains a module deployed via rsync, use that instead
# of the one in /etc/puppet/modules
[[ -z "$local_ebmpuppet_modules" ]] || override_modules

