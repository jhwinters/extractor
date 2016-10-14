#
#  Class for SB Language Records.
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_Language
  FILE_NAME = "language.csv"
  REQUIRED_COLUMNS = [Column["LanIdent",     :ident, true],
                      Column["Language",     :name,  false],
                      Column["LanguageCode", :code, false]]

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
      accumulator[:languages] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end
end
