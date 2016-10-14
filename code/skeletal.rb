#
#  Class for SB *** FILL THIS IN *** Records.
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_*** FILL THIS IN ***
  FILE_NAME = "*** FILL THIS IN ***.csv"
  REQUIRED_COLUMNS = [
    Column["*** FILL THIS IN ***", :ident, :integer]
  ]

  DEPENDENCIES = [
    #          Accumulator key  Record ident      Our attribute Req'd
    Dependency[:whatever,       :pupil_ident,     :pupil,       true],
  ]

  include Slurper
  include Depender


  def adjust(accumulator)
    @complete = find_dependencies(accumulator, DEPENDENCIES)
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
      accumulator[:*** FILL THIS IN ***] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end
end
