#
#  Class for SB Staff records.
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_Staff
  FILE_NAME = "staff.csv"
  REQUIRED_COLUMNS = [
    Column["UserIdent",      :ident,             :integer],
    Column["UserMnemonic",   :initials,          :string],
    Column["UserTitle",      :title,             :string],
    Column["UserForename",   :forename,          :string],
    Column["UserMiddle",     :middle_names,      :string],
    Column["UserSurname",    :surname,           :string],
    Column["UserPrefName",   :preferred_name,    :string],
    Column["UserEmail",      :email,             :string],
    Column["PType",          :ptype,             :integer],
    Column["UserTeach",      :teaches,           :boolean],
    Column["UserLeft",       :left,              :boolean],
    Column["UserDOB",        :dob,               :date],
    Column["UserGender",     :gender,            :string],
    Column["NatIdent",       :nationality_ident, :integer],
    Column["RelIdent",       :religion_ident,    :integer],
    Column["UserDateJoin",   :date_joined,       :date],
    Column["UserDateLeft",   :date_left,         :date],
    Column["UserLeftReason", :reason,            :string],
    Column["UserEmail",      :email,             :string],
    Column["UserDD",         :telno,             :string],
    Column["UserFullTime",   :full_time,         :integer],
    Column["UserHomeAdP1",   :address_string,    :string],
    Column["UserHomeAdP2",   :postcode,          :string],
    Column["UserHomeTel",    :home_tel,          :string],
    Column["UserFax",        :home_fax,          :string],
    Column["UserMob",        :mobile,            :string],
    Column["UserNote",       :note,              :string],
    Column["UserQualif",     :qualifications,    :string]
  ]

  DEPENDENCIES = [
    #          Accumulator key  Record ident        Our attribute   Req'd
    Dependency[:nationalities,  :nationality_ident, :nationality,   false],
    Dependency[:religions,      :religion_ident,    :religion,      false]
  ]
  ADMINISTRATORS = ["JHW"]
  ELEVATED       = ["ICF"]

  SENIOR_SCHOOL_TEACHING_ID          = "Senior School Teaching"
  SENIOR_SCHOOL_TEACHING_DESCRIPTION = "Teaching staff at Abingdon School"
  PREP_SCHOOL_TEACHING_ID            = "Prep School Teaching"
  PREP_SCHOOL_TEACHING_DESCRIPTION   = "Teaching staff at Abingdon Prep"

  SENIOR_SCHOOL_NON_TEACHING_ID          = "Senior School Non-teaching"
  SENIOR_SCHOOL_NON_TEACHING_DESCRIPTION = "Non teaching staff at Abingdon School"
  PREP_SCHOOL_NON_TEACHING_ID            = "Prep School Non-teaching"
  PREP_SCHOOL_NON_TEACHING_DESCRIPTION   = "Non teaching staff at Abingdon Prep"

  OTHERS_ID                              = "Others"
  OTHERS_DESCRIPTION                     = "Others"

  ADMINISTRATOR_CODE        = "A"
  ADMINISTRATOR_NAME        = "Adminstrators"
  ADMINISTRATOR_DESCRIPTION = "Administrators with full control of iSAMS"
  ELEVATED_CODE             = "E"
  ELEVATED_NAME             = "Elevated staff"
  ELEVATED_DESCRIPTION      = "Staff with special responsibilities"
  NORMAL_CODE               = "S"
  NORMAL_NAME               = "Staff"
  NORMAL_DESCRIPTION        = "Normal staff access"

  include Slurper
  include Depender

  attr_reader :address

  def adjust(accumulator)
    @tutorgroups = accumulator[:tutorgroups]
    @address = SB_Address.new(self.address_string, self.postcode)
    @complete = find_dependencies(accumulator, DEPENDENCIES)
  end

  def wanted?
    @complete
  end

  def user_name
    "#{self.forename}.#{self.surname}".downcase
  end

  def user_group
    if self.ptype == 60
      if self.teaches
        SENIOR_SCHOOL_TEACHING_ID
      else
        SENIOR_SCHOOL_NON_TEACHING_ID
      end
    elsif self.ptype == 40
      if self.teaches
        PREP_SCHOOL_TEACHING_ID
      else
        PREP_SCHOOL_NON_TEACHING_ID
      end
    else
      OTHERS_ID
    end
  end

  def security_profile
    if ADMINISTRATORS.include?(self.initials)
      ADMINISTRATOR_CODE
    elsif ELEVATED.include?(self.initials)
      ELEVATED_CODE
    else
      NORMAL_CODE
    end
  end

  def get_preferred_name
    self.preferred_name.empty? ? self.forename : self.preferred_name
  end

  def tutor?
    if @tutorgroups && @tutorgroups[self.ident]
      true
    else
      false
    end
  end

  #
  #  Outsiders are defined as those who don't have an Abingdon e-mail
  #  address.
  #
  def outsider?
    if /@abingdon(prep)?.org.uk\z/ =~ self.email.downcase
      false
    else
      true
    end
  end

  def staff_to_csv(csv_file)
    csv_file << [
      self.ident,
      self.initials,
      self.title,
      self.initials,
      self.forename,
      self.middle_names,
      self.surname,
      self.get_preferred_name,
      self.dob ? self.dob.for_isams : "",
      self.gender,
      "",                                               # Country of residence
      self.nationality ? self.nationality.name : "",
      "",                                               # Language
      self.religion ? self.religion.name : "",
      "",                                               # Ethnic group
      self.date_joined ? self.date_joined.for_isams : "",
      "",                                               # Previous school
      self.date_left ? self.date_left.for_isams : "",
      self.reason,
      "",                                               # Future school
      self.email,
      self.telno.as_telno,
      self.tutor? ? "Yes" : "No",
      self.teaches ? "Yes" : "No",
      self.full_time == 1 ? "No" : "Yes",               # Part time
      self.left ? "-1" : "1"
    ]
    1
  end

  def staff_contact_to_csv(csv_file)
    csv_file << [
      self.ident,
      "Home",
      "Self",
      self.title,
      self.initials,
      self.forename,
      self.middle_names,
      self.surname,
      self.address.address1,
      self.address.address2,
      self.address.address3,
      self.address.town,
      self.address.county,
      self.address.country,
      self.address.postcode,
      self.home_tel.as_telno,
      self.home_fax.as_telno,
      self.mobile.as_telno,
      self.email
    ]
    1
  end

  def staff_note_to_csv(csv_file)
    if self.note.empty?
      0
    else
      csv_file << [
        self.ident,
        "General",
        self.note.clean
      ]
      1
    end
  end

  def staff_qualifications_to_csv(csv_file)
    if self.qualifications.empty?
      0
    else
      csv_file << [
        self.ident,
        "Qualifications",
        self.qualifications.clean
      ]
      1
    end
  end

  def user_to_csv(csv_file)
    unless self.left || self.email.empty? || self.outsider?
      csv_file << [
        self.ident,
        self.user_name,
        self.email,
        self.user_group,
        self.security_profile,
        "No",
        ""
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
      accumulator[:staff] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end

  STAFF_FILENAME                  = "staff_data_staff.csv"
  STAFF_CONTACTS_FILENAME         = "staff_data_staff_contacts.csv"
  STAFF_NOTES_FILENAME            = "staff_data_notes.csv"
  USER_GROUPS_FILENAME            = "users_user_groups.csv"
  USER_SECURITY_PROFILES_FILENAME = "users_security_profiles.csv"
  USERS_FILENAME                  = "users_users.csv"

  def self.do_writing(accumulator, target_dir)
    ours = accumulator[:staff]
    if ours
      #
      #  Files relating to staff.
      #
      written = 0
      csv = CSV.open(File.expand_path(
                       STAFF_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.staff_to_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{STAFF_FILENAME}."
      written = 0
      csv = CSV.open(File.expand_path(
                       STAFF_CONTACTS_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.staff_contact_to_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{STAFF_CONTACTS_FILENAME}."
      written = 0
      csv = CSV.open(File.expand_path(
                       STAFF_NOTES_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.staff_note_to_csv(csv)
      end
      ours.each do |key, entry|
        written += entry.staff_qualifications_to_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{STAFF_NOTES_FILENAME}."

      #
      #  And the files relating to users.
      #
      csv = CSV.open(File.expand_path(
                       USER_GROUPS_FILENAME,
                       target_dir),
                     "wb")
      csv << [SENIOR_SCHOOL_TEACHING_ID,
              SENIOR_SCHOOL_TEACHING_DESCRIPTION]
      csv << [PREP_SCHOOL_TEACHING_ID,
              PREP_SCHOOL_TEACHING_DESCRIPTION]
      csv << [SENIOR_SCHOOL_NON_TEACHING_ID,
              SENIOR_SCHOOL_NON_TEACHING_DESCRIPTION]
      csv << [PREP_SCHOOL_NON_TEACHING_ID,
              PREP_SCHOOL_NON_TEACHING_DESCRIPTION]
      csv << [OTHERS_ID,
              OTHERS_DESCRIPTION]
      written = 5
      csv.close
      puts "Wrote #{written} records to #{USER_GROUPS_FILENAME}."
      csv = CSV.open(File.expand_path(
                       USER_SECURITY_PROFILES_FILENAME,
                       target_dir),
                     "wb")
      csv << [ADMINISTRATOR_CODE, ADMINISTRATOR_NAME, ADMINISTRATOR_DESCRIPTION]
      csv << [ELEVATED_CODE,      ELEVATED_NAME,      ELEVATED_DESCRIPTION]
      csv << [NORMAL_CODE,        NORMAL_NAME,        NORMAL_DESCRIPTION]
      written = 3
      csv.close
      puts "Wrote #{written} records to #{USER_SECURITY_PROFILES_FILENAME}."
      written = 0
      csv = CSV.open(File.expand_path(
                       USERS_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.user_to_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{USERS_FILENAME}."
    end
  end

end
