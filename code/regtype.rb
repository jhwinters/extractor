#
#  Class for SB Pupil Registration Type records.
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_RegType
  FILE_NAME = "regtype.csv"
  REQUIRED_COLUMNS = [Column["RegIdent", :reg_ident, true],
                      Column["RegType",  :reg_type, false],
                      Column["RegWords", :reg_words, false]]

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
      accumulator[:regtypes] = records.collect {|r| [r.reg_ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end
end
