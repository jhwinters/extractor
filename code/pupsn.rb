#
#  Class for SB PupSN records.
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_PupSN
  FILE_NAME = "pupsn.csv"
  REQUIRED_COLUMNS = [
    Column["PupSnIdent", :ident,       :integer],
    Column["PupOrigNum", :pupil_ident, :integer],
    Column["SnIdent",    :sn_ident,    :integer],
    Column["PupSnNote",  :note,        :string],
    Column["PupSnDate",  :date,        :date]
  ]

  DEPENDENCIES = [
    #          Accumulator key  Record ident      Our attribute Req'd
    Dependency[:pupils,         :pupil_ident,     :pupil,       true],
    Dependency[:specialneeds,   :sn_ident,        :sn,          true]
  ]

  include Slurper
  include Depender


  def adjust(accumulator)
    @complete = find_dependencies(accumulator, DEPENDENCIES)
  end

  def wanted?
    @complete
  end

  def to_csv(csv_file)
    written = 0
    self.sn.mapped do |code|
      csv_file << [
        self.pupil_ident,
        code
      ]
      written += 1
    end
    written
  end

  def access_arrangements_to_csv(csv_file)
    if self.sn.access_arrangements?
      csv_file << [
        self.pupil_ident,
        "Access Arrangements",
        self.note.clean,
        self.date.for_isams
      ]
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
      accumulator[:pupsns] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end

  SEN_PUPILS_FILENAME = "pupilsen_sen_pupils.csv"
  SEN_NOTES_FILENAME  = "pupilsen_sen_notes.csv"

  def self.do_writing(accumulator, target_dir)
    ours = accumulator[:pupsns]
    if ours
      written = 0
      csv = CSV.open(File.expand_path(
                       SEN_PUPILS_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.to_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{SEN_PUPILS_FILENAME}."
      written = 0
      csv = CSV.open(File.expand_path(
                       SEN_NOTES_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.access_arrangements_to_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{SEN_NOTES_FILENAME}."
    end
  end
end
