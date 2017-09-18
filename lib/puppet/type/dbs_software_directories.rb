# dbs_software_directories

Puppet::Type.newtype(:dbs_software_directories) do
  @doc = %q{Ensure that the Oracle Database Server software directories exist.}

  newparam(:name, :namevar => true) do
    desc 'The title'
  end

  newproperty(:ensure) do
    desc 'Ensure that the Oracle Database Server software directories are present'

    newvalue(:present) do
      provider.configure
    end

    def retrieve
      oracle_base    = resource[:oracle_base_dir]
      package_target = resource[:package_target_dir]

      if File.exist?(oracle_base) && File.exist?(package_target)
        :present
      else
        :absent
      end
    end
  end

  newparam(:oracle_base_dir) do
    desc 'Full path to the Oracle Base directory'

    validate do |value|
      if value.nil?
        fail ArgumentError, 'oracle_base_dir cannot be empty'
      end
    end
  end

  newparam(:package_target_dir) do
    desc 'Location for installation files'

    defaultto '/var/tmp/install'
  end

  newparam(:os_user) do
    desc 'The Oracle Database Server operating system user'

    defaultto 'oracle'
  end

  newparam(:os_group) do
    desc 'The Oracle Database Server operating system group'

    defaultto 'oinstall'
  end
end
