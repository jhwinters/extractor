#
#  Class for SB VacSite Records.
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_VacSite
  FILE_NAME = "vacsite.csv"
  REQUIRED_COLUMNS = [
    Column["VSiteIdent", :ident, :integer],
    Column["VSiteSite",  :name,  :string]
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
      accumulator[:vacsites] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end
end
