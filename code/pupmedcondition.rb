#
#  Class for SB PupMedCondition records.
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_PupMedCondition
  FILE_NAME = "pupmedcondition.csv"
  REQUIRED_COLUMNS = [
    Column["PMCIdent",     :ident,           :integer],
    Column["PupOrigNum",   :pupil_ident,     :integer],
    Column["MedCondIdent", :condition_ident, :integer],
    Column["PMCNote",      :note,            :string]
  ]

  DEPENDENCIES = [
    #          Accumulator key  Record ident      Our attribute Req'd
    Dependency[:pupils,         :pupil_ident,     :pupil,       true],
    Dependency[:medconditions,  :condition_ident, :condition,   true]
  ]

  include Slurper
  include Depender


  def adjust(accumulator)
    @complete = find_dependencies(accumulator, DEPENDENCIES)
  end

  def wanted?
    @complete
  end

  def condition_to_csv(csv_file)
    csv_file << [
      self.pupil_ident,
      self.condition.reduced_condition,
      self.note.clean,
      "",                               # Treatment
      "",                               # Onset
      "",                               # Action
      self.condition.description,       # Further info
    ]
    1
  end

  #
  #  Set ourselves up and add ourselves to the accumulator.
  #
  def self.setup(accumulator)
    records, message = self.slurp(accumulator, false)
    if records
      accumulator[:pupmedconditions] = records.collect {|r| [r.ident, r]}.to_h
      records.each do |record|
        if record.condition.red_flag
          record.pupil.note_red_flag_condition(record)
        end
      end
      true
    else
      puts message
      false
    end
  end

  CONDITIONS_FILENAME = "sanatorium_conditions.csv"

  def self.do_writing(accumulator, target_dir)
    ours = accumulator[:pupmedconditions]
    if ours
      written = 0
      csv = CSV.open(File.expand_path(
                       CONDITIONS_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.condition_to_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{CONDITIONS_FILENAME}."
    end
  end

end
