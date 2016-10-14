#
#  Class for SB MedCondition records.
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_MedCondition
  FILE_NAME = "medcondition.csv"
  REQUIRED_COLUMNS = [
    Column["MedCondIdent",   :ident,       :integer],
    Column["MedCondDesc",    :description, :string]
  ]

  include Slurper

  attr_reader :reduced_condition, :red_flag

  REDUCED_CONDITIONS = {
    adhd:            "ADHD",
    anaphylaxis:     "Anaphylaxis",
    allergy:         "Allergy",
    asthma:          "Asthma",
    anxiety:         "Anxiety / Panic attacks",
    aspergers:       "Asperger's / Autism",
    cardiac:         "Cardiac condition",
    clotting:        "Clotting disorder",
    coeliac:         "Coeliac",
    concussion:      "Concussion",
    deafness:        "Deafness",
    diabetes:        "Diabetes",
    drugallergy:     "Drug allergy",
    dyspraxia:       "Dyspraxia",
    eczema:          "Eczema",
    endocrine:       "Endocrine disorder",
    enuresis:        "Enuresis",
    epilepsy:        "Epilepsy",
    eyes:            "Eye problem",
    faints:          "Faints",
    foodallergy:     "Food allergy",
    foodintolerance: "Food intolerance",
    gastro:          "Gastro intestinal",
    hayfever:        "Hay fever",
    mental:          "Mental health issues",
    migraine:        "Migraine",
    musculoskeletal: "Musculoskeletal",
    nosebleeds:      "Nose bleeds",
    pancreatitis:    "Pancreatitis",
    renal:           "Renal",
    respiratory:     "Respiratory",
    seizure:         "Seizure",
    othersb:         "Other from SB"
  }

  RED_FLAGS = {
    anaphylaxis: true,
    asthma: true,
    diabetes: true,
    epilepsy: true
  }
  RED_FLAGS.default = false

  CONDITIONS_MAPPING = {
      2 => :allergy,
      4 => :aspergers,
      5 => :asthma,
      6 => :allergy,
      7 => :allergy,
     10 => :deafness,
     11 => :diabetes,
     14 => :eczema,
     15 => :allergy,
     16 => :epilepsy,
     21 => :foodallergy,
     27 => :eyes,
     28 => :deafness,
     42 => :eyes,
     43 => :faints,
     44 => :gastro,
     46 => :hayfever,
     48 => :migraine,
     52 => :musculoskeletal,
     56 => :nosebleeds,
     59 => :respiratory,
     60 => :seizure,
     69 => :allergy,
     72 => :allergy,
     73 => :adhd,
     74 => :adhd,
     75 => :allergy,
     76 => :allergy,
     77 => :allergy,
     78 => :allergy,
     79 => :allergy,
     80 => :foodallergy,
     81 => :foodallergy,
     82 => :allergy,
     83 => :anaphylaxis,
     84 => :aspergers,
     85 => :drugallergy,
     86 => :asthma,
     87 => :asthma,
     88 => :asthma,
     90 => :eczema,
     91 => :eyes,
     92 => :foodallergy,
     94 => :coeliac,
     97 => :allergy,
    102 => :dyspraxia,
    104 => :foodallergy,
    105 => :allergy,
    109 => :epilepsy,
    110 => :foodallergy,
    115 => :hayfever,
    117 => :deafness,
    120 => :allergy,
    124 => :foodallergy,
    125 => :foodallergy,
    126 => :foodallergy,
    127 => :foodallergy,
    132 => :foodallergy,
    133 => :drugallergy,
    134 => :allergy,
    136 => :foodallergy,
    137 => :allergy,
    141 => :foodallergy,
    145 => :migraine,
    146 => :drugallergy,
    149 => :allergy,
    152 => :eyes,
    158 => :allergy,
    159 => :cardiac,
    160 => :anxiety,
    161 => :drugallergy,
    163 => :clotting,
    164 => :foodallergy,
    165 => :mental,
    166 => :foodallergy,
    167 => :aspergers,
    169 => :respiratory,
    170 => :enuresis,
    171 => :pancreatitis,
    172 => :allergy,
    173 => :concussion,
    180 => :renal
  }
  CONDITIONS_MAPPING.default = :othersb

  def adjust(accumulator)
    @reduced_condition = REDUCED_CONDITIONS[CONDITIONS_MAPPING[@ident]]
    if @reduced_condition == nil
      puts "Error - medical condition #{@ident} (#{CONDITIONS_MAPPING[@ident]}) does not map."
      @complete = false
    else
      @red_flag = RED_FLAGS[CONDITIONS_MAPPING[@ident]]
#      if @red_flag
#        puts "Red flag set for #{@reduced_condition}"
#      end
      @complete = true
    end
  end

  def wanted?
    @complete
  end

  #
  #  Set ourselves up and add ourselves to the accumulator.
  #
  def self.setup(accumulator)
    records, message = self.slurp(accumulator, false)
    if records
      accumulator[:medconditions] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end
end
