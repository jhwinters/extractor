#
#  Class for SB Pupil records.
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_PupilRecord
  FILE_NAME = "pupil.csv"
  REQUIRED_COLUMNS = [
    Column["Pu_Surname",        :surname,               :string],
    Column["Pu_Firstname",      :first_name,            :string],
    Column["PupSecondName",     :second_name,           :string],
    Column["PupThirdName",      :third_name,            :string],
    Column["Pu_GivenName",      :preferred_name,        :string],
    Column["Pu_Dob",            :dob,                   :date],
    Column["Pu_Gender",         :gender,                :string],
    Column["Pu_Doe",            :date_of_entry,         :date],
    Column["PupOrigNum",        :pupil_ident,           :integer],
    Column["PupUPN",            :upn,                   :string],
    Column["PupULN",            :uln,                   :string],
    Column["PupADSname",        :ad_username,           :string],
    Column["Pu_CandNo",         :candidate_no,          :string],
    Column["PupUCI",            :exam_uci,              :string],
    Column["Pu_Info",           :info,                  :string],
    Column["PupIntNote",        :registry_note,         :string],
    Column["PupMedNote",        :medical_note,          :string],
    Column["PupBoardingNotes",  :boarding_note,         :string],
    Column["NatIdent",          :nationality_ident,     :integer],
    Column["NatIdent2",         :residence_ident,       :integer],
    Column["LanIdent",          :language_ident,        :integer],
    Column["RelIdent",          :religion_ident,        :string],
    Column["EthIdent",          :ethnicity_ident,       :integer],
    Column["ClassIdent",        :class_ident,           :integer],
    Column["HouseIdent",        :house_ident,           :integer],
    Column["StageOfProspect",   :sop_ident,             :integer],
    Column["BoarderIdent",      :boarder_ident,         :integer],
    Column["PType",             :ptype,                 :integer],
    Column["YearIdent",         :year_ident,            :integer],
    Column["UserIdent",         :tutor_ident,           :integer],
    Column["PupProposedDateIn", :proposed_date_in,      :date],
    Column["PupProposedYear",   :proposed_year_ident,   :integer],
    Column["Pu_LastSchoolId",   :last_school_id,        :integer],
    Column["PupEmail",          :email,                 :string],
    Column["PupMobile",         :mobile,                :string],
    Column["PassportType",      :passport_type_ident,   :integer],
    Column["PupPassNo",         :passport_number,       :string],
    Column["PupPassIssuePlace", :passport_issue_place,  :string],
    Column["PupPassExpires",    :passport_expires,      :date],
    Column["PupVisaType",       :visa_type,             :string],
    Column["PupVisaNo",         :visa_number,           :string],
    Column["PupVisaIssued",     :visa_issued,           :date],
    Column["PupVisaExpires",    :visa_expires,          :date],
    Column["PupCAS",            :cas,                   :string],
    Column["PoliceRegistrationCode", :police_reg_code,  :string],
    Column["PupAdded",          :added_date,            :date],
    Column["PupDateArchived",   :leaving_date,          :date],
    Column["PupExamName",       :exam_name,             :string],
    Column["PupH1",             :h1_ident,              :integer],
    Column["PupH2",             :h2_ident,              :integer],
    Column["FeedAgentIdent",    :feed_agent_ident,      :integer]
  ]

  DEPENDENCIES = [
    #          Accumulator key    Record ident          Our attribute   Req'd
    Dependency[:nationalities,    :nationality_ident,   :nationality,   true],
    Dependency[:countries,        :residence_ident,     :residence,     false],
    Dependency[:languages,        :language_ident,      :language,      true],
    Dependency[:religions,        :religion_ident,      :religion,      false],
    Dependency[:ethnicities,      :ethnicity_ident,     :ethnicity,     false],
    Dependency[:classes,          :class_ident,         :sbclass,       false],
    Dependency[:houses,           :house_ident,         :house,         false],
    Dependency[:sops,             :sop_ident,           :sop,           true],
    Dependency[:boardertypes,     :boarder_ident,       :boarder_type,  true],
    Dependency[:years,            :year_ident,          :year,          false],
    Dependency[:years,            :proposed_year_ident, :proposed_year, false],
    Dependency[:staff,            :tutor_ident,         :tutor,         false],
    Dependency[:passporttypes,    :passport_type_ident, :passport_type, false],
    Dependency[:h1s,              :h1_ident,            :h1,            false],
    Dependency[:h2s,              :h2_ident,            :h2,            false],
    Dependency[:feeders,          :last_school_id,      :last_school,   false],
    Dependency[:feeders,          :feed_agent_ident,    :feed_agent,    false]
  ]

  include Slurper
  include Depender

  MAX_NOTE = 1000

  class ECN_Store

    class ECN_Record

      attr_reader :ecn, :pupils

      def initialize(ecn, pupil)
        @unique = true
        @ecn    = ecn
        @pupils = [pupil]
      end

      def add(pupil)
        @unique = false
        @pupils << pupil
      end

      def unique?
        @unique
      end

    end

    def initialize
      @ecnrs = Hash.new
    end

    def note_ecn(ecn, pupil)
      unless ecn == ""
        existing = @ecnrs[ecn]
        if existing
          existing.add(pupil)
        else
          @ecnrs[ecn] = ECN_Record.new(ecn, pupil)
        end
      end
    end

    def unique?(ecn)
      if ecn == ""
        #
        #  Empty counts as unique
        #
        true
      else
        existing = @ecnrs[ecn]
        if existing
          existing.unique?
        else
          #
          #  This shouldn't happen, because we're meant to have seen all
          #  the ECNs already.  However, since we haven't seen a duplicate
          #  report that it's unique.
          #
          true
        end
      end
    end

    #
    #  Test whether the indicated pupil can use the indicated candidate no.
    #
    #  This algorithm may well change.  Currently the iSAMS loader can't
    #  cope with two students with the same candidate number, even if only
    #  one is current.  This is an error in their code.  We should be fine
    #  to have two the same provided only one is current.
    #
    #  If and when they fix their code, the new algorithm would be just to
    #  check that there is one and only one current/external candidate for
    #  each candidate number.  Provided that is the case (and it is, for
    #  all but one candidate number) then all those listed can use it.
    #
    #  For the clash case - where there's one current pupil and one external
    #  candidate with the same candidate number - the current pupil should
    #  get it.
    #
    def pupil_can_use?(pupil, ecn)
      if ecn == ""
        true
      else
        ecnr = @ecnrs[ecn]
        if ecnr
          #
          #  Sanity check.
          #
          unless ecnr.pupils.include?(pupil)
            puts "Asked to check ecn for previously unseen pupil - #{pupil.display_name}"
          end
          if ecnr.unique?
            #
            #  Fine
            #
            true
          elsif pupil.current?
            #
            #  Sanity check.
            #
            pretender = ecnr.pupils.detect {|p| p.current? && p != pupil}
            if pretender
              puts "ERROR - Current pupils #{pupil.display_name}, and #{pretender.display_name} have the same ecn #{ecn}."
            end
            true
          elsif pupil.external_candidate?
            #
            #  Generally external candidates can have them, but there is one
            #  case where it clashes with a current pupil.
            #
            pretender = ecnr.pupils.detect {|p| p.current?}
            if pretender
              puts "External candidate #{pupil.display_name} can't have ecn #{ecn} because current pupil #{pretender.display_name} has the same one."
              false
            else
              true
            end
          else
            false
          end
        else
          puts "ERROR - asked to adjudicate on ecn which we've never seen before."
          puts "Pupil #{pupil.display_name}, ecn #{ecn}."
          false
        end
      end
    end

    def report_duplicates
      @ecnrs.each do |ecn, ecnr|
        unless ecnr.unique?
          puts "ECN #{ecnr.ecn} is shared by #{ecnr.pupils.count} pupils."
          strong_contenders = 0
          ecnr.pupils.each do |pupil|
            puts "    #{pupil.display_name} - #{pupil.status_text}"
            if pupil.current? || pupil.external_candidate?
              strong_contenders += 1
            end
          end
          if strong_contenders > 1
            puts "DANGER WILL ROBINSON! - too many strong contenders."
          end
        end
      end
    end

  end

  class UPN_Store

    class UPN_Record

      attr_reader :upn, :pupils

      def initialize(upn, pupil)
        @unique = true
        @upn    = upn
        @pupils = [pupil]
      end

      def add(pupil)
        @unique = false
        @pupils << pupil
      end

      def unique?
        @unique
      end

    end

    def initialize
      @upnrs = Hash.new
    end

    def note_upn(upn, pupil)
      unless upn == ""
        existing = @upnrs[upn]
        if existing
          existing.add(pupil)
        else
          @upnrs[upn] = UPN_Record.new(upn, pupil)
        end
      end
    end

    def unique?(upn)
      if upn == ""
        #
        #  Empty counts as unique
        #
        true
      else
        existing = @upnrs[upn]
        if existing
          existing.unique?
        else
          #
          #  This shouldn't happen, because we're meant to have seen all
          #  the UPNs already.  However, since we haven't seen a duplicate
          #  report that it's unique.
          #
          true
        end
      end
    end

    def report_duplicates
      @upnrs.each do |upn, upnr|
        unless upnr.unique?
          puts "UPN #{upnr.upn} is shared by #{upnr.pupils.count} pupils."
          upnr.pupils.each do |pupil|
            puts "    #{pupil.display_name} - #{pupil.status_text}"
          end
        end
      end
    end

  end

  @@ecn_store = ECN_Store.new
  @@upn_store = UPN_Store.new

  def initialize
    @complete = false
    @adultoffspring      = Array.new
    @checkpoints         = Array.new
    @set_names           = Array.new
    @red_flag_conditions = Array.new
    @finance_code        = nil
    @had_finance_code    = false
    @contacts_written    = 0
    @right_siblings      = Array.new
    @left_siblings       = Array.new
  end

  def display_name
    "#{self.first_name} #{self.surname} (#{self.pupil_ident})"
  end

  def adjust(accumulator)
    @complete = self.pupil_ident != -1 &&
                find_dependencies(accumulator, DEPENDENCIES)
    if @complete
      @@upn_store.note_upn(self.upn, self)
      @@ecn_store.note_ecn(self.candidate_no, self)
    end
    @do_readmissions = accumulator.options.do_readmissions
    @split_checkpoints = accumulator.options.split_checkpoints

