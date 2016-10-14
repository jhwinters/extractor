#
#  Class for SB PupApp Records.
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_PupApp
  FILE_NAME = "pupapp.csv"
  REQUIRED_COLUMNS = [
    Column["PupAppIdent",       :ident,             :integer],
    Column["PupOrigNum",        :pupil_ident,       :integer],
    Column["AppIdent",          :application_ident, :integer],
    Column["PupAppNote",        :note,              :string],
    Column["PupAppAwarded",     :awarded,           :boolean],
    Column["PupAppDateAwarded", :date_awarded,      :date],
    Column["PupAppRequestDate", :date_requested,    :date]
  ]

  DEPENDENCIES = [
    #          Accumulator key  Record ident      Our attribute Req'd
    Dependency[:pupils,       :pupil_ident,       :pupil,       true],
    Dependency[:applications, :application_ident, :application, true]
  ]

  include Slurper
  include Depender


  def adjust(accumulator)
    @complete = find_dependencies(accumulator, DEPENDENCIES)
  end

  def wanted?
    @complete
  end

  def body
    #
    #  Provide the gist of this application in a text form.
    #
    "Applied for: #{
       application.description
    }#{
       self.date_requested ?
       " on #{self.date_requested.strftime("%d/%m/%y")}" :
       ""
    }#{
       self.date_awarded ?
       ", Awarded: #{self.date_awarded.strftime("%d/%m/%y")}" :
       ""
    }#{
      self.note.empty? ? "" : " (#{self.note.clean})"
    }"
  end

  def to_csv(csv_file)
    #
    #  Write outselves to the CSV file as a general note.
    #
    if self.date_requested
      effective_date = self.date_requested
    else
      effective_date = self.date_awarded
    end
    if effective_date
      csv_file << [
        pupil.appropriate_id(effective_date),
        "Application",
        self.body,
        effective_date.for_isams
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
      accumulator[:pupapps] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end

  def self.applications_to_csv(accumulator, csv_file)
    ours = accumulator[:pupapps]
    if ours
      written = 0
      ours.each do |key, application|
        application.to_csv(csv_file)
      end
      written
    else
      0
    end
  end
end
