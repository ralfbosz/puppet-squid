require 'spec_helper'

describe 'squid::extra_config_section' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      let :pre_condition do
        ' class{"::squid":
            config => "/tmp/squid.conf"
          }
        '
      end
      let(:title) { 'my config section' }

      expected_config_section  = %(# my config section\n)
      expected_config_section += %(ssl_bump server-first all\n)
      expected_config_section += %(sslcrtd_program /usr/lib64/squid/ssl_crtd -s /var/lib/ssl_db -M 4MB\n)
      expected_config_section += %(sslcrtd_children 8 startup=1 idle=1\n)
      expected_config_section += %(\n)

      context 'when config entry parameters are strings' do
        let(:params) do
          {
            config_entries: {
              'ssl_bump'         => 'server-first all',
              'sslcrtd_program'  => '/usr/lib64/squid/ssl_crtd -s /var/lib/ssl_db -M 4MB',
              'sslcrtd_children' => '8 startup=1 idle=1'
            }
          }
        end

        it { is_expected.to contain_concat_fragment('squid_extra_config_section_my config section').with_target('/tmp/squid.conf') }
        it { is_expected.to contain_concat_fragment('squid_extra_config_section_my config section').with_order('60-my config section') }
        it 'config section' do
          content = catalogue.resource('concat_fragment', 'squid_extra_config_section_my config section').send(:parameters)[:content]
          expect(content).to match(expected_config_section)
        end
      end
      context 'when config entry parameters are arrays' do
        let(:params) do
          {
            config_entries: {
              'ssl_bump'         => ['server-first', 'all'],
              'sslcrtd_program'  => ['/usr/lib64/squid/ssl_crtd', '-s', '/var/lib/ssl_db', '-M', '4MB'],
              'sslcrtd_children' => ['8', 'startup=1', 'idle=1']
            }
          }
        end

        it 'config section' do
          content = catalogue.resource('concat_fragment', 'squid_extra_config_section_my config section').send(:parameters)[:content]
          expect(content).to match(expected_config_section)
        end
      end
      let(:title) { 'my array config section' }

      expected_config_section  = %(# my array config section\n)
      expected_config_section += %(refresh_pattern ^ftp:           1440    20%     10080\n)
      expected_config_section += %(refresh_pattern ^gopher:        1440    0%      1440\n)
      expected_config_section += %(refresh_pattern -i (/cgi-bin/|\?) 0     0%      0\n)
      expected_config_section += %(refresh_pattern .               0       20%     4320\n)
      expected_config_section += %(\n)

      context 'when config entry parameters are array' do
        let(:params) do
          {
            config_entries: {
              'refresh_pattern' => [
                '^ftp:           1440    20%     10080',
                '^gopher:        1440    0%      1440',
                '-i (/cgi-bin/|\?) 0     0%      0',
                '.               0       20%     4320'
              ],
            }
          }
        end

        it { is_expected.to contain_concat_fragment('squid_extra_config_section_my config section').with_target('/tmp/squid.conf') }
        it { is_expected.to contain_concat_fragment('squid_extra_config_section_my config section').with_order('60-my config section') }
        it 'config section' do
          content = catalogue.resource('concat_fragment', 'squid_extra_config_section_my config section').send(:parameters)[:content]
          expect(content).to match(expected_config_section)
        end
      end
    end
  end
end