#    if @last_school_id
#      puts "Got a last_school_id #{@last_school_id} for #{@pupil_ident}"
#    end
#    if @feed_agent_ident
#      puts "Pupil #{@pupil_ident} has feed_agent_ident of #{@feed_agent_ident}."
#    end
  end

  def note_left_sibling(pupil)
    @left_siblings << pupil
  end

  def note_right_sibling(pupil)
    @right_siblings << pupil
  end

  def wanted?
    @complete
  end

  def note_adultoffspring(ao)
    @adultoffspring << ao
  end

  def note_checkpoint(checkpoint)
    @checkpoints << checkpoint
  end

  def note_red_flag_condition(pupil_condition)
    @red_flag_conditions << pupil_condition
  end

  def note_finance_code(finance_code)
    if @had_finance_code
      #
      #  Duplicate.  Reject and blank the old one.
      #
      @finance_code = nil
      false
    else
      @finance_code = finance_code
      @had_finance_code = true
      true
    end
  end

  def write_contact_count(csv_file)
    csv_file << [
      self.pupil_ident,
      self.name,
      @contacts_written
    ]
  end

  def <=>(other)
    self.pupil_ident <=> other.pupil_ident
  end

  def status_if_not_current
    if applicant?
      " - applicant"
    elsif former?
      " - former"
    end
  end

  def name_with_id
    "#{self.name} (#{self.pupil_ident})#{status_if_not_current}"
  end

  def list_siblings(csv_file)
    if self.current? &&
       (@right_siblings.size > 0 || @left_siblings.size > 0)
      csv_file << [
        self.pupil_ident,
        self.name,
        "Linked to",
        @right_siblings.size,
        @right_siblings.sort.collect {|s| s.name_with_id}.join(", ")
      ]
      csv_file << [
        nil,
        nil,
        "Linked from",
        @left_siblings.size,
        @left_siblings.sort.collect {|s| s.name_with_id}.join(", ")
      ]
    end
  end

  def list_lost_prospects(csv_file)
    if self.lost_prospect?
      csv_file << [self.pupil_ident, self.name]
    end
  end

  def list_archived(csv_file)
    if self.archived?
      csv_file << [self.pupil_ident, self.name]
    end
  end

  def list_general_notes(csv_file)
    if self.info && !self.info.empty?
      csv_file << [self.pupil_ident, self.name, self.info.clean]
    end
  end

  #
  #  Potentially getting some more information about the links
  #  between this pupil and feeder schools or agencies.
  #
  def note_feeder(feeder)
    if feeder.agency?
      if self.feed_agent
        if self.feed_agent.ident != feeder.ident
          puts "Pupil #{self.display_name} has two apparent agents - #{self.feed_agent.ident} & #{feeder.ident}."
        end
      else
        self.feed_agent = feeder
      end
    else
      unless self.last_school
        self.last_school = feeder
        self.last_school_id = feeder.ident
      end
    end
  end

  def note_set_name(set_name)
    @set_names << set_name
  end

  def other_names
    if self.third_name.empty?
      if self.second_name.empty?
        ""
      else
        self.second_name
      end
    else
      if self.second_name.empty?
        self.third_name
      else
        "#{self.second_name} #{self.third_name}"
      end
    end
  end

  def name
    if self.preferred_name
      "#{self.preferred_name} #{self.surname}"
    else
      "#{self.first_name} #{self.surname}"
    end
  end

  def name_initials
    [self.first_name, self.second_name, self.third_name].
      select {|name| !name.empty?}.
      collect {|name| name[0]}.
      join(" ")
  end

  def exam_surname
    if @exam_name
      bits = @exam_name.split(":")
      if bits.count == 2
        bits[0].clean
      else
        ""
      end
    else
      ""
    end
  end

  def exam_forenames
    if @exam_name
      bits = @exam_name.split(":")
      if bits.count == 2
        bits[1].clean
      else
        ""
      end
    else
      ""
    end
  end

  def nc_year(as_prospect)
    if as_prospect
      ""
    else
      self.year ? self.year.effective_isams_year : ""
    end
  end

  def proposed_nc_year(as_prospect)
    if prep_school_pupil? && !as_prospect
      ""
    else
      self.proposed_year ? self.proposed_year.effective_isams_year : ""
    end
  end

  def admissions_status(as_prospect)
    if prep_school_pupil? && !as_prospect
      "Enrolled"
    else
      self.sop.name
    end
  end

  def date_to_term(date)
    month_in = date.month
    #
    #  It might seem surprising to include July, but processing is often
    #  done early in the summer holidays, resulting in an apparent date
    #  in July for a Michaelmas start.
    #
    if month_in == 7 ||
       month_in == 8 ||
       month_in == 9 ||
       month_in == 10 ||
       month_in == 11 ||
       month_in == 12
      "Michaelmas"
    elsif month_in == 1 ||
          month_in == 2 ||
          month_in == 3
      "Lent"
    elsif month_in == 4
      #
      #  More checking needed.
      #
      if date.day < 7
        "Lent"
      else
        "Summer"
      end
    else
      "Summer"
    end
  end

  def enrolment_term(as_prospect)
    date = enrolment_date(as_prospect)
    if date
      date_to_term(date)
    else
      ""
    end
  end

  def system_status(as_prospect)
    #
    #  This is slightly odd, in that we have some pupils who don't
    #  really fit into any of iSAMS's categories.  They define:
    #  1 - Current pupil
    #  0 - Prospect
    #  -1 - Left
    #
    #  but in addition to that we have type 95 which is "External
    #  candidate".  The sample code provided by iSAMS would have them
    #  appear as current.
    #
    #  On further consideration though, we will make them appear
    #  as "Left".
    #
    if (self.ptype == 40 && !as_prospect) || self.ptype == 60
      1
    elsif (self.ptype == 40 && as_prospect)
      55
    elsif self.ptype == 5 || self.ptype == 8
      0
    else
      -1
    end
  end

  def status_text
    case self.ptype
    when 40
      "Current prep"
    when 60
      "Current senior"
    when 95
      "External candidate"
    when 5
      "Prospect"
    when 8
      "Lost prospect"
    when 100
      "Archived"
    when 200
      "Deceased"
    when 255
      "Deleted"
    else
      "Unknown"
    end
  end

  def current?
    self.ptype == 40 || self.ptype == 60
  end

  def prep_school_pupil?
    self.ptype == 40
  end

  def applicant?
    self.ptype == 5 || self.ptype == 8
  end

  def lost_prospect?
    self.ptype == 8
  end

  def archived?
    self.ptype == 100
  end

  def former?
    self.ptype == 100 || self.ptype == 200 || self.ptype == 255
  end

  def external_candidate?
    self.ptype == 95
  end

  def enquiry_type
    if h1
      if h1.text == "Not Known"
        ""
      else
        if h2
          if h1.text == h2.text
            h1.text
          else
            "#{h1.text} / #{h2.text}"
          end
        else
          h1.text
        end
      end
    else
      if h2
        h2.text
      else
        ""
      end
    end
  end

  def passport_expires_str
    @passport_expires ? @passport_expires.for_isams : ""
  end

  def visa_issued_str
    @visa_issued ? @visa_issued.for_isams : ""
  end

  def visa_expires_str
    @visa_expires ? @visa_expires.for_isams : ""
  end

  def added_date_str
    @added_date ? @added_date.for_isams : ""
  end

  def leaving_date_str
    @leaving_date ? @leaving_date.for_isams : ""
  end

  def get_last_school_id(as_prospect)
    if prep_school_pupil? && as_prospect
      946               # Abingdon Prep
    else
      if @last_school_id
        if @last_school
          if @last_school.agency?
            puts "Pupil #{self.display_name} has last_school_id of #{self.last_school_id} which is an agency."
            ""
          else
            @last_school_id
          end
        else
          puts "Pupil #{self.display_name} has last_school_id of #{self.last_school_id} which doesn't seem to exist."
          ""
        end
      else
        ""
      end
    end
  end

  def get_upn
    if @@upn_store.unique?(self.upn)
      self.upn
    else
      ""
    end
  end

  def get_candidate_no
    #
    #  Exam candidate numbers are only 4 digits long and thus need to
    #  be re-cycled every few years.  iSAMS require them to be unique
    #  which is probably a data analysis error.  Allow them only for
    #  current pupils and external candidates..
    #
    if @@ecn_store.pupil_can_use?(self, self.candidate_no)
      self.candidate_no
    else
      ""
    end
  end

  def tutor_group(as_prospect)
    if as_prospect
      ""
    else
      self.sbclass ? self.sbclass.name : ""
    end
  end

  def tutors_id(as_prospect)
    if as_prospect
      ""
    else
      #
      #  It's just possible that we've somehow got a non-matching
      #  tutor ident.  Check first that we've managed to identify
      #  a corresponding tutor before using it.
      #
      self.tutor ? self.tutor_ident : ""
    end
  end

  def house_name(as_prospect)
    if as_prospect
      ""
    else
      self.house ? self.house.name : ""
    end
  end

  def enquiry_date
    self.added_date_str
  end

  #
  #  This is the date when the pupil started or will start at the school.
  #  It's filled in slightly differently depending on whether he's a current,
  #  former, or future pupil.  There is also special processing for prep
  #  school pupils, when we want to regard them as prospects.
  #
  def enrolment_date(as_prospect)
    if as_prospect || applicant?
      self.proposed_date_in
    else
      #
      #  One more possibility arises.  There are some ex-pupils who have
      #  no start date, simply because they're not really ex-pupils.
      #  They're actually lost prospects.  They thus might have had a
      #  proposed_date_in, even though they never started.
      #
      #  If they have a date of entry, then use that.  Otherwise
      #  fall back to the proposed date, if any.
      #
      if self.date_of_entry
        self.date_of_entry
      elsif self.system_status(false) == -1
        self.proposed_date_in
      end
    end
  end

  def enrolment_date_for_isams(as_prospect)
    date = enrolment_date(as_prospect)
    date ? date.for_isams : ""
  end

  #
  #  This method is intended for use with adjuncts to pupil records
  #  which might be attached either to an original pupil record, or
  #  to the same pupil's re-admissions record.
  #
  #  These are:
  #    visits
  #    deposits
  #    prospectuses
  #
  #  and possibly
  #    scholarships
  #
  #  You pass in the date of the item, and this method returns
  #  <ID> or <ID>RA appropriately.  You normally get <ID> but
  #  you get <ID>RA iff:
  #
  #    The pupil is at the prep school
  #    The date passed in is *after* the pupil's start date at the prep
  #    school.
  #
  def appropriate_id(as_at)
    threshold = enrolment_date(false)
    if @do_readmissions &&
       as_at &&
       threshold &&
       prep_school_pupil? &&
       as_at > threshold
      "#{self.pupil_ident}RA"
    else
      "#{self.pupil_ident}"
    end
  end

  def pupil_to_csv(csv_file, as_prospect)
    #
    #  If the as_prospect flag is set, then we write records only
    #  for current prep school pupils.
    #
    if !prep_school_pupil? && as_prospect
      0
    else
      csv_file << [
        "#{self.pupil_ident}#{as_prospect ? "RA" : ""}",  # Id
        self.get_upn,                                     # UPN
        self.uln,                                         # ULN
        self.ad_username,                                 # AD Username
        self.get_candidate_no,                            # Exam Candidate Number
        self.exam_uci,                                    # Exam UCI Number
        "Mr",                                             # Title
        self.name_initials,                               # Name Initials
        self.first_name,                                  # Forename
        self.other_names,                                 # Middle names
        self.surname,                                     # Surname
        self.preferred_name,                              # Preffered name
        self.dob ? self.dob.for_isams : "",               # DOB
        self.gender.upcase,                               # Gender
        self.residence ? self.residence.name : "",        # Country of residence
        self.nationality.name,                            # Nationality
        self.language.name,                               # Language
        self.religion ? self.religion.name : "",          # Religion
        self.ethnicity ? self.ethnicity.name : "",        # Ethnicity
        "",                                               # Birth place
        "",                                               # Birth county
        "",                                               # Birth country
        "",                                               # Diplomatic & forces
        self.nc_year(as_prospect),                        # NC Year (adjusted)
        self.tutor_group(as_prospect),                    # Tutor group
        self.tutors_id(as_prospect),                      # Tutor
        self.house_name(as_prospect),                     # Academic house
        "",                                               # Boarding house
        self.enquiry_date,                                # Enquiry date
        "",                                               # Enquiry type
        "",                                               # Admissions date
        self.admissions_status(as_prospect),              # Admissions status
        self.enrolment_date_for_isams(as_prospect),       # Enrolment date
        self.proposed_nc_year(as_prospect),               # Enrolment NC year
        self.enrolment_term(as_prospect),                 # Enrolment term name
        "",                                               # Enrolment form
        "",                                               # Enrolment ac house
        "",                                               # Enrolment b'ding h'se
        self.get_last_school_id(as_prospect),             # Previous school id.
        self.leaving_date_str,                            # Leaving date
        "",                                               # Leaving reason
        "",                                               # Leaving NC year
        "",                                               # Leaving term name
        "",                                               # Leaving form
        "",                                               # Leaving Ac Hse
        "",                                               # Leaving Bd Hse
        self.exam_surname,                                # Exam surname
        self.exam_forenames,                              # Exam forenames
        self.email.clean,                                 # Pupil email
        self.mobile.clean.as_telno,                       # Mobile number
        self.boarder_type.boarder_type_for_isams,         # School status
        self.system_status(as_prospect)                   # System status
      ]
      1
    end
  end

  def contacts_to_csv(csv_file)
    written = 0
    #
    #  Need to write one record for each known contact, trying to
    #  identify mother and father as far as is possible.  Whether
    #  or not an individual can be identified, he or she still gets
    #  an output record.
    #
    @adultoffspring.sort.each do |ao|
      written += ao.to_csv(csv_file)
    end
    @contacts_written += written
    written
  end

  #
  #  This method writes the notes completely un-mangled.
  #
  def write_note_intact(csv_file, note_type, note)
    if note.empty?
      0
    else
      csv_file << [self.pupil_ident,
                   note_type,
                   note,
                   Date.today.for_isams]
      1
    end
  end

  def write_registry_intact(csv_file, field_name, note)
    if note.empty?
      0
    else
      csv_file << [self.pupil_ident,
                   field_name,
                   note]
      1
    end
  end

  def info_to_csv(csv_file)
    write_note_intact(csv_file, "Information", self.info)
  end

  def registered_date
    #
    #  Try to work out the date on which this pupil reached a status
    #  of Registered.  This has to come from a checkpoint.
    #
    #  Note that the pupil's current status might not be Registered -
    #  he might have moved on and now be Current, but we'd still like
    #  to know when he became Registered.
    #
    #  The relevant checkpoint is no. 13 "Enq Registered Date".
    #
    #  It's possible that the pupil has become Registered more than
    #  once, in which case take the last instance.
    #  
    #  Amendment: I have been asked to check checkpoint 229 "Enquiry
    #  to Registered" as well.
    #
    #  Further update - apparently the 229 checkpoint - Enquiry to
    #  Registered - should take priority.
    #
    cps229 = @checkpoints.select {|cp| cp.checkpoint_ident == 229}
    cps13  = @checkpoints.select {|cp| cp.checkpoint_ident == 13}
    if cps229.size > 0
      cps = cps229
    elsif cps13.size > 0
      cps = cps13
    else
      cps = []
    end
    if cps.size == 0
      nil
    else
      cps.sort.last.date.for_isams
    end
  end

  def admissions_to_csv(csv_file, as_prospect)
    if !prep_school_pupil? && as_prospect
      0
    else
      csv_file << [
        "#{self.pupil_ident}#{as_prospect ? "RA" : ""}", # Id
        self.admissions_status(as_prospect), # Admissions status (dup)
        "",                                  # Admissions date (dup)
        self.enquiry_date,                   # Enquiry date (dup)
        "",                                  # Enquiry reason
        "",                                  # Enquiry method (not captured)
        "",                                  # Enquiry notes
        self.registered_date                 # Registered date
      ]
      1
    end
  end

  def boarding_to_csv(csv_file)
    write_note_intact(csv_file, "Boarding", self.boarding_note)
  end

  def health_to_csv(csv_file)
    write_note_intact(csv_file, "General", self.medical_note)
  end

  def red_flag_texts
    #
    #  It's just possible that a student will have the same condition
    #  flagged twice - don't list it twice.
    #
    @red_flag_conditions.collect {|rfc| rfc.condition.reduced_condition}.
                         uniq.
                         join(",")
  end

  def red_flag_conditions_to_csv(csv_file)
    if @red_flag_conditions.empty?
      0
    else
      #
      #  Might have more than one.
      #
      csv_file << [
        self.pupil_ident,               # Pupil ID
        nil,                            # Wears glasses
        nil,                            # Right or left handed
        nil,                            # NHS number
        "Yes",                          # Red flag
        red_flag_texts                  # Notes
      ]
      1
    end
  end

  def passport_to_csv(csv_file)
    written = 0
    if self.passport_type || !self.passport_number.empty?
      csv_file << [self.pupil_ident,
                   self.passport_type ? self.passport_type.name : "",
                   self.passport_number,
                   self.nationality.name,
                   self.passport_issue_place,
                   self.passport_expires_str]
      written = 1
    end
    written
  end

  def visa_to_csv(csv_file)
    written = 0
    unless self.visa_type.empty?
      csv_file << [self.pupil_ident,
                   self.visa_type,
                   self.visa_number,
                   self.cas,
                   self.nationality.name,
                   "",
                   self.visa_issued_str,
                   self.visa_expires_str,
                   "",
                   self.police_reg_code]
      written = 1
    end
    written
  end

  def unused_phonenos
    @adultoffspring.collect {|ao| ao.unused_phonenos}.flatten
  end

  def unused_emails
    @adultoffspring.collect {|ao| ao.unused_emails}.flatten
  end

  def spare_phonenos_to_csv(csv_file, field_name)
    written = 0
    spares = unused_phonenos
    if spares.size > 0
      csv_file << [self.pupil_ident,
                   field_name,
                   spares.collect {|sn| sn.text_version.clean}.join(",")]
      written += 1
    end
    written
  end

  def spare_emails_to_csv(csv_file, field_name)
    written = 0
    spares = unused_emails
    if spares.size > 0
      csv_file << [self.pupil_ident,
                   field_name,
                   spares.join(",")]
      written += 1
    end
    written
  end

  def finance_code_to_csv(csv_file, field_name)
    if self.finance_code
      csv_file << [
        self.pupil_ident,
        field_name,
        self.finance_code
      ]
      1
    else
      0
    end
  end

  def checkpoints_to_csv(csv_file)
    if @checkpoints.size == 0
      0
    else
      if @split_checkpoints &&
         prep_school_pupil? &&
         (threshold = self.enrolment_date(false))
        before, after = @checkpoints.partition {|cp| cp.date < threshold}
        written = 0
        if before.size > 0
          note =
            before.sort.collect {|c| c.text_version}.join("\n")
          csv_file << [
            self.pupil_ident,
            "SB Checkpoints",
            note,
            Date.today.for_isams
          ]
          written += 1
        end
        if after.size > 0
          note =
            after.sort.collect {|c| c.text_version}.join("\n")
          csv_file << [
            "#{self.pupil_ident}RA",
            "SB Checkpoints",
            note,
            Date.today.for_isams
          ]
          written += 1
        end
        written
      else
        note =
          @checkpoints.sort.collect {|c| c.text_version}.join("\n")
        csv_file << [
          self.pupil_ident,
          "SB Checkpoints",
          note,
          Date.today.for_isams
        ]
        1
      end
    end
  end

  def enquiry_notes_to_csv(csv_file)
    if self.registry_note.empty?
      0
    else
      csv_file << [
        self.pupil_ident,
        "SB Notes",
        self.registry_note,
        Date.today.for_isams
      ]
      1
    end
  end

  def pupil_allocation_to_csv(csv_file)
    if self.feed_agent && self.feed_agent.agency?
      csv_file << [
        self.pupil_ident,
        self.feed_agent.ident
      ]
      1
    else
      0
    end
  end

  def list_set_names(csv_file)
    if @set_names.size > 0
      csv_file << [
        "",                             # iSAMS id
        self.pupil_ident,
        self.surname,
        self.first_name
      ] + @set_names
      1
    else
      0
    end
  end

  def count_fathers
    father_count = 0
    @adultoffspring.each do |ao|
      if ao.get_relationship1 == "Father"
        father_count += 1
      end
      if ao.get_relationship2 == "Father"
        father_count += 1
      end
    end
    father_count
  end

  #
  #  Set ourselves up and add ourselves to the accumulator.
  #
  PRE_REQUISITES = []

  def self.setup(accumulator)
    PRE_REQUISITES.each do |pr|
      unless accumulator[pr]
        puts "Pre-requisite #{pr} missing from accumulator and needed by regpup."
        return false
      end
    end
    records, message = self.slurp(accumulator, false)
    if records
      accumulator[:pupils] = records.collect {|r| [r.pupil_ident, r]}.to_h
