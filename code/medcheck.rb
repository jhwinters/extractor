#
#  Class for SB MedCheck (types of medication for consents) records.
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_MedCheck
  FILE_NAME = "medcheck.csv"
  REQUIRED_COLUMNS = [
    Column["MedCheckIdent",  :ident,             :integer],
    Column["MedCheck",       :name,              :string],
    Column["ConsentTypeID",  :consenttype_ident, :integer]
  ]

  DEPENDENCIES = [
    #          Accumulator key  Record ident        Our attribute Req'd
    Dependency[:consenttypes,   :consenttype_ident, :consenttype, true]
  ]

  include Slurper
  include Depender


  def adjust(accumulator)
    @complete = find_dependencies(accumulator, DEPENDENCIES)
    @name = @name.capitalize
  end

  def wanted?
    @complete
  end

  def consented_name
#    if /consent\Z/ =~ self.name
#      self.name
#    else
#      self.name.strip + " consent"
#    end
    self.name
  end

  def write_custom_field_name(csv_file)
    if self.consenttype.medical
      0
    else
      csv_file << [
        consented_name,
        "Select",
        "Consent type"
      ]
      1
    end
  end

  def write_medical_consent_type(csv_file)
    if self.consenttype.medical
      csv_file << [
        consented_name,
      ]
      1
    else
      0
    end
  end

  MEDICAL_CONSENT_TYPES_FILENAME = "sanatorium_parental_consent_types.csv"

  #
  #  Set ourselves up and add ourselves to the accumulator.
  #
  def self.setup(accumulator)
    records, message = self.slurp(accumulator, false)
    if records
      accumulator[:medchecks] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end

  def self.do_writing(accumulator, target_dir)
    written = 0
    ours = accumulator[:medchecks]
    if ours
      csv = CSV.open(File.expand_path(
                       MEDICAL_CONSENT_TYPES_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.write_medical_consent_type(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{MEDICAL_CONSENT_TYPES_FILENAME}."
    end
  end

  def self.write_custom_fields(accumulator, csv_file)
    written = 0
    ours = accumulator[:medchecks]
    if ours
      ours.each do |key, entry|
        written += entry.write_custom_field_name(csv_file)
      end
    end
    written
  end

end
