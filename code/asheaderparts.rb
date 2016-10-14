#
#  Class for SB AsHeaderParts records.
#  
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_AsHeaderParts
  FILE_NAME = "asheaderparts.csv"
  REQUIRED_COLUMNS = [Column["AsHPartIdent",        :ident,             true],
                      Column["AsHeaderIdent",       :as_header_ident,   true],
                      Column["AsHPartDisplayName",  :display_name,      false]]

  include Slurper

  attr_reader :header, :used_for_comment, :used_for_grade

  def adjust(accumulator)
    @used_for_comment = false
    @used_for_grade   = false
    @header = nil
    headers = accumulator[:asheaders]
    if headers
      @header = headers[self.as_header_ident]
    end
  end

  def wanted?
    @header != nil
  end

  def to_csv(csv_file)
  end

  def get_display_name_for_comment
    @used_for_comment = true
    self.display_name
  end

  def get_display_name_for_grade
    @used_for_grade = true
    self.display_name
  end

  #
  #  Set ourselves up and add ourselves to the accumulator.
  #
  def self.setup(accumulator)
    records, message = self.slurp(accumulator, false)
    if records
      accumulator[:asheaderparts] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end

  TEMPLATES_FILENAME = "reports_and_assessments_templates.csv"
  COMMENT_ELEMENTS_FILENAME = "reports_and_assessments_comment_elements.csv"

  def self.write_template_records(accumulator, target_dir)
    written = 0
    ours = accumulator[:asheaderparts]
    if ours
      csv = CSV.open(File.expand_path(
                       TEMPLATES_FILENAME,
                       target_dir),
                     "wb")
      csv << ["Rep", "Report"]
      csv.close
      puts "Wrote 1 record to #{TEMPLATES_FILENAME}."
    end
  end

  def self.write_comment_element_records(accumulator, target_dir)
    written = 0
    ours = accumulator[:asheaderparts]
    if ours
      csv = CSV.open(File.expand_path(
                       COMMENT_ELEMENTS_FILENAME,
                       target_dir),
                     "wb")
      ours.collect {|key, entry| entry}.
           select {|entry| entry.used_for_comment}.
           collect {|entry| entry.display_name}.uniq.each do |dn|
        csv << [dn, "Rep"]
        written += 1
      end
      csv.close
      puts "Wrote #{written} records to #{COMMENT_ELEMENTS_FILENAME}."
    end
  end

  def self.do_writing(accumulator, target_dir)
    write_template_records(accumulator, target_dir)
    write_comment_element_records(accumulator, target_dir)
  end

end