#      puts records[0].inspect
#      puts records[0].nationality.inspect
      true
    else
      puts message
      false
    end
  end

  PUPILS_FILENAME                    = "pupil_data_pupils.csv"
  PUPIL_GROUPS_FILENAME              = "pupil_groups.csv"
  PUPIL_CONTACTS_FILENAME            = "pupil_data_pupil_contacts.csv"
  PUPIL_NOTES_FILENAME               = "pupil_data_general_notes.csv"
  PUPIL_HEALTH_NOTES_FILENAME        = "pupil_data_health_notes.csv"
  PUPIL_PASSPORT_FILENAME            = "pupil_data_passport_info.csv"
  PUPIL_VISA_FILENAME                = "pupil_data_visa_info.csv"
  PUPIL_CUSTOM_FIELDS_FILENAME       = "pupil_data_custom_fields.csv"
  PUPIL_CUSTOM_FIELD_VALUES_FILENAME = "pupil_data_custom_field_value.csv"
  SPARE_PHONENOS_FIELD_NAME          = "Other telephone numbers"
  SPARE_EMAILS_FIELD_NAME            = "Other emails"
  FINANCE_CODE_FIELD_NAME            = "Finance code"
  AGENCIES_PUPIL_ALLOCATION_FILENAME = "agencies_pupil_allocation.csv"
  ENQUIRIES_AND_ENROLMENT_FILENAME   = "admissions_enquiries_and_enrolment.csv"
  SANATORIUM_GENERAL_FILENAME        = "sanatorium_general.csv"

  def self.do_writing(accumulator, target_dir)
    ours = accumulator[:pupils]
    if ours
      #
      #  Main sheet.
      #
      written = 0
      csv = CSV.open(File.expand_path(
                       PUPILS_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.pupil_to_csv(csv, false)
        written += entry.pupil_to_csv(csv, true)
      end
      csv.close
      puts "Wrote #{written} records to #{PUPILS_FILENAME}."
      #
      #  Contacts.
      #
      written = 0
      csv = CSV.open(File.expand_path(
                       PUPIL_CONTACTS_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.contacts_to_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{PUPIL_CONTACTS_FILENAME}."
      #
      #  Passport data.
      #
      written = 0
      csv = CSV.open(File.expand_path(
                       PUPIL_PASSPORT_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.passport_to_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{PUPIL_PASSPORT_FILENAME}."
      #
      #  Visa data.
      #
      written = 0
      csv = CSV.open(File.expand_path(
                       PUPIL_VISA_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.visa_to_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{PUPIL_VISA_FILENAME}."
      #
      #  General notes.
      #
      written = 0
      csv = CSV.open(File.expand_path(
                       PUPIL_NOTES_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.info_to_csv(csv)
        written += entry.boarding_to_csv(csv)
        written += entry.checkpoints_to_csv(csv)
        written += entry.enquiry_notes_to_csv(csv)
      end
      written += SB_PupApp.applications_to_csv(accumulator, csv)
      csv.close
      puts "Wrote #{written} records to #{PUPIL_NOTES_FILENAME}."
      #
      #  Health notes.
      #
      written = 0
      csv = CSV.open(File.expand_path(
                       PUPIL_HEALTH_NOTES_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.health_to_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{PUPIL_HEALTH_NOTES_FILENAME}."
      #
      #  Custom fields.
      # 
      written = 0
      csv = CSV.open(File.expand_path(
                       PUPIL_CUSTOM_FIELDS_FILENAME,
                       target_dir),
                     "wb")
      csv << [SPARE_PHONENOS_FIELD_NAME, "Textbox",  ""]
      written += 1
      csv << [SPARE_EMAILS_FIELD_NAME, "Textbox",  ""]
      written += 1
      #
      written += SB_Feature.write_custom_field_names(accumulator, csv)
      #
      #  One for the Pass system identifying code.
      #
      csv << [FINANCE_CODE_FIELD_NAME, "Textbox", ""]
      written += 1
      csv.close
      puts "Wrote #{written} records to #{PUPIL_CUSTOM_FIELDS_FILENAME}."
      #
      #  Values for custom fields.
      #
      written = 0
      csv = CSV.open(File.expand_path(
                       PUPIL_CUSTOM_FIELD_VALUES_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.spare_phonenos_to_csv(csv, SPARE_PHONENOS_FIELD_NAME)
        written += entry.spare_emails_to_csv(csv, SPARE_EMAILS_FIELD_NAME)
        written += entry.finance_code_to_csv(csv, FINANCE_CODE_FIELD_NAME)
      end
      #
      #  Don't want the old media permission fields any more (which
      #  amazingly enough were in the medical tables).
      #
      #written += SB_MedCheckPup.write_custom_field_values(accumulator, csv)
      written += SB_PupilFeature.write_custom_field_values(accumulator, csv)
      #
      csv.close
      puts "Wrote #{written} records to #{PUPIL_CUSTOM_FIELD_VALUES_FILENAME}."
      written = 0
      csv = CSV.open(File.expand_path(
                       AGENCIES_PUPIL_ALLOCATION_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.pupil_allocation_to_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{AGENCIES_PUPIL_ALLOCATION_FILENAME}."
      #
      #  And the admissions stuff.
      #
      written = 0
      csv = CSV.open(File.expand_path(
                       ENQUIRIES_AND_ENROLMENT_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.admissions_to_csv(csv, false)
        written += entry.admissions_to_csv(csv, true)
      end
      csv.close
      puts "Wrote #{written} records to #{ENQUIRIES_AND_ENROLMENT_FILENAME}."
      #
      #  And the sanatorium stuff.
      #
      written = 0
      csv = CSV.open(File.expand_path(
                       SANATORIUM_GENERAL_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.red_flag_conditions_to_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{SANATORIUM_GENERAL_FILENAME}."
    end
  end

  def self.write_groups(accumulator, target_dir)
    ours = accumulator[:pupils]
    if ours
      written = 0
      csv = CSV.open(File.expand_path(
                       PUPIL_GROUPS_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.list_set_names(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{PUPIL_GROUPS_FILENAME}."
    end
  end

  DUMP_DIR = File.expand_path("../dump/", File.dirname(__FILE__))

  def self.do_stats(accumulator)
    ours = accumulator[:pupils]
    if ours
      our_recs = ours.collect {|key, entry| entry}
      current = our_recs.select {|rec| rec.current?}
      puts "#{current.count} current pupils."
      lacking_nc_year = current.select {|rec| rec.nc_year(false) == ""}
      if lacking_nc_year.size > 0
        puts "Of whom, #{lacking_nc_year.size} lack an apparent NC year."
        puts "For instance:"
        puts lacking_nc_year[0].inspect
      end
      applicants = our_recs.select {|rec| rec.applicant?}
      puts "#{applicants.count} applicants."
      previous = our_recs.select {|rec| rec.former?}
      puts "#{previous.count} previous pupils."
      external = our_recs.select {|rec| rec.external_candidate?}
      puts "#{external.count} external candidates."
      if our_recs.size != (current.size + applicants.size + previous.size + external.size)
        others = our_recs - (current + applicants + previous + external)
        puts "#{others.size} others."
        puts "For instance:"
        puts others[0].inspect
      end
      our_recs.each do |rec|
        if rec.count_fathers > 1
          puts "Pupil #{rec.pupil_ident} #{rec.name} has #{rec.count_fathers} fathers."
        end
      end
      #
      #  Stats file for Niki.
      #
      csv = CSV.open(File.expand_path("contactcounts.csv",
                                      DUMP_DIR),
                     "wb")
      csv << ["Pupil ID", "Pupil name", "Contacts"]
      ours.each do |key, pupil|
        pupil.write_contact_count(csv)
      end
      csv.close
      #
      #  And sibling info.
      #
      csv = CSV.open(File.expand_path("siblings.csv",
                                      DUMP_DIR),
                     "wb")
      csv << ["Pupil ID", "Pupil name", nil, "Count", "List"]
      ours.each do |key, pupil|
        pupil.list_siblings(csv)
      end
      csv.close
      #
      #  And lost prospects.
      #
      csv = CSV.open(File.expand_path("lostprospects.csv",
                                      DUMP_DIR),
                     "wb")
      csv << ["Pupil ID", "Pupil name"]
      ours.each do |key, pupil|
        pupil.list_lost_prospects(csv)
      end
      csv.close
      #
      #  And archived
      #
      csv = CSV.open(File.expand_path("archived.csv",
                                      DUMP_DIR),
                     "wb")
      csv << ["Pupil ID", "Pupil name"]
      ours.each do |key, pupil|
        pupil.list_archived(csv)
      end
      csv.close
      #
      #  And notes.
      #
      csv = CSV.open(File.expand_path("generalnotes.csv",
                                      DUMP_DIR),
                     "wb")
      csv << ["Pupil ID", "Pupil name", "Note"]
      ours.each do |key, pupil|
        pupil.list_general_notes(csv)
      end
      csv.close

    end
    @@ecn_store.report_duplicates
    @@upn_store.report_duplicates
  end

end
