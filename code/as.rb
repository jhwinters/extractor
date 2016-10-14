#
#  Class for SB As records.
#  Each As record corresponds to one teacher => pupil report.  It
#  usually has attached to it two grades and a comment.
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_As
  FILE_NAME = "as.csv"
  REQUIRED_COLUMNS = [Column["AsIdent",       :ident,        true],
                      Column["AsGroupsIdent", :groups_ident, true],
                      Column["PupOrigNum",    :pupil_ident,  true]]

  include Slurper

  attr_reader :as_group

  def adjust(accumulator)
    @complete = false
    asgroups = accumulator[:asgroups]
    if asgroups
      @as_group = asgroups[self.groups_ident]
#      if @as_group
#        if @as_group.user_ident == 0
#          puts "User ident 0 for as_group #{self.groups_ident} year #{@as_group.year ? @as_group.year.effective_isams_year : "unknown" }"
#        end
#      else
#        puts "Couldn't find as_group #{self.groups_ident} for as #{@ident}"
#      end
      @complete = (@as_group != nil && @as_group.user_ident != 0)
    end
  end

  def wanted?
    @complete
  end

  def value_field
    if self.as_group.aprt.type == "Academic" ||
       self.as_group.aprt.type == "Add on"
      result = self.as_group.subject_name
    else
      result = self.as_group.tg_name
    end
    if result.empty?
      result = "Other"
    end
    result
  end

  def nc_year
    self.as_group.year.effective_isams_year
  end

  def to_csv(csv_file)
    csv_file << [self.ident,
                 self.as_group.header.type_code,
                 "Rep",
                 "Subjects Reports",
                 self.value_field,
                 "",
                 self.as_group.user_ident,
                 self.pupil_ident,
                 self.nc_year]
    1
  end

  #
  #  Set ourselves up and add ourselves to the accumulator.
  #
  def self.setup(accumulator)
    records, message = self.slurp(accumulator, false)
    if records
      accumulator[:as] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end

  REPORTS_FILENAME = "reports_and_assessments_report.csv"

  def self.do_writing(accumulator, target_dir)
    written = 0
    ours = accumulator[:as]
    if ours
      csv = CSV.open(File.expand_path(
                       REPORTS_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.to_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{REPORTS_FILENAME}."
    end
  end
end
