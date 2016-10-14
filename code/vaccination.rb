#
#  Class for SB Vaccination records
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_Vaccination
  FILE_NAME = "vaccination.csv"
  REQUIRED_COLUMNS = [
    Column["VacIdent",       :ident,           :integer],
    Column["TreatmentIdent", :treatment_ident, :integer],
    Column["VacBatch",       :batch,           :string],
    Column["VacDate",        :date,            :date],
    Column["NurseIdent",     :nurse_ident,     :integer],
    Column["VSiteIdent",     :vacsite_ident,   :integer],
    Column["PupOrigNum",     :pupil_ident,     :integer]
  ]

  DEPENDENCIES = [
    #          Accumulator key  Record ident      Our attribute Req'd
    Dependency[:pupils,         :pupil_ident,     :pupil,       true],
    Dependency[:treatments,     :treatment_ident, :treatment,   true],
    Dependency[:nurses,         :nurse_ident,     :nurse,       false],
    Dependency[:vacsites,       :vacsite_ident,   :vacsite,     false]
  ]

  include Slurper
  include Depender


  def adjust(accumulator)
    @complete = find_dependencies(accumulator, DEPENDENCIES)
    if @complete
      @treatment.note_use
    end
  end

  def wanted?
    @complete
  end

  def notes
    #
    #  What exactly we put in the notes depends on what we have.
    #
    #  We might have:
    #    Batch info
    #    Nurse info
    #    Location info
    #
    [
      self.treatment.name,
      self.batch.empty? ? nil : "Batch: #{self.batch}",
      self.nurse && self.nurse.real_nurse? ? "By: #{self.nurse.name}" : nil,
      self.vacsite ? "Site: #{self.vacsite.name}" : nil
    ].compact.join(", ")
  end

  def vaccination_to_csv(csv_file)
    csv_file << [
      self.pupil_ident,
      self.treatment.reduced_treatment,
      self.date ? self.date.for_isams : "",
      "",
      self.notes
    ]
    1
  end

  #
  #  Set ourselves up and add ourselves to the accumulator.
  #
  def self.setup(accumulator)
    records, message = self.slurp(accumulator, false)
    if records
      accumulator[:vaccinations] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end

  VACCINATIONS_FILENAME = "sanatorium_pupil_vaccinations.csv"

  def self.do_writing(accumulator, target_dir)
    ours = accumulator[:vaccinations]
    if ours
      written = 0
      csv = CSV.open(File.expand_path(
                       VACCINATIONS_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.vaccination_to_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{VACCINATIONS_FILENAME}."
    end
  end

end
