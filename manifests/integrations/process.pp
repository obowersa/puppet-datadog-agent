# Class: datadog_agent::integrations::process
#
# This class will install the necessary configuration for the process integration
#
# Parameters:
#   $processes:
#       Array of process hashes. See example
#
# Sample Usage:
#
# class { 'datadog_agent::integrations::process':
#     processes   => [
#         {
#             'name'          => 'puppetmaster',
#             'search_string' => ['puppet master'],
#             'exact_match'   => false,
#         },
#         {
#             'name'          => 'sshd',
#             'search_string' => ['/usr/sbin/sshd'],
#             'exact_match'   => true,
#         },
#     ],
# }

#
#
class datadog_agent::integrations::process(
  $processes = [],
) inherits datadog_agent::params {

  validate_array( $processes )

  package { $process_int_package :
    ensure => installed,
  }

  file { "${conf_dir}/process.yaml":
    ensure  => file,
    owner   => $datadog_agent::dd_user,
    group   => $datadog_agent::dd_group,
    mode    => 0600,
    content => template('datadog_agent/agent-conf.d/process.yaml.erb'),
    require => Package[$process_int_package],
    notify  => Service[$service_name]
  }
}
