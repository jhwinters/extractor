#
#  Class for SB AsGrade records.
#  Each AsGrade record contains one grade entry.
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_AsGrade
  FILE_NAME = "asgrade.csv"
  REQUIRED_COLUMNS = [Column["AsGradeIdent",   :ident,         true],
                      Column["AsGrade",        :grade,         false],
                      Column["AsSectionIdent", :section_ident, true],
                      Column["AsIdent",        :as_ident,      true],
                      Column["AsGPartIdent",   :gpart_ident,   true]]

  include Slurper

  attr_reader :as, :as_group_part

  def adjust(accumulator)
    @as = nil
    @as_group_part = nil
    as = accumulator[:as]
    as_groups = accumulator[:asgroupsparts]
    if as && as_groups
      @as = as[self.as_ident]
      @as_group_part = as_groups[self.gpart_ident]
      if @as_group_part
        @as_group_part.note_grade_value(self.grade)
      end
    end
  end

  def wanted?
    @as != nil && @as_group_part != nil
  end

  def grade_element_name
    #
    #  It seems logical for me to separate comments into Teacher
    #  comments, Tutor comments and Housemaster comments (if I can
    #  tell them apart).
    #
    self.as_group_part.get_display_name_for_grade
  end

  def to_csv(csv_file)
    if self.grade.empty?
      0
    else
      csv_file << [self.as_ident,
                   self.grade_element_name,
                   self.grade]
      1
    end
  end

  #
  #  Set ourselves up and add ourselves to the accumulator.
  #
  def self.setup(accumulator)
    records, message = self.slurp(accumulator, false)
    if records
      accumulator[:asgrades] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end

  GRADES_FILENAME         = "reports_and_assessments_grade.csv"

  def self.do_writing(accumulator, target_dir)
    written = 0
    ours = accumulator[:asgrades]
    if ours
      csv = CSV.open(File.expand_path(
                       GRADES_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.to_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{GRADES_FILENAME}."
    end
  end

end
