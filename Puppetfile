#
# git repo base URIs
#
github = 'https://github.com/'

#
# profile
#
mod 'profile', :ref => 'norcams-0.5.9',          :git => github + 'norcams/puppeels'

#
# profile::base::common
#
mod 'ntp', :ref => '3.3.0',                      :git => github + 'puppetlabs/puppetlabs-ntp'

#
# profile::webserver::apache
#
mod 'puppetlabs/apache', '1.2.0'                 # forge

#
# profile::application::foreman
#
mod 'theforeman/concat_native', '1.3.1'          # forge
mod 'theforeman/puppet', :ref => '4cc662969',    :git => github + 'theforeman/puppet-puppet.git'

#
# Common libs
#
mod 'stdlib', :ref => '4.6.0',                   :git => github + 'puppetlabs/puppetlabs-stdlib'
mod 'concat', :ref => '1.1.2',                   :git => github + 'puppetlabs/puppetlabs-concat'
