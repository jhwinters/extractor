#
#  Class for SB Day Book Type records
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_DayBookType
  FILE_NAME = "dbtype.csv"
  REQUIRED_COLUMNS = [
    Column["DBTypeIdent",      :ident,           :integer],
    Column["DBType",           :name,            :string],
    Column["DtTypePositive",   :positive,        :integer],
    Column["DBTCategoryIdent", :category_ident,  :integer],
    Column["DBWeightingValue", :weighting_value, :integer]
  ]

  DEPENDENCIES = [
    #          Accumulator key    Record ident     Our attribute   Req'd
    Dependency[:dbtypecategories, :category_ident, :category,      true]
  ]

  include Slurper
  include Depender

  attr_reader :isams_type

  RS_Type = Struct.new(:id, :plural_name, :singular_name, :positive)
  RS_TYPES = {
    "RP" => RS_Type.new("RP", "Record APS Rewards",      "APS Reward", true),
    "SP" => RS_Type.new("SP", "Record APS Consequences", "APS Consequence", false),
    "RS" => RS_Type.new("RS", "(S) Rewards",   "(S) Reward", true),
    "SS" => RS_Type.new("SS", "(S) Sanctions", "(S) Sanction", false),
    "SA" => RS_Type.new("SA", "Archived",      "Archived", false)
  }
  #
  #  Table to put individual SB Daybook types into iSAMS types.
  #  "NW" is a filler value meaning "Not wanted".
  #
  SB_Types = [
    "NW",                       # 0 - does not exist.
    #
    #  These next few are events rather than rewards or sanctions.
    #  They don't map across.
    #
    "NW",                       # 1 - late arrival.
    "NW",                       # 2 - Excellent work.
    "NW",                       # 3 - No prep.
    "NW",                       # 4 - Good work.
    "NW",                       # 5 - General concern.
    "NW",                       # 6 - Disruptive behaviour.
    "NW",                       # 7 - Missing equipment.
    #
    #  Now we get to the useful stuff.
    #
    "SA",                       # 8 - Detention.
    "NW",                       # 9 - Merit.
    "RS",                       # 10 - Commendation.
    "SA",                       # 11 - Copy
    "SA",                       # 12 - Friday detention.
    "SS",                       # 13 - Head's detention.
    "RS",                       # 14 - Head's praise.
    "RS",                       # 15 - Housemaster's praise.
    "SA",                       # 16 - Lower school detention.
    "SS",                       # 17 - Other sanction.
    "RS",                       # 18 - Other reward.
    "SS",                       # 19 - Prep detention.
    "SA",                       # 20 - Wednesday detention.
    "SS",                       # 21 - Missed prep detention.
    "SS",                       # 22 - Missed Friday detention.
    "NW",                       # 23 - Prep School merits.
    "SP",                       # 24 - Prep School sanctions.
    "RP",                       # 25 - Prep School gold.
    "RP",                       # 26 - Prep bronze cert.
    "RP",                       # 27 - Prep silver cert.
    "RP",                       # 28 - Prep gold cert.
    "SS",                       # 29 - Exclusion.
    "SS",                       # 30 - Temporary exclusion.
    "SS",                       # 31 - 1 hour Friday detention.
    "SS",                       # 32 - 2 hour Friday detention.
    "RS",                       # 33 - HoD's praise.
    "RS",                       # 34 - Middle master's praise.
    "RS",                       # 35 - Upper master's praise.
    "SS",                       # 36 - Housemaster's summons.
  ]

  def adjust(accumulator)
    @name = @name.chomp(".")
    @complete = find_dependencies(accumulator, DEPENDENCIES)
    if @complete
      #
      #  Try to map to an iSAMS type.
      #
      @complete = false
      entry = SB_Types[self.ident]
      if entry
        @isams_type = RS_TYPES[entry]
        if @isams_type
          @complete = true
        end
      end
    end
  end

  def wanted?
    @complete
  end

  #
  #  These two are a bit messy.
  #
  DONT_PLURALIZE = [
    /Work\Z/,
    /Behaviour\Z/,
    /Equipment\Z/
  ]

  def can_pluralize?(string)
    DONT_PLURALIZE.each do |regex|
      if regex =~ string
        return false
      end
    end
    true
  end

  def plural_name
    if /Summons\Z/ =~ self.name
      "#{self.name}es"
    elsif /Copy\Z/ =~ self.name
      "Copies"
    elsif /s\Z/ =~ self.name
      self.name
    elsif can_pluralize?(self.name)
      "#{self.name}s"
    else
      self.name
    end
  end

  def singular_name
    if /Summons\Z/ =~ self.name
      "#{self.name}"
    elsif /s\Z/ =~ self.name
      self.name.chomp("s")
    else
      self.name
    end
  end

  #
  #  There's an error in iSAMS's data structures here.  What they call
  #  "Category" they really regard as a reason, and as such it shouldn't
  #  come between the types and the actual incident records - it should
  #  be in parallel.  However they've put it between, and therefore one
  #  of these records needs to exist for each of the type records because
  #  otherwise the data can't be connected up.
  #
  #  Correction: Although all the examples which iSAMS gives are reasons
  #  this field is in fact intended for the category of reward or sanction.
  #  It's the examples which are wrong - not the name of the field.
  #
  def category_to_csv(csv_file)
    csv_file << [
      self.ident,
      self.name,
      self.name,
      self.isams_type.id
    ]
    1
  end

  #
  #  You must not have more than about 4 or 5 types.  The iSAMS system
  #  just can't cope with more (although it claims that it can).
  #
  def self.types_to_csv(csv_file)
    RS_TYPES.each do |key, rst|
      csv_file << [
        rst.id,
        rst.plural_name,
        rst.singular_name,
        rst.positive ? "Yes" : "No"
      ]
    end
    RS_TYPES.size
  end

  #
  #  Set ourselves up and add ourselves to the accumulator.
  #
  def self.setup(accumulator)
    records, message = self.slurp(accumulator, false)
    if records
      accumulator[:dbtypes] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end

  DBOOK_TYPES_FILENAME      = "rewards_and_conducts_types.csv"
  DBOOK_CATEGORIES_FILENAME = "rewards_and_conducts_categories.csv"

  def self.do_writing(accumulator, target_dir)
    ours = accumulator[:dbtypes]
    if ours
      written = 0
      csv = CSV.open(File.expand_path(
                       DBOOK_TYPES_FILENAME,
                       target_dir),
                     "wb")
      written += types_to_csv(csv)
      csv.close
      puts "Wrote #{written} records to #{DBOOK_TYPES_FILENAME}."
      written = 0
      csv = CSV.open(File.expand_path(
                       DBOOK_CATEGORIES_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.category_to_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{DBOOK_CATEGORIES_FILENAME}."
    end
  end

end
