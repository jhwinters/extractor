#
#  Class for SB FeederFeature records
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_FeederFeature
  FILE_NAME = "feederfeature.csv"
  REQUIRED_COLUMNS = [
    Column["FeederFeatureIdent", :ident, :integer],
    Column["FeederFeature",      :name,  :string]
  ]

  include Slurper

  FEATURE_TYPES = {
    1 => :agent,
    2 => :governance,
    3 => :governance,
    4 => :school_type,
    5 => :school_type,
    6 => :school_type,
    7 => :gender,
    8 => :gender,
    9 => :gender,
    10 => :not_wanted,  # Currently we ignore overseas.
    11 => :school_type,
    12 => :school_type
  }

  attr_reader :type

  def adjust(accumulator)
    @type = FEATURE_TYPES[self.ident]
    @complete = (@type != nil)
  end

  def wanted?
    @complete
  end

  def governance_to_csv(csv_file)
    if self.type == :governance
      csv_file << [
        self.ident,
        self.name
      ]
      1
    else
      0
    end
  end

  def school_type_to_csv(csv_file)
    if self.type == :school_type
      csv_file << [
        self.ident,
        self.name
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
      accumulator[:feederfeatures] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end

  GOVERNANCE_FILENAME = "other_schools_governance_type.csv"
  SCHOOL_TYPE_FILENAME = "other_schools_school_type.csv"

  def self.do_writing(accumulator, target_dir)
    ours = accumulator[:feederfeatures]
    if ours
      written = 0
      csv = CSV.open(File.expand_path(
                       GOVERNANCE_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.governance_to_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{GOVERNANCE_FILENAME}."
      written = 0
      csv = CSV.open(File.expand_path(
                       SCHOOL_TYPE_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.school_type_to_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{SCHOOL_TYPE_FILENAME}."
    end
  end

end
