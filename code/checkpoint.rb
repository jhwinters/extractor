#
#  Class for SB Checkpoint records
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_Checkpoint
  FILE_NAME = "checkpoints.csv"
  REQUIRED_COLUMNS = [
    Column["CkIdent", :ident, :integer],
    Column["CkName",  :name,  :string],
    Column["CkRank",  :rank,  :integer]
  ]

  include Slurper

  attr_reader :deposit, :prospectus, :visit, :ordinary

  DEPOSIT_CHECKPOINTS = {
    11   => "No Return",
    15   => "Last Term",
    7045 => "No Return",
    8382 => "No Return"
  }

  PROSPECTUS_CHECKPOINTS = [1, 12]

  VISIT_CATEGORIES = {
    openday:         "Open Day",
    taster:          "Taster",
    boardingtaster:  "Boarding Taster",
    admissionsvisit: "Admissions Visit",
    other:           "Other",
    eventoffsite:    "Event - Off site",
    eventonsite:     "Event - On site"
  }

  VISIT_CHECKPOINT_CATEGORIES = {
    16   => :admissionsvisit,
    20   => :openday,
    42   => :openday,
    47   => :eventonsite,
    48   => :eventonsite,
    49   => :eventoffsite,
    50   => :eventoffsite,
    58   => :eventoffsite,
    95   => :boardingtaster,
    107  => :eventoffsite,
    117  => :taster,
    121  => :eventoffsite,
    124  => :openday,
    140  => :eventoffsite,
    150  => :openday,
    151  => :eventoffsite,
    153  => :openday,
    156  => :eventoffsite,
    158  => :eventoffsite,
    164  => :eventoffsite,
    171  => :openday,
    177  => :eventoffsite,
    183  => :eventoffsite,
    208  => :eventoffsite,
    209  => :eventoffsite,
    213  => :eventoffsite,
    214  => :eventoffsite,
    216  => :taster,
    221  => :eventoffsite,
    4976 => :admissionsvisit,
    4977 => :openday,
    4978 => :openday,
    8290 => :admissionsvisit,
    8292 => :eventoffsite,
    8293 => :other,
    8318 => :other,
    8321 => :eventonsite,
    8323 => :eventoffsite,
    8331 => :eventoffsite,
    8335 => :eventonsite,
    8339 => :eventoffsite,
    8340 => :eventoffsite,
    8344 => :eventoffsite,
    8345 => :eventoffsite,
    8354 => :eventoffsite,
    8355 => :eventoffsite,
    8376 => :eventoffsite,
    8381 => :boardingtaster,
    8386 => :eventoffsite,
    8387 => :eventoffsite,
    8388 => :eventoffsite,
    8389 => :eventoffsite,
    8393 => :eventoffsite,
    8397 => :eventoffsite,
    8398 => :eventoffsite,
    8399 => :eventoffsite,
    8400 => :eventoffsite,
    8401 => :eventonsite,
    8403 => :eventoffsite,
    8409 => :eventonsite
  }

  ENROLMENT_CHECKPOINTS = [
    7051,
    7270,
    8050,
    8055,
    8063,
    8156,
    8203,
    8218,
    8333,
    8338,
    8348,
    8362,
    8384
  ]

  def adjust(accumulator)
    @prospectus = false
    @visit      = false
    @deposit    = false
    @ordinary   = false
    #
    #  Some kinds of checkpoints go to different tables in iSAMS.
    #
    if PROSPECTUS_CHECKPOINTS.include?(self.ident)
      @prospectus = true
    elsif DEPOSIT_CHECKPOINTS[self.ident]
      @deposit = true
    elsif VISIT_CHECKPOINT_CATEGORIES[self.ident] != nil
      @visit = true
    else
      @ordinary = true
    end
  end

  def returns_policy
    DEPOSIT_CHECKPOINTS[self.ident]
  end

  def wanted?
    true
  end

  def visit_category
    VISIT_CHECKPOINT_CATEGORIES[self.ident]
  end

  def enrolment?
    ENROLMENT_CHECKPOINTS.include?(self.ident)
  end

  #
  #  Set ourselves up and add ourselves to the accumulator.
  #
  def self.setup(accumulator)
    records, message = self.slurp(accumulator, false)
    if records
      accumulator[:checkpoints] = records.collect {|r| [r.ident, r]}.to_h
      @@ours = accumulator[:checkpoints]
      true
    else
      puts message
      false
    end
  end

  def self.write_visit_categories(csv_file)
    VISIT_CATEGORIES.each do |key, name|
      csv_file << [
        key.to_s,
        name
      ]
    end
    VISIT_CATEGORIES.count
  end

  def self.write_deposit_types(csv_file)
    written = 0
    @@ours.each do |key, record|
      if record.deposit
        csv_file << [
          record.name, nil
        ]
        written += 1
      end
    end
    written
  end

end
