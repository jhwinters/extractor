#
#  Class for SB PupFeeder records.
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_PupFeeder
  FILE_NAME = "pupfeeder.csv"
  REQUIRED_COLUMNS = [
    Column["PupFeederIdent",     :ident,        :integer],
    Column["PupOrigNum",         :pupil_ident,  :integer],
    Column["FeedIdent",          :feeder_ident, :integer],
    Column["PupFeedLast",        :last_school,  :boolean],
    Column["PupFeederStartDate", :start_date,   :date],
    Column["PupFeederNote",      :note,         :string]
  ]

  DEPENDENCIES = [
    #          Accumulator key  Record ident   Our attribute   Req'd
    Dependency[:pupils,         :pupil_ident,  :pupil,         true],
    Dependency[:feeders,        :feeder_ident, :feeder,        true]
  ]

  include Slurper
  include Depender


  def adjust(accumulator)
    @complete = find_dependencies(accumulator, DEPENDENCIES)
    if @complete
      pupil.note_feeder(feeder)
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
      accumulator[:pupfeeders] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end

end
