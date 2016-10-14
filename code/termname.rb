#
#  Class for SB TermName records.
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_TermName
  FILE_NAME = "termname.csv"
  REQUIRED_COLUMNS = [
    Column["TermNo",   :ident, :integer],
    Column["TermName", :name,  :string]
  ]

  include Slurper


  def adjust(accumulator)
    @used = false
  end

  def wanted?
    true
  end

  def get_name
    @used = true
    self.name
  end

  def termname_to_csv(csv_file)
    if @used
      csv_file << [self.name]
      1
    else
      0
    end
  end

  #
  #  Set ourselves up and add ourselves to the accumulator.
  #
  def self.setup(accumulator)
    records, message = self.slurp(accumulator, false)
    if records
      accumulator[:termnames] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end

  TERM_NAMES_FILENAME = "school_structure_terms.csv"

  def self.do_writing(accumulator, target_dir)
    ours = accumulator[:termnames]
    if ours
      written = 0
      csv = CSV.open(File.expand_path(
                       TERM_NAMES_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.termname_to_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{TERM_NAMES_FILENAME}."
    end
  end

end
