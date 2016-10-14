#
#  Class for SB Occupation records.
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_Occupation
  FILE_NAME = "occupations.csv"
  REQUIRED_COLUMNS = [
    Column["OccIdent",   :ident, :integer],
    Column["Occupation", :name,  :string]
  ]

  include Slurper


  def adjust(accumulator)
    @complete = true
  end

  def wanted?
    @complete
  end

  #
  #  Set ourselves up and add ourselves to the accumulator.
  #
  def self.setup(accumulator)
    records, message = self.slurp(accumulator, false)
    if records
      accumulator[:occupations] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end
end
