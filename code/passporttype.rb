#
#  Class for SB *** FILL THIS IN *** Records.
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_PassportType
  FILE_NAME = "passporttype.csv"
  REQUIRED_COLUMNS = [Column["PassportTypeIdent", :ident, true],
                      Column["PassportType",      :name,  false]]

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
      accumulator[:passporttypes] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end
end
