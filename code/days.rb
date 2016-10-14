#
#  Class for SB Pupil Registration records.
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_Days
  FILE_NAME = "days.csv"
  REQUIRED_COLUMNS = [Column["Days",      :date_text,  false],
                      Column["DateIdent", :date_ident, true]] 

  include Slurper

  attr_reader :date

  def adjust(accumulator)
    @date = Date.parse(@date_text) unless @date_text.empty?
  end

  def wanted?
    !!@date
  end

  #
  #  Set ourselves up and add ourselves to the accumulator.
  #
  def self.setup(accumulator)
    records, message = self.slurp(accumulator, false)
    if records
      accumulator[:days] = records.collect {|r| [r.date_ident, r]}.to_h
#      our_hash = Hash.new
#      records.each
#      accumulator[:days] = records
      true
    else
      puts message
      false
    end
  end
end
