#
#  Class for SB NurseAll records.
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_NurseAll
  FILE_NAME = "nurseall.csv"
  REQUIRED_COLUMNS = [
    Column["NurseIdent", :ident, :integer],
    Column["Nurse",      :name,  :string]
  ]

  include Slurper

  def adjust(accumulator)
    @complete = true
  end

  def wanted?
    @complete
  end

  def real_nurse?
    #
    #  There are some dummy records which came in from SB.
    #
    self.ident != 27
  end

  #
  #  Set ourselves up and add ourselves to the accumulator.
  #
  def self.setup(accumulator)
    records, message = self.slurp(accumulator, false)
    if records
      accumulator[:nurses] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end
end
