#
#  Class for SB Treatment (vaccination type) records
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_Treatment
  FILE_NAME = "treatment.csv"
  REQUIRED_COLUMNS = [
    Column["TreatmentIdent", :ident,           :integer],
    Column["Treatment",      :name,            :string],
    Column["TreatmentCode",  :cod3,            :string]
  ]

  include Slurper

  attr_reader :used, :reduced_treatment

  REDUCED_TREATMENTS = {
    bcg:        "BCG",
    chickenpox: "Chickenpox",
    flu:        "Flu",
    hibmenc:    "Hib/Men C",
    menacwy:    "Men ACWY",
    tetanus:    "Tetanus",
    tdipv:      "Td/IPV",
    mmr1:       "MMR 1",
    mmr2:       "MMR 2",
    other:      "Other from SB"
  }

  TREATMENTS_MAPPING = {
    18 => :tetanus,
    21 => :mmr1,
    25 => :flu,
    27 => :bcg,
    33 => :tdipv,
    40 => :tdipv,
    41 => :mmr2,
    42 => :tdipv,
    48 => :tdipv,
    49 => :tdipv,
    63 => :hibmenc,
    65 => :chickenpox,
    66 => :menacwy
  }
  TREATMENTS_MAPPING.default = :other

  def adjust(accumulator)
    @reduced_treatment = REDUCED_TREATMENTS[TREATMENTS_MAPPING[@ident]]
    if @reduced_treatment == nil
      puts "Error - vaccination #{@ident} (#{TREATMENTS_MAPPING[@ident]}) does not map."
      @complete = false
    else
      @used     = false
      @complete = true
    end
  end

  def wanted?
    @complete
  end

  def note_use
    @used = true
  end

  def treatment_to_csv(csv_file)
    csv_file << [
      self.name
    ]
    1
  end

  #
  #  Set ourselves up and add ourselves to the accumulator.
  #
  def self.setup(accumulator)
    records, message = self.slurp(accumulator, false)
    if records
      accumulator[:treatments] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end

  VACCINATION_TYPES_FILENAME = "sanatorium_vaccination_types.csv"

  def self.do_writing(accumulator, target_dir)
    ours = accumulator[:treatments]
    if ours
      written = 0
      csv = CSV.open(File.expand_path(
                       VACCINATION_TYPES_FILENAME,
                       target_dir),
                     "wb")
      REDUCED_TREATMENTS.each do |key, entry|
        csv << [
          entry
        ]
        written += 1
      end
      csv.close
      puts "Wrote #{written} records to #{VACCINATION_TYPES_FILENAME}."
    end
  end

  def self.do_stats(accumulator)
    ours = accumulator[:treatments]
    puts "The following treatments are in use:"
    ours.collect {|key, record| record}.select {|r| r.used}.each do |record|
      puts "  #{record.name}"
    end
    puts "The following treatments are not in use:"
    ours.collect {|key, record| record}.select {|r| !r.used}.each do |record|
      puts "  #{record.name}"
    end
  end

end
