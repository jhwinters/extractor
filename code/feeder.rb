#
#  Class for SB Feeder (Schools) Records.
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_Feeder
  FILE_NAME = "feeder.csv"
  REQUIRED_COLUMNS = [
    Column["FeedIdent",    :ident,          true],
    Column["Fe_Address",   :address_string, false],
    Column["Fe_Phone",     :phone_no,       false],
    Column["FeedPostCode", :postcode,       false],
    Column["Fe_School",    :name,           false],
    Column["FeedEmail",    :email,          false],
    Column["FeedWeb",      :url,            false],
    Column["FeedAgent",    :agent,          :boolean]
  ]

  include Slurper

  attr_reader :address

  def adjust(accumulator)
    @features = Hash.new
    @address = SB_Address.new(address_string, postcode)
  end

  def wanted?
    true
  end

  def note_feature(feature)
    if feature.type == :agent
      if @agent
#        puts "#{self.name} confirmed as being an agent."
      else
#        puts "#{self.name} converted to agent."
        @agent = true
      end
    else
      existing = @features[feature.type]
      if existing && (existing != feature)
        puts "School #{self.name} seems to have a second feature of the same type."
        puts "#{existing.name} and #{feature.name}."
      else
        @features[feature.type] = feature
      end
    end
  end

  def governance
    g = @features[:governance]
    if g
      g.ident
    else
      ""
    end
  end

  def school_type
    st = @features[:school_type]
    if st
      st.ident
    else
      ""
    end
  end

  def gender
    g = @features[:gender]
    if g
      g.name
    else
      ""
    end
  end

  def agency?
    @agent
  end

  def school_to_csv(csv_file)
    if agency?
      0
    else
      csv_file << [
        self.ident,
        self.name,
        self.gender,                      # Gender
        "",                               # Boarding type
        self.governance,                  # Governance type
        self.school_type,                 # School type
        "",                               # Intake type
        "",                               # Contact title
        "",                               # Contact initials
        "",                               # Contact forename
        "",                               # Contact Surname
        "",                               # Profession
        "",                               # Qualifications
        self.address.address1,
        self.address.address2,
        self.address.address3,
        self.address.town,
        self.address.county,
        self.address.country,
        self.address.postcode,
        self.email,
        self.url,
        self.phone_no,                    # Contact telno
        ""                                # Contact fax
      ]
      1
    end
  end

  def agency_to_csv(csv_file)
    if agency?
      csv_file << [
        self.ident,
        self.name
      ]
      1
    else
      0
    end
  end

  def agency_branch_to_csv(csv_file)
    if agency?
      csv_file << [
        self.ident,
        self.name,
        self.ident
      ]
      1
    else
      0
    end
  end

  def agency_contact_to_csv(csv_file)
    if agency?
      csv_file << [
        self.ident,
        "",                                     # Forename
        "",                                     # Surname
        self.address.address1,
        self.address.address2,
        self.address.address3,
        self.address.town,
        self.address.county,
        self.address.country,
        self.address.postcode,
        self.phone_no,
        "",                                     # Fax
        self.email,
        self.ident
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
      accumulator[:feeders] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end

  OTHER_SCHOOLS_FILENAME = "other_schools_schools.csv"
  AGENCIES_AGENCY_FILENAME = "agencies_agency.csv"
  AGENCIES_BRANCH_FILENAME = "agencies_branch.csv"
  AGENCIES_CONTACT_FILENAME = "agencies_contact_allocation.csv"

  def self.do_writing(accumulator, target_dir)
    ours = accumulator[:feeders]
    if ours
      written = 0
      csv = CSV.open(File.expand_path(
                       OTHER_SCHOOLS_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.school_to_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{OTHER_SCHOOLS_FILENAME}."
      written = 0
      csv = CSV.open(File.expand_path(
                       AGENCIES_AGENCY_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.agency_to_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{AGENCIES_AGENCY_FILENAME}."
      written = 0
      csv = CSV.open(File.expand_path(
                       AGENCIES_BRANCH_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.agency_branch_to_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{AGENCIES_BRANCH_FILENAME}."
      written = 0
      csv = CSV.open(File.expand_path(
                       AGENCIES_CONTACT_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.agency_contact_to_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{AGENCIES_CONTACT_FILENAME}."
    end
  end

end
