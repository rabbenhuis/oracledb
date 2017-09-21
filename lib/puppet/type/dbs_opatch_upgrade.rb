# dbs_opatch_upgrade
#
Puppet::Type.newtype(:dbs_opatch_upgrade) do
  @doc = %q{Upgrade the Oracle Database Server OPatch utility.}

  ensurable

  newparam(:name, :namevar => true) do
    desc 'The title'
  end

  newparam(:oracle_home) do
    desc 'Full path to the Oracle Home directory'

    validate do |value|
      if value.nil?
        fail ArgumentError, 'oracle_home cannot be empty'
      end
    end
  end

  newparam(:install_dir) do
    desc 'Location for the patch file'

    defaultto '/var/tmp/install'
  end

  newparam(:patch_version) do
    desc 'opatch version of the opatch upgrade file'

    newvalues(/\d+\.\d+\.\d+\.\d+\.\d+/)
  end

  newparam(:os_user) do
    desc 'Operating system user'

    defaultto 'oracle'
  end

  newparam(:os_group) do
    desc 'Operating system group'

    defaultto 'oinstall'
  end
end
