#
#  Class for SB AsGroups records.
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_AsGroups
  FILE_NAME = "asgroups.csv"
  REQUIRED_COLUMNS = [Column["AsGroupsIdent",       :ident,            true],
                      Column["AsHeaderIdent",       :header_ident,     true],
                      Column["AsPartReportType",    :part_report_type, true],
                      Column["YearIdent",           :year_ident,       true],
                      Column["UserIdent",           :user_ident,       true],
                      Column["AsGroupsName",        :tg_name,          false],
                      Column["AsGroupsSubjectName", :subject_name,     false]]

  include Slurper

  attr_reader :header, :aprt, :year

  def adjust(accumulator)
    @header = nil
    headers = accumulator[:asheaders]
    aprts   = accumulator[:aspartreporttypes]
    years   = accumulator[:years]
    if headers && aprts && years
      @header = headers[self.header_ident]
      @aprt   = aprts[self.part_report_type]
      @year   = years[self.year_ident]
      if @user_ident == 0 && @year
        #
        #  This would be much better done by using the head-of-year
        #  field from the year's records in SB, but ours are horrendously
        #  out of date.
        #
        #  There was some code here which patched in specific
        #  members of staff - excised.
        #
      end
    end
  end

  def wanted?
#    unless @header && @aprt && @year
#      puts "Dropping AsGroups #{@ident}"
#      unless @header
#        puts "  Header ident #{@header_ident}"
#      end
#      unless @aprt
#        puts "  Part report type #{@part_report_type}"
#      end
#      unless @year
#        puts "  Year ident #{@year_ident}"
#      end
#    end
    @header != nil && @aprt != nil && @year != nil
  end

  def to_csv(csv_file)
  end

  #
  #  Set ourselves up and add ourselves to the accumulator.
  #
  def self.setup(accumulator)
    records, message = self.slurp(accumulator, false)
    if records
      accumulator[:asgroups] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end

end
