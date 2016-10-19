#
#  Class for SB AsComment records.
#  Each AsComment record contains one textual comment from a report.
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_AsComment
  FILE_NAME = "ascomment.csv"
  REQUIRED_COLUMNS = [Column["AsCommentIdent",  :ident,         true],
                      Column["AsComment",       :comment,       false],
                      Column["AsSectionIdent",  :section_ident, true],
                      Column["AsIdent",         :as_ident,      true],
                      Column["AsGroupsIdent",   :groups_ident,  true],
                      Column["AsGPartIdent",    :gpart_ident,   true],
                      Column["AsCommentWriter", :writer_ident,  true]]

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
    end
  end

  def wanted?
    #
    #  Some comments contain an entire Word XML document (how?!)
    #  Drop them.
    #
    #  Note that this test is not entirely safe, since it would cause
    #  any comment which contained the string "<xml>" to be dropped,
    #  but it works in our case and hits the two corrupt comments.
    #
    if /<xml>/ =~ @comment
      puts "Dropping comment with ident #{@ident} for being XML."
      false
    else
      @as != nil && @as_group_part != nil && !@comment.empty?
    end
  end

  def comment_element_name
    #
    #  It seems logically for me to separate comments into Teacher
    #  comments, Tutor comments and Housemaster comments (if I can
    #  tell them apart).
    #
    self.as_group_part.header_part.get_display_name_for_comment
  end

  def to_csv(csv_file)
    csv_file << [self.as_ident,
                 self.comment_element_name,
                 self.comment]
    1
  end

  #
  #  Set ourselves up and add ourselves to the accumulator.
  #
  def self.setup(accumulator)
    records, message = self.slurp(accumulator, false)
    if records
      accumulator[:ascomments] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end

  COMMENTS_FILENAME         = "reports_and_assessments_comment.csv"

  def self.do_writing(accumulator, target_dir)
    written = 0
    ours = accumulator[:ascomments]
    if ours
      csv = CSV.open(File.expand_path(
                       COMMENTS_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.to_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{COMMENTS_FILENAME}."
    end
  end

end
