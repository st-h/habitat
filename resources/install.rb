#
# Author:: Thom May (<thom@chef.io>)
#
# Copyright:: Copyright (c) 2016 Chef Software, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

resource_name :hab_install

property :install_url, String, default: 'https://raw.githubusercontent.com/habitat-sh/habitat/master/components/hab/install.sh'
property :bldr_url, String
property :channel, String

action :install do
  if ::File.exist?(hab_path)
    cmd = shell_out!([hab_path, '--version', '0.33.2'])
    version = %r{hab (\d*\.\d*\.\d[^\/]*)}.match(cmd.stdout)[1]
    return if version == '0.33.2'
  end

  remote_file ::File.join(Chef::Config[:file_cache_path], 'hab-install.sh') do
    source new_resource.install_url
  end

  execute 'installing with hab-install.sh' do
    command hab_command
    environment 'HAB_BLDR_URL' => new_resource.bldr_url if new_resource.bldr_url
  end
end

action :upgrade do
  remote_file ::File.join(Chef::Config[:file_cache_path], 'hab-install.sh') do
    source new_resource.install_url
  end

  execute 'installing with hab-install.sh' do
    command hab_command
    environment 'HAB_BLDR_URL' => new_resource.bldr_url if new_resource.bldr_url
  end
end

action_class do
  def hab_path
    if platform_family?('mac_os_x')
      '/usr/local/bin/hab'
    elsif platform_family?('windows')
      Chef::Log.warn 'Habitat installation on Windows is not yet supported by this cookbook.'
      Chef::Log.warn 'The installation location on Windows will probably change in the future.'
      'C:/Program Files/Habitat/hab.exe'
    else
      '/bin/hab'
    end
  end

  def hab_command
    cmd = ["bash #{Chef::Config[:file_cache_path]}/hab-install.sh", '-v 0.33.2']
    cmd.join(' ')
  end
end
