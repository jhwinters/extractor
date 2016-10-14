#
#  Class for SB PupIntakeCheck records.
#  Each of these records gives the date of a particular stage in a pupil's
#  recruitment process.
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class ConsolidatedVisit

  attr_reader :ident, :date

  @@next_ident = 1

  def initialize(visit)
    @ident = @@next_ident
    @@next_ident += 1
    @checkpoint = visit.checkpoint
    @date       = visit.date
  end

  def to_csv(csv_file)
    csv_file << [
      @ident,
      "#{@checkpoint.name} #{@date.strftime("%d/%m/%Y")}",
      @date.for_isams,
      @date.for_isams,
      "",
      @checkpoint.visit_category
    ]
  end

  #
  #  Want reverse chronological order.
  #
  def <=>(other)
    other.date <=> self.date
  end

end

class VisitRepository

  def initialize
    @known_visits = Hash.new
  end

  #
  #  We are passed each of the individual SB_PupIntakeCheck records
  #  which represents a visit.  We identify those with the same type
  #  and date and build up a record of actual events.
  #
  #  If two pupils came to, say, an Open Day on the same date then
  #  we assume they were both coming to the same event and record just
  #  the one.
  #
  def record_visit(visit)
    @known_visits[visit.hash_key] ||= ConsolidatedVisit.new(visit)
    @known_visits[visit.hash_key].ident
  end

  def to_csv(csv_file)
    written = 0
    @known_visits.collect {|key, record| record}.sort.each do |record|
      record.to_csv(csv_file)
      written += 1
    end
    written
  end

end

class SB_PupIntakeCheck
  FILE_NAME = "pupintakechecks.csv"
  REQUIRED_COLUMNS = [
    Column["PInIdent",   :ident,            :integer],
    Column["PupOrigNum", :pupil_ident,      :integer],
    Column["CkIdent",    :checkpoint_ident, :integer],
    Column["PInDate",    :date,             :date],
    Column["PInDone",    :done,             :boolean],
    Column["PInNote",    :note,             :string]
  ]

  DEPENDENCIES = [
    #          Accumulator key  Record ident       Our attribute   Req'd
    Dependency[:pupils,         :pupil_ident,      :pupil,         true],
    Dependency[:checkpoints,    :checkpoint_ident, :checkpoint,    true]
  ]
  include Slurper
  include Depender

  @@visit_repository = VisitRepository.new

  def adjust(accumulator)
    @complete = find_dependencies(accumulator, DEPENDENCIES)
    if @complete
      pupil.note_checkpoint(self)
    end
  end

  def wanted?
    @complete
  end

  def <=>(other)
    self.date <=> other.date
  end

  #
  #  Generate a hash key from our date and checkpoint number.
  #
  def hash_key
    "#{self.checkpoint_ident} : #{self.date.for_isams}"
  end

  def enrolment?
    self.checkpoint.enrolment?
  end

  def prospectus_notes
    if self.note.empty?
      self.checkpoint.name
    else
      "#{self.checkpoint.name} : #{self.note.clean}"
    end
  end

  def checkpoint_to_csv(csv_file)
    if self.checkpoint.ordinary
      csv_file << [
        self.pupil_ident,                                 # Pupil ID
        self.checkpoint.name,                             # Event name
        "",                                               # Admissions date
        self.date ? self.date.for_isams : "",             # Enquiry date
        "",                                               # Enquiry reason
        "",                                               # Enquiry method
        self.note.clean,                                  # Enquiry note
        ""                                                # Registered date
      ]
      1
    else
      0
    end
  end

  def prospectus_to_csv(csv_file)
    if self.checkpoint.prospectus
      csv_file << [
        self.pupil.appropriate_id(self.date),
        self.date ? self.date.for_isams : "",
        self.prospectus_notes
      ]
      1
    else
      0
    end
  end

  def pupil_visit_to_csv(csv_file)
    if self.checkpoint.visit
      visit_ident = @@visit_repository.record_visit(self)
      csv_file << [
        self.pupil.appropriate_id(self.date),
        visit_ident
      ]
      1
    else
      0
    end
  end

  def amount
    #
    #  Try to work out the amount of a deposit.  Err on the side of caution
    #  and go for 0 if we can do no better.
    #
    #  The simplest case, in quite a few of the older records is that the
    #  note consists entirely of a number.  Nothing but numeric digits.
    #
    if /\A\d+\z/ === self.note
      self.note.to_i
    elsif /\A[\d,]+\z/ === self.note
      #
      #  Just digits and commas - nothing else.
      #
      self.note.delete(",").to_i
    elsif /\A[\d,]+\.00\z/ === self.note
      #
      #  As the previous one, but ending in ".00"
      #
      self.note.sub(".00", "").delete(",").to_i
    elsif /£[\d, ]+/ =~ self.note
      #
      #  An embedded pound sign, followed by one or more digits, commas and
      #  spaces.  There is a danger here - there could be a second amount
      #  of money also in the string, and we have no idea whether they
      #  should be added, subtracted or what.  If a second amount is
      #  mentioned, forget it.
      #
      tentative_value = $&.delete("£, ").to_i
      if /£.+£/ =~ self.note
        #
        #  Two pound characters with anything else in between.
        #
        0
      else
        tentative_value
      end
    else
      0
    end
  end

  def deposit_to_csv(csv_file)
    if self.checkpoint.deposit && self.done
      csv_file << [
        self.pupil.appropriate_id(self.date),
        self.amount,
        self.date ? self.date.for_isams : "",
        self.note.clean,
        self.checkpoint.returns_policy,
        self.checkpoint.name
      ]
      1
    else
      0
    end
  end

  #
  #  Provide a brief text version of ourself to go in a notes field.
  #
  def text_version
    "#{
       self.date ? self.date.strftime("%d/%m/%y") + " : " : ""
     }#{
       self.checkpoint.name
     }#{
       self.done ? "" : " (not done)"
     }#{
       self.note.empty? ? "" : " - " + self.note
     }"
  end

  #
  #  Set ourselves up and add ourselves to the accumulator.
  #
  def self.setup(accumulator)
    records, message = self.slurp(accumulator, false)
    if records
      accumulator[:pupintakechecks] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end

