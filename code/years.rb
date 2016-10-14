#
#  Class for SB Year group records.
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_Years
  FILE_NAME = "years.csv"
  REQUIRED_COLUMNS = [
    Column["YearDesc1", :short_name,   :string],
    Column["YearIdent", :ident,        :integer],
    Column["YearDesc",  :real_nc_year, :integer],
    Column["YearName",  :long_name,    :string],
    Column["Ptype",     :ptype,        :integer],
    Column["HeadOfYear", :head,        :integer]
  ]

  include Slurper

  attr_reader :date

  def adjust(accumulator)
  end

  def wanted?
    true
  end

  def effective_isams_year
    if self.ptype == 40
      self.real_nc_year + 20
    else
      self.real_nc_year
    end
  end

  def year_to_csv(csv_file)
    csv_file << [
      self.effective_isams_year,
      self.short_name,
      self.long_name,
      self.head,
      ""
    ]
    1
  end

  #
  #  Set ourselves up and add ourselves to the accumulator.
  #
  def self.setup(accumulator)
    records, message = self.slurp(accumulator, false)
    if records
      accumulator[:years] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end

  YEARS_FILENAME = "school_structure_years.csv"

  def self.do_writing(accumulator, target_dir)
    ours = accumulator[:years]
    if ours
      written = 0
      csv = CSV.open(File.expand_path(
                       YEARS_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.year_to_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{YEARS_FILENAME}."
    end
  end

end
