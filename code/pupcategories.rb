#
#  Class for SB PupCategory Records
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_PupCategory
  FILE_NAME = "pupcategories.csv"
  REQUIRED_COLUMNS = [
    Column["PupCategoryIdent", :ident, :integer],
    Column["PupCategory",      :name,  :string]
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
      accumulator[:pupcategories] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end
end
