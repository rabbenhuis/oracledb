# oracledb.rb

require 'rexml/document'
require 'facter'

def get_orainventory_directory
  if FileTest.exists?('/etc/oraInst.loc')
    orainst_content = File.read('/etc/oraInst.loc')
    inventory_directory = ''

    orainst_content.split(/\r?\n/).each do |line|
      if line.match(/^inventory_loc/)
        inventory_directory = line[14..-1]
      end
    end

    return inventory_directory
  else
    return 'NotFound'
  end
end

def get_oracle_database_homes(orainventory_dir)
  unless orainventory_dir.nil?
    if FileTest.exists?(orainventory_dir + '/ContentsXML/inventory.xml')
      inventory_content = File.read(orainventory_dir + '/ContentsXML/inventory.xml')
      xml_document = REXML::Document.new inventory_content
      oracle_homes = ''

      xml_document.elements.each('/INVENTORY/HOME_LIST/HOME') do |xml_element|
        location = xml_element.attributes['LOC']
        name = xml_element.attributes['NAME']

        unless location.nil?
          if name.match(/^OraDB*/)
            oracle_homes += location + ';'
          end
        end
      end

      return oracle_homes
    else
      return 'NotFound'
    end
  else
    return 'NotFound'
  end
end

def get_opatch_version(oracle_home)
  ENV['ORACLE_HOME'] = oracle_home

  opatch_version = Facter::Util::Resolution.exec(oracle_home + '/OPatch/opatch version')

  unless opatch_version.nil?
      opatch_version = opatch_version.split(' ')[2]

      Puppet.debug "ora_db - opatch version: #{opatch_version}"
      return opatch_version
  else
    return 'NotFound'
  end
end

def get_oracle_home_properties(oracle_home)
  properties = {}

  properties[:opatch_version] = get_opatch_version(oracle_home)

  return properties
end

def get_oracledb_facts
  orainventory_dir = get_orainventory_directory
  oracle_homes = get_oracle_database_homes(orainventory_dir)
  facts = {}

  facts[:orainventory_dir] = orainventory_dir
  facts[:oracle_homes] = oracle_homes

  unless oracle_homes.nil?
    oracle_homes.split(';').each do |oracle_home|
      facts[oracle_home] = get_oracle_home_properties(oracle_home)
    end
  end

  Puppet.debug "get_oracledb_facts: #{facts.inspect}"
  return facts
end

oracledb_facts = get_oracledb_facts
Facter.add(:oracledb) do
  confine :kernel => 'Linux'

  setcode do
    oracledb_facts
  end
end
