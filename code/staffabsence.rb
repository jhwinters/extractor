#
#  Class for SB Staff Absence records
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_StaffAbsence
  FILE_NAME = "staffabsence.csv"
  REQUIRED_COLUMNS = [
    Column["StaffAbsenceDate",   :start_ident,  :integer],
    Column["StaffAbsenceDate2",  :end_ident,    :integer],
    Column["UserIdent",          :user_ident,   :integer],
    Column["StAbCovReasonIdent", :reason_ident, :integer]
  ]

  DEPENDENCIES = [
    #          Accumulator key  Record ident   Our attribute   Req'd
    Dependency[:days,           :start_ident,  :start_day,     true],
    Dependency[:days,           :end_ident,    :end_day,       true],
    Dependency[:stabcovreasons, :reason_ident, :reason,        true]
  ]

  include Slurper
  include Depender


  def adjust(accumulator)
    @complete = find_dependencies(accumulator, DEPENDENCIES)
  end

  def wanted?
    @complete
  end

  def absence_to_csv(csv_file)
    csv_file << [
      self.user_ident,
      self.reason.reason,
      self.start_day.date.for_isams,
      self.end_day.date.for_isams,
      ""
    ]
    1
  end

  def <=>(other)
    self.user_ident <=> other.user_ident
  end

  #
  #  Set ourselves up and add ourselves to the accumulator.
  #
  def self.setup(accumulator)
    records, message = self.slurp(accumulator, false)
    if records
      accumulator[:staffabsences] = records
      true
    else
      puts message
      false
    end
  end

  ABSENCES_FILENAME = "staff_data_absence.csv"

  def self.do_writing(accumulator, target_dir)
    ours = accumulator[:staffabsences]
    if ours
      written = 0
      csv = CSV.open(File.expand_path(
                       ABSENCES_FILENAME,
                       target_dir),
                     "wb")
      ours.sort.each do |entry|
        written += entry.absence_to_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{ABSENCES_FILENAME}."
    end
  end

end
