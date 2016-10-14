#
#  Class for SB DayBook records.
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_DayBook
  FILE_NAME = "dbook.csv"
  REQUIRED_COLUMNS = [
    Column["DBookIdent",        :ident,         :integer],
    Column["PupOrigNum",        :pupil_ident,   :integer],
    Column["Dater",             :date,          :date],
    Column["UserIdent",         :staff_ident,   :integer],
    Column["DBTypeIdent",       :type_ident,    :integer],
    Column["DBookNote",         :note,          :string],
    Column["DBookPointsEarned", :points_earned, :integer],
    Column["EmailNotify",       :email_notify,  :boolean]
  ]

  DEPENDENCIES = [
    #          Accumulator key    Record ident     Our attribute   Req'd
    Dependency[:dbtypes,          :type_ident,     :dbtype,        true],
    Dependency[:pupils,           :pupil_ident,    :pupil,         true],
    Dependency[:staff,            :staff_ident,    :staff,         true]
  ]

  include Slurper
  include Depender


  def adjust(accumulator)
    #
    #  In SB, we have 7 original categories which we didn't want
    #  and have never used.  Taking the opportunity to get rid of them.
    #
    if @type_ident > 7
      @complete = find_dependencies(accumulator, DEPENDENCIES)
    else
      @complete = false
    end
  end

  def wanted?
    @complete
  end

  def dbook_to_csv(csv_file)
    csv_file << [
      self.pupil_ident,
      self.staff_ident,
      self.date ? self.date.for_isams : "",
      self.note.clean,
      "",                                               # Department
      "",                                               # Subject
      self.type_ident
    ]
    1
  end

  #
  #  Set ourselves up and add ourselves to the accumulator.
  #
  def self.setup(accumulator)
    records, message = self.slurp(accumulator, false)
    if records
      accumulator[:dbooks] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end

  DBOOK_FILENAME = "rewards_and_conducts_pupil_allocation.csv"

  def self.do_writing(accumulator, target_dir)
    ours = accumulator[:dbooks]
    if ours
      written = 0
      csv = CSV.open(File.expand_path(
                       DBOOK_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.dbook_to_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{DBOOK_FILENAME}."
    end
  end

end
