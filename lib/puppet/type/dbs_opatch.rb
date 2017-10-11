# dbs_opatch.rb
#
Puppet::Type.newtype(:dbs_opatch) do
  @doc = %q{Patch the Oracle Database Software}

  ensurable

  newparam(:name, :namevar => true) do
    desc 'The patch id'
  end

  newparam(:oracle_home) do
    desc 'Full path to the Oracle Home directory'

    validate do |value|
      if value.nil?
        fail ArgumentError, 'oracle_home cannot be empty'
      end
    end
  end

  newparam(:patch_dir) do
    desc 'Location off the extracted patch folder'
  end

  newparam(:ocmrf_file) do
    desc 'The full path to the ocm response file'
  end

  newparam(:use_opatch_auto) do
    desc 'Should the opatch auto command be used'

    defaultto :false
    newvalues(:true, :false)
  end

  newparam(:os_user) do
    desc 'Operating system user'

    defaultto 'oracle'
  end

  newparam(:os_group) do
    desc 'Operating system group'

    defaultto 'dba'
  end
end
