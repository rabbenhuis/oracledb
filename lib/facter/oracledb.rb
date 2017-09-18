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

        unless location.nil?
          oracle_homes += location + ';'
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

def get_oracledb_facts
  orainventory_dir = get_orainventory_directory
  oracle_homes = get_oracle_database_homes(orainventory_dir)
  facts = {}

  facts[:orainventory_dir] = orainventory_dir
  facts[:oracle_homes] = oracle_homes

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
