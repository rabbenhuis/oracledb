# oracle_home_exists.rb
#
# Check if the Oracle Home alredy exists.
#
# @param oracle_home the full path of the oracle home directory.
# @return [Boolean] Return if it exists or not.

require 'puppet/util/log'

Puppet::Functions.create_function(:'oracledb::oracle_home_exists') do
  dispatch :home_exists do
    param 'String', :oracle_home
  end

  def home_exists(oracle_home)
    oracle_home = oracle_home.strip
    log "Oracle Home to check #{oracle_home}"

    # Get the oracledb::oracle_homes fact
    scope = closure_scope
    oracle_homes = scope['facts']['oracledb']['oracle_homes']
    log "The following Oracle Homes are found #{oracle_homes}"

    if oracle_homes == 'NotFound' or oracle_homes.nil?
      return false
    else
      log "Search for #{oracle_home} in #{oracle_homes}"
      if oracle_homes.include? oracle_home
        return true
      end
    end

    log "End of function, return false"
    return false
  end

  def log(msg)
    Puppet::Util::Log.create(
      :level   => :info,
      :message => msg,
      :source  => 'oracledb::oracle_home_exists'
    )
  end
end
