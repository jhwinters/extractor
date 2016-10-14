#
#  Class for SB Boarder Type Records.
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_BoarderType
  FILE_NAME = "boardertype.csv"
  REQUIRED_COLUMNS = [Column["BoarderIdent", :ident, true],
                      Column["BoarderType",  :boarder_type, false]]

  include Slurper


  def adjust(accumulator)
  end

  def wanted?
    true
  end

  ISAMS_BOARDER_TYPES = [
    nil,                # 0 - we don't have one.
    "Day",              # 1 - Day
    "Full Boarder",     # 2 - SB equivalent is Full Boarding.
    nil,                # 3 - we don't have one.
    "Weekly Boarder",   # 4 - SB equivalent is W/Boarder
    nil                 # 5 - SB equivalent is "Not known"
  ]

  #
  #  iSAMS doesn't understand the same boarder types as SB does.
  #
  def boarder_type_for_isams
    ISAMS_BOARDER_TYPES[@ident]
  end

  #
  #  Set ourselves up and add ourselves to the accumulator.
  #
  def self.setup(accumulator)
    records, message = self.slurp(accumulator, false)
    if records
      accumulator[:boardertypes] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end
end
