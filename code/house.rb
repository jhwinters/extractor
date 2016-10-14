#
#  Class for SB House Records.
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_House
  FILE_NAME = "house.csv"
  REQUIRED_COLUMNS = [
    Column["HouseIdent", :ident, :integer],
    Column["HouseName",  :name,  :string],
    Column["UserIdent",  :head,  :integer]
  ]

  include Slurper


  def adjust(accumulator)
  end

  def wanted?
    true
  end

  def code
    self.name[0..2]
  end

  def house_to_csv(csv_file)
    csv_file << [
      self.code,
      self.name,
      "Academic",
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
      accumulator[:houses] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end

  HOUSES_FILENAME = "school_structure_houses.csv"

  def self.do_writing(accumulator, target_dir)
    ours = accumulator[:houses]
    if ours
      written = 0
      csv = CSV.open(File.expand_path(
                       HOUSES_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.house_to_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{HOUSES_FILENAME}."
    end
  end

end
