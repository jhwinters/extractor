#
#  Class for SB MedCheckPup records.
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_MedCheckPup
  FILE_NAME = "medcheckpup.csv"
  REQUIRED_COLUMNS = [
    Column["MedCheckPupIdent", :ident,              :integer],
    Column["MedCheckIdent",    :medcheck_ident,     :integer],
    Column["PupOrigNum",       :pupil_ident,        :integer],
    Column["MedCheckStat",     :givenconsent_ident, :integer]
  ]

  DEPENDENCIES = [
    #          Accumulator key  Record ident      Our attribute Req'd
    Dependency[:pupils,         :pupil_ident,        :pupil,        true],
    Dependency[:medchecks,      :medcheck_ident,     :medcheck,     true],
    Dependency[:givenconsents,  :givenconsent_ident, :givenconsent, true]
  ]

  include Slurper
  include Depender


  def adjust(accumulator)
    @complete = find_dependencies(accumulator, DEPENDENCIES)
  end

  def wanted?
    @complete
  end

  def medcheck_to_csv(csv_file)
    #
    #  Store only medical consents in this file.  Others are dealt
    #  with elsewhere.
    #
    #  Currently there seems to be no way to transfer anything other than
    #  positive consent.  The others have to be dropped.
    #
    if self.medcheck.consenttype.medical &&
       self.givenconsent.consent_given?
      csv_file << [
        self.pupil_ident,
        self.medcheck.name,
        self.givenconsent.name
      ]
      1
    else
      0
    end
  end

  def custom_field_value(csv_file)
    if self.medcheck.consenttype.medical
      0
    else
      csv_file << [
        self.pupil_ident,
        self.medcheck.consented_name,
        self.givenconsent.name
      ]
      1
    end
  end

  #
  #  Set ourselves up and add ourselves to the accumulator.
  #
  def self.setup(accumulator)
    records, message = self.slurp(accumulator, false)
    if records
      accumulator[:medcheckpups] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end

  CONSENTS_FILENAME = "sanatorium_pupil_parental_consent.csv"

  def self.do_writing(accumulator, target_dir)
    ours = accumulator[:medcheckpups]
    if ours
      written = 0
      csv = CSV.open(File.expand_path(
                       CONSENTS_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.medcheck_to_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{CONSENTS_FILENAME}."
    end
  end

  def self.write_custom_field_values(accumulator, csv_file)
    written = 0
    ours = accumulator[:medcheckpups]
    if ours
      ours.each do |key, entry|
        written += entry.custom_field_value(csv_file)
      end
    end
    written
  end

end
