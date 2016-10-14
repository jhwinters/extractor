#
#  Class for SB Feature records.
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_Feature
  FILE_NAME = "features.csv"
  REQUIRED_COLUMNS = [
    Column["Feature",          :name,           :string],
    Column["FeatureIdent",     :ident,          :integer],
    Column["PupCategoryIdent", :category_ident, :integer],
    Column["Archived",         :archived,       :boolean]
  ]

  DEPENDENCIES = [
    #          Accumulator key  Record ident      Our attribute Req'd
    Dependency[:pupcategories,  :category_ident,  :category,    true],
  ]

  include Slurper
  include Depender


  def adjust(accumulator)
    @complete = find_dependencies(accumulator, DEPENDENCIES, false) && !@archived
  end

  def wanted?
    @complete
  end

  LOOK_FOR = [
    /Academic/,
    /Sport/,
    /Drama/,
    /Art/,
    /Music/
  ]

  CUSTOM_FIELD_TYPES = [
    "Academic",
    "Sport",
    "Drama",
    "Art / DT",
    "Music"
  ]

  MEDICAL_FIELD_NAME = "Admissions medical"

  def an_award?
    (@category.name == "Exhibition" ||
     @category.name == "Scholarship" ||
     @category.name == "Lower school award")
  end

  def sen?
    @category.name == "SEN"
  end

  def medical?
    @category.name == "Medical"
  end

  def type_index
    LOOK_FOR.each_with_index do |lf, i|
      if lf =~ @name
        return i
      end
    end
    nil
  end

  def field_name
    if an_award?
      CUSTOM_FIELD_TYPES[type_index] + " award"
    elsif medical?
      MEDICAL_FIELD_NAME
    else
      "Surprise"
    end
  end

  def select_value_to_csv(csv)
    if an_award?
      index = type_index
      if index
        csv << [
          CUSTOM_FIELD_TYPES[index] + " award values",
          self.name
        ]
        1
      else
        0
      end
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
      accumulator[:features] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end

  def self.write_custom_field_names(accumulator, csv)
#    CUSTOM_FIELD_TYPES.each do |cft|
#      csv << [
#        cft + " award",
#        "Select",
#        cft + " award values",
#      ]
#    end
#    CUSTOM_FIELD_TYPES.size
    csv << [
      MEDICAL_FIELD_NAME,
      "TextArea",
      ""
    ]
    1
  end

  def self.write_select_values(accumulator, csv_file)
    written = 0
    ours = accumulator[:features]
    if ours
      ours.each do |key, entry|
        written += entry.select_value_to_csv(csv_file)
      end
    end
    written
  end

end
