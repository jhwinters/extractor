#
#  Class for SB ConsentType records.
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_ConsentType
  FILE_NAME = "consenttypes.csv"
  REQUIRED_COLUMNS = [
    Column["ConsentID",      :ident,       :integer],
    Column["ConsentName",    :name,        :string],
    Column["ConsentDesc",    :description, :string]
  ]

  include Slurper


  attr_reader :medical

  def adjust(accumulator)
    if self.name == "Medical"
      @medical = true
    else
      @medical = false
    end
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
      accumulator[:consenttypes] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end

end
