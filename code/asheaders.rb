#
#  Class for SB AsHeader records.
#
#  Each AsHeader record relates to one reporting cycle.
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_AsHeaders
  FILE_NAME = "asheaders.csv"
  REQUIRED_COLUMNS = [Column["AsHeaderIdent",         :ident,        true],
                      Column["AsHeaderDate",          :date_text,    false],
                      Column["AsHeaderName",          :name,         false],
                      Column["AsHeaderTitle",         :title,        false],
                      Column["AsHeaderRestrictPtype", :ptype,        true]]

  include Slurper

  attr_reader :date

  def adjust(accumulator)
    @date = Date.parse(@date_text) unless @date_text.empty?
  end

  def wanted?
    true
  end

  #
  #  We don't actually possess a type code, so try to construct
  #  one.
  #
  def type_code
    self.name.split(" ").collect {|w| w[0]}.join + "_" + self.ident.to_s
  end

  def term_name
    month = self.date.month
    if [9,10,11,12].include?(month)
      "Michaelmas"
    elsif [1,2,3,4].include?(month)
      "Lent"
    else
      "Summer"
    end
  end

  def to_csv(csv_file)
    csv_file << [self.type_code,
                 self.title,
                 "Report",
                 self.date.for_isams,
                 self.date.for_isams,
                 self.date.for_isams,
                 self.term_name]
    1
  end

  #
  #  Each session should have a unique title, but it seems that in
  #  some cases in SB they don't.  Identify those with duplicate titles
  #  and make them unique by tagging on their dates.
  #
  def self.make_titles_unique(records, check)
    hashed = Hash.new
    records.each do |record|
      if hashed[record.title]
        hashed[record.title] << record
      else
        hashed[record.title] = [record]
      end
    end
    hashed.each do |title, title_records|
      if title_records.size > 1
        if check
          puts "Title #{title} is still not unique - used #{title_records.size} times."
        else
          title_records.each_with_index do |title_record, index|
            title_record.title = "#{title_record.title} - #{title_record.date.strftime("%Y")} (#{index + 1})"
#            puts title_record.title
          end
        end
      end
    end
  end

  #
  #  Set ourselves up and add ourselves to the accumulator.
  #
  def self.setup(accumulator)
    records, message = self.slurp(accumulator, false)
    if records
      make_titles_unique(records, false)
      make_titles_unique(records, true)
      accumulator[:asheaders] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end

  CYCLES_FILENAME = "reports_and_assessments_cycles.csv"

  def self.do_writing(accumulator, target_dir)
    written = 0
    ours = accumulator[:asheaders]
    if ours
      csv = CSV.open(File.expand_path(
                       CYCLES_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.to_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{CYCLES_FILENAME}."
    end
  end
end
