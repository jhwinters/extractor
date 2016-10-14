#
#  Class for SB Pupil Registration records.
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class DTSchedule
  @@next_id = 0
  @@entries = Hash.new

  attr_reader :id, :date, :ampm

  #
  #  Store one Date Time Schedule entry.
  #
  def initialize(date, ampm)
    @date = date
    @ampm = ampm
    @id   = @@next_id
    @@next_id += 1
  end

  def morning?
    self.ampm == :am
  end

  def date_time_str
    if self.morning?
      time_str = "09:00"
    elsif self.date.wday == 3      # Wednesday
      time_str = "13:00"
    else
      time_str = "15:00"
    end
    "#{self.date.for_isams} #{time_str}"
  end

  def slot_name
    self.morning? ?  "Morning Registration" : "Afternoon Registration"
  end

  def ampm_str
    self.morning? ? "AM" : "PM"
  end

  def dump_csv(csv_file)
    csv_file << [self.id,
                 self.date_time_str,
                 self.slot_name,
                 self.ampm_str,
                 "Import Rule"]
  end

  def self.hash_key(date, ampm)
    "#{date.for_isams} #{ampm == :am ? "AM" : "PM"}"
  end

  def self.entry_for(date, ampm)
    #
    #  Find an appropriate entry for the indicated date and slot.
    #  Create one if needs be.
    #
    @@entries[hash_key(date, ampm)] ||= DTSchedule.new(date, ampm)
  end

  def self.dump_csv(csv_file)
    @@entries.each do |key, entry|
      entry.dump_csv(csv_file)
    end
    @@entries.count
  end

end


class SB_RegPup
  @@accumulator = nil

  FILE_NAME = "regpup.csv"
  REQUIRED_COLUMNS = [
    Column["DateIdent",   :date_ident, true],
    Column["PupOrigNum",  :pupil_ident, true],
    Column["RegIdentAM1", :mon_am, true],
    Column["RegIdentPM1", :mon_pm, true],
    Column["RegIdentAM2", :tue_am, true],
    Column["RegIdentPM2", :tue_pm, true],
    Column["RegIdentAM3", :wed_am, true],
    Column["RegIdentPM3", :wed_pm, true],
    Column["RegIdentAM4", :thu_am, true],
    Column["RegIdentPM4", :thu_pm, true],
    Column["RegIdentAM5", :fri_am, true],
    Column["RegIdentPM5", :fri_pm, true]
  ]

  include Slurper

  attr_reader :start_date

  def initialize
    @complete = false
  end

  def adjust(accumulator)
    #
    #  SB seems to contain some records which simply have no information
    #  at all.  Note, these are not ten absences - they are ten dunnos.
    #
    if self.mon_am != 0 || self.mon_pm != 0 ||
       self.tue_am != 0 || self.tue_pm != 0 ||
       self.wed_am != 0 || self.wed_pm != 0 ||
       self.thu_am != 0 || self.thu_pm != 0 ||
       self.fri_am != 0 || self.fri_pm != 0
      #
      #  Need to find out our date.
      #
      days = accumulator[:days]
      if days && (day = days[self.date_ident])
        @start_date = day.date
        #
        #  Don't want any entries from the future.  However, we do want
        #  the rest of this week if it's run on a Monday.
        #
        if @start_date <= Date.today
          @complete = true
        end
      end
    end
  end

  def wanted?
    @complete
  end

  IndividualEntry = Struct.new(:name, :ampm, :date_offset)

  Entries = [
    IndividualEntry.new(:mon_am, :am, 0),
    IndividualEntry.new(:mon_pm, :pm, 0),
    IndividualEntry.new(:tue_am, :am, 1),
    IndividualEntry.new(:tue_pm, :pm, 1),
    IndividualEntry.new(:wed_am, :am, 2),
    IndividualEntry.new(:wed_pm, :pm, 2),
    IndividualEntry.new(:thu_am, :am, 3),
    IndividualEntry.new(:thu_pm, :pm, 3),
    IndividualEntry.new(:fri_am, :am, 4),
    IndividualEntry.new(:fri_pm, :pm, 4)
  ]

  def to_csv(csv_file)
    written = 0
    regtypes = @@accumulator[:regtypes]
    Entries.each do |entry|
      value = self.send(entry.name)
      if value != 0
        reg_code = regtypes[value].reg_type
        if reg_code
          present = (reg_code == '/' ||
                     reg_code == 'L')
          #
          #  Make sure there is a suitable date time schedule entry for this
          #  registration.  They actually get written later.
          #
          effective_date = self.start_date + entry.date_offset
          dts_id = DTSchedule.entry_for(effective_date, entry.ampm).id
          csv_file << [self.pupil_ident,
                       dts_id,
                       present ? "Yes" : "No",
                       present ? "" : reg_code,
                       ""]
          written += 1
        end
      end
    end
    written
  end

  #
  #  Set ourselves up and add ourselves to the accumulator.
  #
  PRE_REQUISITES = [:days, :regtypes]

  def self.setup(accumulator)
    PRE_REQUISITES.each do |pr|
      unless accumulator[pr]
        puts "Pre-requisite #{pr} missing from accumulator and needed by regpup."
        return false
      end
    end
    records, message = self.slurp(accumulator, false)
    if records
      accumulator[:regpups] = records
      @@accumulator = accumulator
      true
    else
      puts message
      false
    end
  end

  MAX_RECORDS = 800000
  RPR_BASENAME = "registrations_pupil_registration"
  RDTS_NAME = "registrations_date_time_schedule.csv"

  def self.do_writing(accumulator, target_dir)
    suffix = 0
    written = 0
    ours = accumulator[:regpups]
    if ours
      csv = CSV.open(File.expand_path(
                       "#{RPR_BASENAME}#{suffix}.csv",
                       target_dir),
                     "wb")
      ours.each do |entry|
        written += entry.to_csv(csv)
        if written >= MAX_RECORDS
          csv.close
          puts "Wrote #{written} records to #{RPR_BASENAME}#{suffix}.csv"
          suffix += 1
          written = 0
          csv = CSV.open(File.expand_path(
                           "#{RPR_BASENAME}#{suffix}.csv",
                           target_dir),
                         "wb")
        end
      end
      csv.close
      puts "Wrote #{written} records to #{RPR_BASENAME}#{suffix}.csv"
      #
      #  And the Date Time Schedule records.
      #
      CSV.open(File.expand_path(RDTS_NAME, target_dir), "wb") do |csv|
        written = DTSchedule.dump_csv(csv)
        puts "Wrote #{written} records to #{RDTS_NAME}"
      end
    end
  end

end
