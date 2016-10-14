#
#  Class for SB AsGroupsParts records
#  
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_AsGroupParts
  FILE_NAME = "asgroupsparts.csv"
  REQUIRED_COLUMNS = [Column["AsGPartIdent",        :ident,             true],
                      Column["AsGroupsIdent",       :as_group_ident,    true],
                      Column["AsGPartDisplayName",  :display_name,      false],
                      Column["AsHeaderPartIdent",   :header_part_ident, true]]

  include Slurper

  attr_reader :header_part, :as_group, :used_for_grade, :grade_values

  def adjust(accumulator)
    @used_for_grade = false
    @grade_values = Array.new
    @header_part = nil
    @as_group    = nil
    header_parts = accumulator[:asheaderparts]
    as_groups    = accumulator[:asgroups]
    if header_parts && as_groups
      @header_part = header_parts[self.header_part_ident]
      @as_group    = as_groups[self.as_group_ident]
    end
  end

  def wanted?
    @header_part != nil && @as_group != nil && @display_name != "Mock %"
  end

  def get_display_name_for_grade
    @used_for_grade = true
    self.display_name
  end

  def note_grade_value(grade)
#    puts "Noting grade value #{grade} for #{self.display_name}."
    unless @grade_values.include?(grade)
      @grade_values << grade
    end
  end

  #
  #  Set ourselves up and add ourselves to the accumulator.
  #
  def self.setup(accumulator)
    records, message = self.slurp(accumulator, false)
    if records
      accumulator[:asgroupsparts] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end

  def self.group_grade_values_by_display_name(ours)
    hashed = Hash.new
    ours.each do |key, asgrouppart|
      if hashed[asgrouppart.display_name]
        hashed[asgrouppart.display_name] << asgrouppart
      else
        hashed[asgrouppart.display_name] = [asgrouppart]
      end
    end
    hashed.each do |display_name, asgroupparts|
      grade_values =
        asgroupparts.collect {|asgp| asgp.grade_values}.flatten.uniq
      grade_values.each do |gv|
        unless gv.empty?
          yield display_name, gv
        end
      end
    end
  end

  GRADE_ELEMENTS_FILENAME = "reports_and_assessments_grade_elements.csv"
  GRADE_ELEMENT_VALUES_FILENAME = "reports_and_assessments_grade_element_values.csv"

  def self.do_writing(accumulator, target_dir)
    written = 0
    ours = accumulator[:asgroupsparts]
    if ours
      csv = CSV.open(File.expand_path(
                       GRADE_ELEMENTS_FILENAME,
                       target_dir),
                     "wb")
      ours.collect {|key, entry| entry}.
           select {|entry| entry.used_for_grade}.
           collect {|entry| entry.display_name}.uniq.each do |dn|
        csv << [dn, "Rep"]
        written += 1
      end
      csv.close
      puts "Wrote #{written} records to #{GRADE_ELEMENTS_FILENAME}."
      written = 0
      csv = CSV.open(File.expand_path(
                       GRADE_ELEMENT_VALUES_FILENAME,
                       target_dir),
                     "wb")
      group_grade_values_by_display_name(ours) do |display_name, value|
        csv << [value, display_name, "No"]
        written += 1
      end
      if false
      csv << ["O", "Effort", "No"]
      csv << ["V", "Effort", "No"]
      csv << ["G", "Effort", "No"]
      csv << ["C", "Effort", "No"]
      csv << ["P", "Effort", "No"]
      csv << ["A", "Effort", "No"]
      csv << ["B", "Effort", "No"]
      csv << ["C", "Effort", "No"]
      csv << ["D", "Effort", "No"]
      csv << ["E", "Effort", "No"]
      csv << ["1", "Achievement", "No"]
      csv << ["2", "Achievement", "No"]
      csv << ["3", "Achievement", "No"]
      csv << ["4", "Achievement", "No"]
      csv << ["5", "Achievement", "No"]
      written += 10
      end
      csv.close
      puts "Wrote #{written} records to #{GRADE_ELEMENT_VALUES_FILENAME}."
    end
  end

end
