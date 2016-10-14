#
#  Class for SB StafeOfProspect records.
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_StageOfProspect
  FILE_NAME = "stageofprospect.csv"
  REQUIRED_COLUMNS = [Column["StageOfProspect", :ident,   true],
                      Column["StageName",       :sb_name, false]]

  include Slurper

  MODIFIED_NAMES = {
    17 => "Withdrawn Before Reg",
    66 => "No offer - Review",
    67 => "Pre-test Exemption",
    68 => "Offer - Conditional",
    70 => "Offer made",
    74 => "Offer refused",
    80 => "Offer accepted",
    84 => "Waiting List Accepted",
    87 => "Offer - Deferred",
    90 => "Offer - Confirmed"
  }

  def adjust(accumulator)
  end

  def wanted?
    true
  end

  def name
    MODIFIED_NAMES[self.ident] || self.sb_name
  end

  #
  #  Set ourselves up and add ourselves to the accumulator.
  #
  def self.setup(accumulator)
    records, message = self.slurp(accumulator, false)
    if records
      accumulator[:sops] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end
end
