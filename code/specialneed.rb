#
#  Class for SB SpecialNeed records.
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_SpecialNeed
  FILE_NAME = "specialneeds.csv"
  REQUIRED_COLUMNS = [
    Column["SnIdent",     :ident, :integer],
    Column["SpecialNeed", :name,  :string]
  ]

  include Slurper

  REDUCED_NEEDS = {
    adhd:        "ADHD",
    asperger:    "Asperger Syndrome",
    colour:      "Colour blindness",
    dyscalculia: "Dyscalculia",
    dysgraphia:  "Dysgraphia",
    dyslexia:    "Dyslexia",
    dyspraxia:   "Dyspraxia",
    hearing:     "Hearing Impairment",
    irlen:       "Irlen Syndrome",
    none:        "None",
    nvld:        "Non-Verbal Learning Difficulty",
    visual:      "Visual Impairment"
  }

  #
  #  Note that each record in SB maps to zero or more records in iSAMS.
  #
  NEEDS_MAPPING = {
    1  => [:dyslexia],                          # Dyslexia
    2  => [:hearing],                           # Hearing impairment
    3  => [:dyspraxia],                         # Dyspraxia
    4  => [:adhd],                              # A.D.H.D
    5  => [:asperger],                          # A/S Spectrum
    6  => [:visual],                            # Visual impairment
    16 => [:asperger, :dyspraxia],              # A/S + Dyspraxia
    17 => [:dyslexia, :dyspraxia],              # Dyslexia + Dyspraxia
    19 => [:dysgraphia],                        # Dysgraphia
    20 => [:dyspraxia, :dysgraphia],            # Dyspraxia,Dysgraphia
    21 => [:asperger, :hearing, :dyspraxia],    # A/S,Hearing,Dyspraxia
    26 => [:adhd, :dyslexia, :dyspraxia],       # ADHD + Dysl + Dyspr
    28 => [:colour],                            # Colour blind
    29 => [:nvld],                              # NVLD
    30 => [:dyslexia, :dyspraxia, :asperger],   # Dysl, Dyspr, A/S
    31 => [:asperger, :dyslexia, :dyspraxia],   # A/S + Dysl + Dyspr
    32 => [:dyslexia, :adhd],                   # Dyslexia + ADHD
    33 => [:dyspraxia, :adhd],                  # Dyspraxia + ADHD
    34 => [:irlen]                              # Irlen Syndrome
  }

  def adjust(accumulator)
    @complete = true
  end

  def wanted?
    @complete
  end

  def mapped
    mapped_needs = NEEDS_MAPPING[self.ident]
    if mapped_needs
      mapped_needs.each do |mn|
        yield mn
      end
    end
  end

  def access_arrangements?
    @ident == 9
  end

  #
  #  Set ourselves up and add ourselves to the accumulator.
  #
  def self.setup(accumulator)
    records, message = self.slurp(accumulator, false)
    if records
      accumulator[:specialneeds] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end

  SEN_TYPES_FILENAME = "pupilsen_sen_types.csv"

  def self.do_writing(accumulator, target_dir)
    ours = accumulator[:specialneeds]
    if ours
      written = 0
      csv = CSV.open(File.expand_path(
                       SEN_TYPES_FILENAME,
                       target_dir),
                     "wb")
      REDUCED_NEEDS.each do |key, entry|
        csv << [
          key,
          entry
        ]
        written += 1
      end
      csv.close
      puts "Wrote #{written} records to #{SEN_TYPES_FILENAME}."
    end
  end

end
