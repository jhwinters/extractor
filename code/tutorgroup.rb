#
#  Class for SB Tutorgroup records
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_TutorGroup
  FILE_NAME = "tutorgroup.csv"
  REQUIRED_COLUMNS = [
    Column["UserIdent", :ident, :integer]
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
      accumulator[:tutorgroups] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end
end
