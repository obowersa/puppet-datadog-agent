# Class: datadog_agent
#
# This class contains the agent installation mechanism for the Datadog module
#
# Parameters:
#   $dd_url:
#       The host of the Datadog intake server to send agent data to.
#       Defaults to https://app.datadoghq.com.
#   $host:
#       Your hostname to see in Datadog. Defaults with Datadog hostname detection.
#   $api_key:
#       Your DataDog API Key. Please replace with your key value.
#   $tags
#       Optional array of tags.
#   $puppet_run_reports
#       Will send results from your puppet agent runs back to the datadog service.
#   $puppetmaster_user
#       Will chown the api key used by the report processor to this user.
#   $non_local_traffic
#       Enable you to use the agent as a proxy. Defaults to false.
#       See https://github.com/DataDog/dd-agent/wiki/Proxy-Configuration
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# include datadog_agent
#
# OR
#
# class { 'datadog_agent':
#     api_key   => 'your key',
#     tags      => ['env:production', 'linux'],
#     puppet_run_reports  => false,
#     puppetmaster_user   => puppet,
# }
#
#
class datadog_agent(
  $dd_url = 'http://app.datadoghq.com',
  $host = '',
  $api_key = 'your_API_key',
  $tags = [],
  $puppet_run_reports = false,
  $puppetmaster_user = 'puppet',
  $non_local_traffic = false
) inherits datadog_agent::params {

  validate_string($dd_url)
  validate_string($host)
  validate_string($api_key)
  validate_array($tags)
  validate_bool($puppet_run_reports)
  validate_string($puppetmaster_user)
  validate_bool($non_local_traffic)

  include datadog_agent::params

  case $operatingsystem {
    "Ubuntu","Debian" : { include datadog_agent::ubuntu }
    "RedHat","CentOS","Fedora","Amazon","Scientific" : { include datadog_agent::redhat }
    default: { fail("Class[datadog_agent]: Unsupported operatingsystem: ${::operatingsystem}") }
  }

  file { "/etc/dd-agent":
    ensure   => present,
    owner    => "root",
    group    => "root",
    mode     => 0755,
    require  => Package["datadog-agent"],
  }

  # main agent config file
  file { "/etc/dd-agent/datadog.conf":
    ensure   => file,
    content  => template("datadog_agent/datadog.conf.erb"),
    owner    => $dd_user,
    group    => $dd_group,
    mode     => 0640,
    notify   => Service[$service_name],
    require  => File["/etc/dd-agent"],
  }

  if $puppet_run_reports {
    class { 'datadog_agent::reports':
      api_key           => $api_key,
      puppetmaster_user => $puppetmaster_user,
    }
  }

}
