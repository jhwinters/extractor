#
#  Class for SB FeederFeatureLink records
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_FeederFeatureLink
  FILE_NAME = "feederfeaturelink.csv"
  REQUIRED_COLUMNS = [
    Column["FeederFeatureLinkIdent", :ident,         :integer],
    Column["FeederFeatureIdent",     :feature_ident, :integer],
    Column["FeedIdent",              :feed_ident,    :integer]
  ]

  DEPENDENCIES = [
    #          Accumulator key   Record ident     Our attribute   Req'd
    Dependency[:feederfeatures,  :feature_ident,  :feature,       true],
    Dependency[:feeders,         :feed_ident,     :feeder,        true]
  ]

  include Slurper
  include Depender


  def adjust(accumulator)
    @complete = find_dependencies(accumulator, DEPENDENCIES)
    if @complete
      feeder.note_feature(feature)
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
      accumulator[:feederfeaturelinks] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end
end
