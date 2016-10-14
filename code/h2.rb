#
#  Class for SB H2 (Markeing) records.
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_H2Record
  FILE_NAME = "h2.csv"
  REQUIRED_COLUMNS = [
    Column["H1Auto",   :ident, true],
    Column["H2Reason", :text,  false]
  ]

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
      accumulator[:h2s] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end
end
