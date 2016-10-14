#
#  Class for SB DayBook Type Category records
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_DayBookTypeCategory
  FILE_NAME = "dbtypecategory.csv"
  REQUIRED_COLUMNS = [
    Column["DBTCategoryIdent", :ident,        :integer],
    Column["DBTCategoryName",  :name,         :string],
    Column["DBTPointsEarned",  :earns_points, :boolean]
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
      accumulator[:dbtypecategories] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end
end
