#
#  Class for SB Country Records.
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_Country
  FILE_NAME = "country.csv"
  REQUIRED_COLUMNS = [
    Column["CountryIdent", :ident, :integer],
    Column["Country",      :name,  :string]
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
      accumulator[:countries] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end
end
