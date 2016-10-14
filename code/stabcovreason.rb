#
#  Class for SB StAbCovReason records.
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_StAbCovReason
  FILE_NAME = "stabcovreason.csv"
  REQUIRED_COLUMNS = [
    Column["StAbCovReasonIdent", :ident,  :integer],
    Column["StAbCovReason",      :reason, :string]
  ]

  include Slurper


  def adjust(accumulator)
  end

  def wanted?
    true
  end

  def absence_type_to_csv(csv_file)
    csv_file << [
      self.reason
    ]
    1
  end
  #
  #  Set ourselves up and add ourselves to the accumulator.
  #
  def self.setup(accumulator)
    records, message = self.slurp(accumulator, false)
    if records
      accumulator[:stabcovreasons] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end

  ABSENCE_CODES_FILENAME = "staff_data_absence_types.csv"

  def self.do_writing(accumulator, target_dir)
    ours = accumulator[:stabcovreasons]
    if ours
      written = 0
      csv = CSV.open(File.expand_path(
                       ABSENCE_CODES_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.absence_type_to_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{ABSENCE_CODES_FILENAME}."
    end
  end

end
