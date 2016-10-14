#
#  Class for SB Pupil Feature records.
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_PupilFeature
  FILE_NAME = "pupilfeatures.csv"
  REQUIRED_COLUMNS = [
    Column["OrigNumber",        :pupil_ident,   :integer],
    Column["Note",              :note,          :string],
    Column["FeatureDate",       :date,          :date],
    Column["FeatureIdent",      :feature_ident, :integer],
    Column["PupilFeatureIdent", :ident,         :integer]
  ]

  DEPENDENCIES = [
    #          Accumulator key  Record ident      Our attribute Req'd
    Dependency[:pupils,         :pupil_ident,     :pupil,       true],
    Dependency[:features,       :feature_ident,   :feature,     true]
  ]

  include Slurper
  include Depender


  def adjust(accumulator)
#    puts "Adjusting pupilfeature for #{@pupil_ident}."
    @complete = find_dependencies(accumulator, DEPENDENCIES, false)
#    puts "@complete = #{@complete}"
  end

  def wanted?
    @complete
  end

  def write_custom_field_value(csv)
#    if @feature.an_award?
#      csv << [
#        @pupil_ident,
#        @feature.field_name,
#        @feature.name
#      ]
#      1
    if @feature.medical?
      csv << [
        @pupil_ident,
        @feature.field_name,
        @note.clean
      ]
      1
    else
      0
    end
  end

  def scholarship_to_csv(csv)
    if @feature.an_award?
      csv << [
        @pupil_ident,
        @feature.name,
        "Award",
        @note,
        @date.for_isams,
        nil,
        nil,
        nil,
        nil
      ]
      1
    else
      0
    end
  end

  def sen_to_csv(csv)
    if @feature.sen?
      csv << [
        @pupil_ident,
        "Yes",
        nil,
        @note.clean
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
      accumulator[:pupilfeatures] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end

  def self.write_custom_field_values(accumulator, csv_file)
    written = 0
    ours = accumulator[:pupilfeatures]
    if ours
      ours.each do |key, record|
        written += record.write_custom_field_value(csv_file)
      end
    end
    written
  end

  ADMISSIONS_SCHOLARSHIPS_FILENAME = "admissions_scholarships.csv"
  SEN_REGISTER_FILENAME = "pupilsen_sen_register.csv"

  def self.do_writing(accumulator, target_dir)
    ours = accumulator[:pupilfeatures]
    if ours
      #
      #  Scholarships and exhibitions.
      #
      written = 0
      csv = CSV.open(File.expand_path(
                       ADMISSIONS_SCHOLARSHIPS_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.scholarship_to_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{ADMISSIONS_SCHOLARSHIPS_FILENAME}."
      #
      #  SEN
      #
      written = 0
      csv = CSV.open(File.expand_path(
                       SEN_REGISTER_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.sen_to_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{SEN_REGISTER_FILENAME}."
    end
  end

end
