require 'spec_helper'

describe 'datadog_agent' do
  context 'unsupported operating system' do
    describe 'datadog_agent class without any parameters on Solaris/Nexenta' do
      let(:facts) do
        {
          osfamily:         'Solaris',
          operatingsystem:  'Nexenta'
        }
      end

      it do
        expect {
          should contain_package('module')
        }.to raise_error(Puppet::Error, /Unsupported operatingsystem: Nexenta/)
      end
    end
  end

  # Test all supported OSes
  context 'all supported operating systems' do
    ALL_OS.each do |operatingsystem|
      describe "datadog_agent class common actions on #{operatingsystem}" do
        let(:params) { { puppet_run_reports: true } }
        let(:facts) do
          {
            operatingsystem: operatingsystem,
            osfamily: DEBIAN_OS.include?(operatingsystem) ? 'debian' : 'redhat'
          }
        end

        it { should compile.with_all_deps }

        it { should contain_class('datadog_agent') }

        describe 'datadog_agent imports the default params' do
          it { should contain_class('datadog_agent::params') }
        end

        it { should contain_file('/etc/dd-agent') }
        it { should contain_file('/etc/dd-agent/datadog.conf') }

        it { should contain_class('datadog_agent::reports') }

        describe 'paramter check' do
            context 'with defaults' do
                context 'for proxy' do
                    it { should contain_file('/etc/dd-agent/datadog.conf').with(
                    'content' => /dd_url: https:\/\/app.datadoghq.com\n/,
                    'content' => /# proxy_host:\n/,
                    'content' => /# proxy_port:\n/,
                    'content' => /# proxy_user:\n/,
                    'content' => /# proxy_password:\n/,
                )}
                end

                context 'for general' do
                    it { should contain_file('/etc/dd-agent/datadog.conf').with(
                    'content' => /api_key: 'your_API_key'\n/,
                    'content' => /# hostname:\n/,
                    'content' => /use_mount: false\n/,
                    'content' => /non_local_traffic: false\n/,
                    'content' => /^# collect_ec2_tags: no\n/,
                    'content' => /^# collect_instance_metadata: yes\n/,
                    'content' => /^# recent_point_threshold: 30\n/,
                    'content' => /^# listen_port: 17123\n/,
                    'content' => /^# graphite_listen_port: 17123\n/,
                    'content' => /^# additional_checksd: \/etc\/dd-agent\/checks.d\n/,
                    'content' => /^# use_curl_http_client: False\n/,
                    'content' => /^# device_blacklist_re: .*\\\/dev\\\/mapper\\\/lxc-box.*\n/,
                    )}
                end

                context 'for pup' do
                    it { should contain_file('/etc/dd-agent/datadog.conf').with(
                    'content' => /^# use_pup: no\n/,
                    'content' => /^# pup_port: 17125\n/,
                    'content' => /^# pup_interface: localhost\n/,
                    'content' => /^# pup_url: http:\/\/localhost:17125\n/,
                    )}
                end

                context 'for dogstatsd' do
                    it { should contain_file('/etc/dd-agent/datadog.conf').with(
                    'content' => /^# bind_host: localhost\n/,
                    'content' => /^use_dogstatsd: no\n/,
                    'content' => /^dogstatsd_port: 8125\n/,
                    'content' => /^# dogstatsd_target: http:\/\/localhost:17123\n/,
                    'content' => /^# dogstatsd_interval: 10\n/,
                    'content' => /^# dogstatsd_normalize: yes\n/,
                    'content' => /^# statsd_forward_host: address_of_own_statsd_server\n/,
                    'content' => /^# statsd_forward_port: 8125\n/,
                    )}
                end

                context 'for ganglia' do
                    it { should contain_file('/etc/dd-agent/datadog.conf').with(
                    'content' => /^#ganglia_host: localhost\n/,
                    'content' => /^#ganglia_port: 8651\n/,
                    )}
                end

                context 'for logging' do
                    it { should contain_file('/etc/dd-agent/datadog.conf').with(
                    'content' => /log_level: INFO\n/,
                    'content' => /log_to_syslog: False\n/,
                    'content' => /^# collector_log_file: \/var\/log\/datadog\/collector.log\n/,
                    'content' => /^# forwarder_log_file: \/var\/log\/datadog\/forwarder.log\n/,
                    'content' => /^# dogstatsd_log_file: \/var\/log\/datadog\/dogstatsd.log\n/,
                    'content' => /^# pup_log_file: \/var\/log\/datadog\/pup.log\n/,
                    'content' => /^# syslog_host:\n/,
                    'content' => /^# syslog_port:\n/,
                )}
                end
            end

            context 'with a custom dd_url' do
                let(:params) {{:dd_url => 'https://notaurl.datadoghq.com'}}
                it { should contain_file('/etc/dd-agent/datadog.conf').with(
                    'content' => /^dd_url: https:\/\/notaurl.datadoghq.com\n/,
                )}
            end

            context 'with a custom proxy_host' do
                let(:params) {{:proxy_host => 'localhost'}}
                it { should contain_file('/etc/dd-agent/datadog.conf').with(
                    'content' => /^proxy_host: localhost\n/,
                )}
            end

            context 'with a custom proxy_port' do
                let(:params) {{:proxy_port => '1234'}}
                it { should contain_file('/etc/dd-agent/datadog.conf').with(
                    'content' => /^proxy_port: 1234\n/,
                )}
            end

            context 'with a custom proxy_user' do
                let(:params) {{:proxy_user => 'notauser'}}
                it { should contain_file('/etc/dd-agent/datadog.conf').with(
                    'content' => /^proxy_user: notauser\n/,
                )}
            end
            context 'with a custom api_key' do
                let(:params) {{:api_key => 'notakey'}}
                it { should contain_file('/etc/dd-agent/datadog.conf').with(
                    'content' => /^api_key: notakey\n/,
                )}
            end

            context 'with a custom hostname' do
                let(:params) {{:host => 'notahost'}}

                it { should contain_file('/etc/dd-agent/datadog.conf').with(
                    'content' => /^hostname: notahost\n/,
                )}
            end
            context 'with use_mount set to true' do
                let(:params) {{:use_mount => 'true'}}
                it { should contain_file('/etc/dd-agent/datadog.conf').with(
                    'content' => /^use_mount: true\n/,
                )}
            end
            context 'with non_local_traffic set to true' do
                let(:params) {{:non_local_traffic => true}}
                it { should contain_file('/etc/dd-agent/datadog.conf').with(
                    'content' => /^non_local_traffic: true\n/,
                )}
            end
            #Should expand testing to cover changes to the case upcase 
            context 'with log level set to critical' do
                let(:params) {{:log_level => 'critical'}}
                it { should contain_file('/etc/dd-agent/datadog.conf').with(
                    'content' => /^log_level: CRITICAL\n/,
                )}
            end
            context 'with a custom hostname' do
                let(:params) {{:host => 'notahost'}}
                it { should contain_file('/etc/dd-agent/datadog.conf').with(
                    'content' => /^hostname: notahost\n/,
                )}
            end
            context 'with log_to_syslog set to false' do
                let(:params) {{:log_to_syslog => false}}
                it { should contain_file('/etc/dd-agent/datadog.conf').with(
                    'content' => /^log_to_syslog: no\n/,
                )}
            end
        end

        if DEBIAN_OS.include?(operatingsystem)
          it { should contain_class('datadog_agent::ubuntu') }
        elsif REDHAT_OS.include?(operatingsystem)
          it { should contain_class('datadog_agent::redhat') }
        end
      end
    end
  end
end