#  CHECKPOINTS_FILENAME = "admissions_enquiries_and_enrolment.csv"
  PROSPECTUS_FILENAME = "admissions_prospectus.csv"
  VISIT_CATEGORIES_FILENAME = "admissions_visit_categories.csv"
  VISITS_FILENAME = "admissions_visits.csv"
  PUPIL_VISITS_FILENAME = "admissions_pupil_visits.csv"
  DEPOSIT_TYPES_FILENAME = "admissions_deposit_types.csv"
  DEPOSITS_FILENAME      = "admissions_deposits.csv"

  def self.do_writing(accumulator, target_dir)
    ours = accumulator[:pupintakechecks]
    if ours
#      written = 0
#      csv = CSV.open(File.expand_path(
#                       CHECKPOINTS_FILENAME,
#                       target_dir),
#                     "wb")
#      ours.each do |key, entry|
#        written += entry.checkpoint_to_csv(csv)
#      end
#      csv.close
#      puts "Wrote #{written} records to #{CHECKPOINTS_FILENAME}."
      written = 0
      csv = CSV.open(File.expand_path(
                       PROSPECTUS_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.prospectus_to_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{PROSPECTUS_FILENAME}."
      written = 0
      csv = CSV.open(File.expand_path(
                       PUPIL_VISITS_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.pupil_visit_to_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{PUPIL_VISITS_FILENAME}."
      written = 0
      csv = CSV.open(File.expand_path(
                       VISITS_FILENAME,
                       target_dir),
                     "wb")
      written = @@visit_repository.to_csv(csv)
#      ours.each do |key, entry|
#        written += entry.visit_to_csv(csv)
#      end
      csv.close
      puts "Wrote #{written} records to #{VISITS_FILENAME}."
      written = 0
      csv = CSV.open(File.expand_path(
                       VISIT_CATEGORIES_FILENAME,
                       target_dir),
                     "wb")
      written += SB_Checkpoint.write_visit_categories(csv)
      csv.close
      puts "Wrote #{written} records to #{VISIT_CATEGORIES_FILENAME}."
      written = 0
      csv = CSV.open(File.expand_path(
                       DEPOSIT_TYPES_FILENAME,
                       target_dir),
                     "wb")
      written += SB_Checkpoint.write_deposit_types(csv)
      csv.close
      puts "Wrote #{written} records to #{DEPOSIT_TYPES_FILENAME}."
      written = 0
      csv = CSV.open(File.expand_path(
                       DEPOSITS_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.deposit_to_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{DEPOSITS_FILENAME}."
    end
  end
end
