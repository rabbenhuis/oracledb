# posix.rb
#
require 'fileutils'

Puppet::Type.type(:dbs_opatch_upgrade).provide(:opatch) do
  desc 'Upgrade the OPatch utility'

  commands :unzip => 'unzip'

  def get_current_opatch_version
    oracle_home   = resource[:oracle_home]
    patch_version = resource[:patch_version]
    user          = resource[:os_user]
    group         = resource[:os_group]

    ENV['ORACLE_HOME'] = oracle_home

    command = oracle_home + '/OPatch/opatch version | grep Version'
    Puppet.debug "get_current_opatch_version - command: #{command}"

    output = execute(command, { :failonfail => true, :combine => true, :uid => user, :gid => group } )
    Puppet.debug "get_current_opatch_version - output: #{output}"

    line_value = output.split(':')
    current_opatch_version = line_value.last.strip!
    Puppet.debug("Current OPatch version #{current_opatch_version}")

    Gem::Version.new(current_opatch_version) == Gem::Version.new(patch_version) ? (return nil) : (return current_opatch_version)
  end

  def backup_current_opatch_dir(current_opatch_version)
    oracle_home     = resource[:oracle_home]
    backup_dir_name = 'OPatch_' + "#{current_opatch_version}"

    Puppet.debug("Backup OPatch directory to #{backup_dir_name}")
    FileUtils.chdir("#{oracle_home}", :verbose => false)
    FileUtils.move('OPatch', "#{backup_dir_name}", :force => true, :verbose => false)
  end

  def extract_patch_file
    install_dir = resource[:install_dir]
    oracle_home = resource[:oracle_home]
    patch_file  = resource[:name]
    user        = resource[:os_user]
    group       = resource[:os_group]

    Puppet.debug("Extract #{patch_file}")
    FileUtils.chdir("#{install_dir}", :verbose => false)
    unzip(["#{patch_file}", '-d', "#{oracle_home}"])
    FileUtils.chdir("#{oracle_home}", :verbose => false)
    FileUtils.chown_R("#{user}", "#{group}", 'OPatch', :verbose => false)
  end

  def exists?
    get_current_opatch_version == nil
  end

  def destroy
    Puppet.info("The current OPatch utility version equals #{resource[:patch_version]}, no action needed")
  end

  def create
    current_opatch_version = get_current_opatch_version
    Puppet.info("The current OPatch utility version (#{current_opatch_version}) doesn't equal #{resource[:patch_version]}. So patching is required")
    backup_current_opatch_dir(current_opatch_version)
    extract_patch_file
  end
end

