# current_opatch_version
#
# Get the current OPatch version for the given Oracle Home
#

require 'puppet/util/log'

Puppet::Functions.create_function(:'oracledb::current_opatch_version') do
  dispatch :opatch_version do
    param 'String', :oracle_home
  end

  def opatch_version(oracle_home)
    oracle_home = oracle_home.strip.downcase
    log "Stripped oracle home #{oracle_home}"

    scope = closure_scope
    current_opatch_version = scope['facts']['oracledb']["#{oracle_home}"]['opatch_version']

    if current_opatch_version =='NotFound' or current_opatch_version.nil?
      log "No current opatch version found. Return NotFound"
      return 'NotFound'
    else
      log "Found OPatch version: #{current_opatch_version}"
      return current_opatch_version
    end

    log "End of function current_opatch_version. Return NotFound"
    return 'NotFound'
  end

  def log(msg)
    Puppet::Util::Log.create(
      :level   => :info,
      :message => msg,
      :source  => 'oracledb::opatch_version'
    )
  end
end
