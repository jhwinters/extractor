#
#  Class for SB Ethnicity Records
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_Ethnicity
  FILE_NAME = "ethnicity.csv"
  REQUIRED_COLUMNS = [Column["EthIdent",  :ident,     true],
                      Column["Ethnicity", :ethnicity, false]]

  include Slurper


  def adjust(accumulator)
  end

  def wanted?
    true
  end

  #
  #  Set ourselves up and add ourselves to the accumulator.
  #
  def self.setup(accumulator)
    records, message = self.slurp(accumulator, false)
    if records
      accumulator[:ethnicities] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end
end
