# opatch.rb
#
Puppet::Type.type(:dbs_opatch).provide(:opatch) do
  desc 'Patch the Oracle Database Software'

  def get_list_of_patches
    oracle_home = resource[:oracle_home]
    user        = resource[:os_user]
    group       = resource[:os_group]
    patches     = ''

    command = oracle_home + '/OPatch/opatch lsinventory -patch_id -oh ' + oracle_home + ' -invPtrLoc /etc/oraInst.loc'
    Puppet.debug "get_list_of_patches - command: #{command}"

    output = execute(command, { :failonfail => true, :combine => true, :uid => user, :gid => group } )
    Puppet.debug "get_list_of_patches - output: #{output}"

    if output.scan(/no Interim patches installed/).empty?
      output.each_line do |line|
        if line.match(/^Patch/) and line.match(/: applied on/)
          patch = line[5, line.index(':') - 5].strip
          patches += patch + ';'
        end
      end
    end

    Puppet.debug "get_list_of_patches - patches: #{patches}"
    return patches.split(";")
  end

  def get_patch_properties(patch_id)
    get_list_of_patches.collect do |patch|
      if patch == patch_id
        return patch
      end
    end

    return nil
  end

  def opatch(action)
    oracle_home     = resource[:oracle_home]
    user            = resource[:os_user]
    group           = resource[:os_group]
    ocmrf_file      = resource[:ocmrf_file]
    patch_id        = resource[:name]
    patch_dir       = resource[:patch_dir]
    use_opatch_auto = resource[:use_opatch_auto]

    if ocmrf_file.nil?
      ocmrf = ''
    else
      ocmrf = ' -ocmrf ' + ocmrf_file
    end

    if use_opatch_auto == true
      if action == 'apply'
        command = "#{oracle_home}/OPatch/opatch auto #{patch_dir} #{ocmrf} -oh #{oracle_home}"
      else
        command = "#{oracle_home}/OPatch/opatch auto -rollback #{patch_dir} #{ocmrf} -oh #{oracle_home}"
      end
    else
      if action == 'apply'
        command = "#{oracle_home}/OPatch/opatch apply -silent #{ocmrf} -oh #{oracle_home} #{patch_dir}"
      else
        command = "#{oracle_home}/OPatch/opatch rollback -id #{patch_id} -silent -oh #{oracle_home}"
      end
    end
    Puppet.debug "opatch - command: #{command}"

    output = execute(command, { :failonfail => true, :combine => true, :uid => user, :gid => group } )
    Puppet.debug "opatch - output: #{output}"
  end

  def exists?
    get_patch_properties(resource[:name]) != nil
  end

  def destroy
    Puppet.info("Rollback patch #{resource[:name]}")
    opatch('rollback')
  end

  def create
    Puppet.info("Apply patch #{resource[:name]}")
    opatch('apply')
  end
end
