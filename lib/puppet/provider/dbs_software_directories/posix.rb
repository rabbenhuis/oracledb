# posix.rb

Puppet::Type.type(:dbs_software_directories).provide :posix do
  desc "Create the required Oracle Database Server software directories"

  commands :mkdir => '/usr/bin/mkdir'
  commands :chown => '/usr/bin/chown'
  commands :chmod => '/usr/bin/chmod'

  def configure
    oracle_base    = resource[:oracle_base_dir]
    package_target = resource[:package_target_dir]
    owner          = resource[:os_user]
    group          = resource[:os_group]

    Puppet.info('Configure Oracle Database Server Software directories')

    create_directory(oracle_base)
    create_directory(package_target)

    set_permissions(oracle_base, owner, group, '0775')
    set_permissions(package_target, owner, group, '0777')
  end

  def create_directory(path)
    Puppet.info "Creating directory #{path}"
    mkdir(['-p', "#{path}"])
  end

  def set_permissions(path, owner, group, mode)
    Puppet.info "Setting ownership for '#{path}' to #{owner}:#{group}"
    chown(['-R', "#{owner}:#{group}", "#{path}"])

    Puppet.info "Change file mode bits for '#{path}' to '#{mode}'"
    chmod(["#{mode}", "#{path}"])
  end
end
