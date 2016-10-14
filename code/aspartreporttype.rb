#
#  Class for SB AsPartReportType records.
#
#  These specify what kind each report is - Academic, Pastoral, Other.
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_AsPartReportType
  FILE_NAME = "aspartreporttype.csv"
  REQUIRED_COLUMNS = [Column["AsPartReportTypeIdent",  :ident, true],
                      Column["AsPartReportType",       :type,  false]]

  include Slurper

  attr_reader :as_group

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
      accumulator[:aspartreporttypes] =
        records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end

end
