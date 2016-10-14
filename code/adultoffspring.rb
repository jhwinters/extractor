#
#  Class for SB Adult Offspring records
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_AdultOffspring
  FILE_NAME = "adultoffspring.csv"
  REQUIRED_COLUMNS = [
    Column["PupOrigNum",     :pupil_ident,       :integer],
    Column["Name1",          :name1,             :string],
    Column["Name2",          :name2,             :string],
    Column["Address",        :address_string,    :string],
    Column["PostCode",       :postcode,          :string],
    Column["Relationship1",  :relationship1,     :string],
    Column["Relationship2",  :relationship2,     :string],
    Column["Primary",        :primary,           :boolean],
    Column["Report",         :report,            :boolean],
    Column["FeePayer",       :fee_payer,         :integer],
    Column["Occupation1",    :occupation1_ident, :integer],
    Column["Occupation2",    :occupation2_ident, :integer],
    Column["Notes",          :notes,             :string],
    Column["EMail1",         :email1_org,        :string],
    Column["EMail2",         :email2_org,        :string],
    Column["AdultTitle1",    :title1,            :string],
    Column["AdultTitle2",    :title2,            :string],
    Column["AdultFirst1",    :first_name1,       :string],
    Column["AdultFirst2",    :first_name2,       :string],
    Column["AdultSurname1",  :surname1,          :string],
    Column["AdultSurname2",  :surname2,          :string],
    Column["AdultGuardian",  :guardian,          :boolean],
    Column["AdultNo",        :adult_ident,       :integer],
    Column["AdultPriority",  :priority,          :integer],
    Column["Adult1Priority", :priority1,         :integer],
    Column["Adult2Priority", :priority2,         :integer]
  ]

  DEPENDENCIES = [
    #          Accumulator key  Record ident        Our attribute  Req'd
    Dependency[:occupations,    :occupation1_ident, :occupation1,  false],
    Dependency[:occupations,    :occupation2_ident, :occupation2,  false]
  ]


  include Slurper
  include Depender

  attr_reader :address, :email1, :email2

  def initialize
    @phonenos = Array.new
    @complete = false
  end

  def <=>(other)
    self.priority <=> other.priority
  end

  #
  #  Each email field should contain just the one e-mail.  Unfortunately
  #  sometimes we find that someone has put more in.
  #
  #  Separators seem to be either "; " or ",".  There may be others.
  #
  def unmangle_emails
    @email1 = ""
    @email2 = ""
    @spare_emails = Array.new
    if @email1_org != ""
      splut = @email1_org.split_emails
      #
      #  It's possible that there's nothing left.  A string like ", ;" will
      #  result in an empty array.
      #
      if splut.size == 1
        @email1 = @email1_org
      elsif splut.size > 1
        #
        #  Seem to have more than one e-mail.
        #
        @email1 = splut.shift
        splut.each do |extra_one|
          @spare_emails << extra_one
        end
      end
    end
    if @email2_org != ""
      splut = @email2_org.split_emails
      if splut.size == 1
        @email2 = @email2_org
      elsif splut.size > 1
        #
        #  Seem to have more than one e-mail.
        #
        @email2 = splut.shift
        splut.each do |extra_one|
          @spare_emails << extra_one
        end
      end
    end
  end

  def adjust(accumulator)
    pupils = accumulator[:pupils]
    if pupils
      pupil = pupils[self.pupil_ident]
      if pupil
        pupil.note_adultoffspring(self)
        @address = SB_Address.new(address_string, postcode)
        unmangle_emails
        @complete = find_dependencies(accumulator, DEPENDENCIES)
      end
    end
  end

  def wanted?
    @complete
  end

  def note_phoneno(phoneno)
    @phonenos << phoneno
#    if @pupil_ident == 122 || @pupil_ident == 1607
#      puts "Phone no for #{@pupil_ident == 122 ? "Alex" : "George"}"
#      puts "Name1: #{@name1}"
#      puts "Name2: #{@name2}"
#      puts "Phone no: #{phoneno.phone_number}"
#    end
  end

  def find_phoneno(string)
    entry = @phonenos.detect {|pn| pn.location.downcase == string.downcase}
    if entry
      entry.mark_used_by(@pupil_ident)
      entry.phone_number.as_telno
    else
      ""
    end
  end

  def home_phoneno(relation)
    result = find_phoneno("Home")
    if result.empty?
      result = find_phoneno("#{relation} Home")
      #
      #  Last ditch attempt.
      #
      if @phonenos.size == 1 ||
         (relation == "Emergency" && @phonenos.size > 0)
        entry = @phonenos[0]
        entry.mark_used_by(@pupil_ident)
        result = entry.phone_number.as_telno
      end
    end
    if result.empty?
      result = find_phoneno(relation)
    end
    result
  end

  def relations_mobile_phoneno(relation)
    result = find_phoneno("#{relation} Mobile")
    if result.empty?
      if relation == "Father" || relation == "Mother"
        result = find_phoneno("Parents Mobile")
      end
    end
    if result.empty?
      result = find_phoneno("Mobile")
    end
    result
  end

  def relations_work_phoneno(relation)
    result = find_phoneno("#{relation} Work")
    if result.empty? && relation == "Agent"
      result = home_phoneno(relation)
    end
    result
  end

  def relations_work_mobile_phoneno(relation)
    result = find_phoneno("#{relation} Work Mobile")
    if result.empty? && relation == "Agent"
      result = relations_mobile_phoneno(relation)
    end
    result
  end

  def fax_phoneno(relation)
    result = find_phoneno("#{relation} Fax")
    if result.empty?
      find_phoneno("Fax")
    end
    result
  end

  def pupil_resides
    self.guardian ? "Yes" : "No"
  end

  def get_relationship1
    @relationship1.empty? ? "Other" : @relationship1
  end

  def get_relationship2
    @relationship2.empty? ? "Other" : @relationship2
  end

  def get_surname1
    @surname1.empty? ? self.name1.split.last : @surname1
  end

  def get_surname2
    @surname2.empty? ? self.name2.split.last : @surname2
  end

  def address_array
    [
      self.address.address1,
      self.address.address2,
      self.address.address3,
      self.address.town,
      self.address.county,
      self.address.country,
      self.address.postcode
    ]
  end

  def blank_address
    ["", "", "", "", "", "", ""]
  end

  #
  #  Quite a lot of the notes contain the string "(Pupil Lives at this
  #  address)" which has clearly been added by some automated process.
  #  We don't really want it in an SOS note.
  #
  #  It also occurs in variants more than once - e.g. "addresss".
  #
  #  Once it's gone there may be just spaces left, so strip those too.
  #
  def tidied_notes
    self.notes.clean.gsub(/(\()?Pupil Lives at this address(s)?(\))?/, "").strip
  end

  def spare_phonenos_note
    self.unused_phonenos.collect {|sn| sn.text_version.clean}.join(",")
  end

  def trailing_array(contact_only = false)
    if contact_only
      [
        "",                                  # Marital status
        "No",                                # SOS contact
        "",                                  # SOS note - don't put it in again.
        "",                                  # All merges
        "No",                                # Billing merge
        "No",                                # Correspondence merges
        "No",                                # Report merge
        "Yes"                                # Contact only
      ]
    else
      [
        "",                                  # Marital status
        "No",                                # SOS contact
        self.tidied_notes,                   # SOS note
        "",                                  # All merges
        self.fee_payer == 1 ? "Yes" : "No",  # Billing merge
        self.primary ? "Yes" : "No",         # Correspondence merges
        self.report ? "Yes" : "No",          # Report merge
        "No"                                 # Contact only
      ]
    end
  end

  def to_csv(csv_file)
    written = 0
    #
    #  Need to write one record for each known contact, trying to
    #  identify mother and father as far as is possible.  Whether
    #  or not an individual can be identified, he or she still gets
    #  an output record.
    #
    #  Each actual address is taken to be a home address, but we may
    #  also generate a Work record, if we have any work contact info.
    #
    #  We now save our proposed entries in an array temporarily,
    #  whilst we decide whether to add any spare phone nos.
    #
    entries = Array.new
    unless self.name1.empty?
      an_agent = (self.get_relationship1 == "Agent")
      entries <<
      [
        self.pupil_ident,
        an_agent ? "Work" : "Home",
        self.get_relationship1,
        self.pupil_resides,
        self.title1,
        "",                                  # Name initials
        self.first_name1,
        "",                                  # Middle names
        self.get_surname1
      ] +
      self.address_array +
      [
        an_agent ? self.relations_work_phoneno(self.relationship1) : self.home_phoneno(self.relationship1),
        an_agent ? self.relations_work_mobile_phoneno(self.relationship1) : self.relations_mobile_phoneno(self.relationship1),
        self.email1,
        self.fax_phoneno(self.relationship1),
        self.occupation1 ? self.occupation1.name : ""
      ] +
      self.trailing_array
      written += 1
      #
      #  Can we also get a work entry for this individual?  Don't bother
      #  for agents.
      #
      work_phoneno = relations_work_phoneno(self.relationship1)
      work_mobile_phoneno = relations_work_mobile_phoneno(self.relationship1)
      unless an_agent || (work_phoneno.empty? && work_mobile_phoneno.empty?)
        entries <<
        [
          self.pupil_ident,
          "Work",
          self.get_relationship1,
          "No",
          self.title1,
          "",                                  # Name initials
          self.first_name1,
          "",                                  # Middle names
          self.get_surname1
        ] +
        self.blank_address +
        [
          work_phoneno,
          work_mobile_phoneno,
          "",
          self.fax_phoneno(self.relationship1),
          ""             # Don't bother putting occupation a 2nd time
        ] +
        self.trailing_array(true)
        written += 1
      end
    end
    unless self.name2.empty?
      an_agent = (self.get_relationship2 == "Agent")
      entries <<
      [
        self.pupil_ident,
        an_agent ? "Work" : "Home",
        self.get_relationship2,
        self.pupil_resides,
        self.title2,
        "",                                  # Name initials
        self.first_name2,
        "",                                  # Middle names
        self.get_surname2
      ] +
      self.address_array +
      [
        #
        #  That relationship1 in the next line is not a typo.  Home phone
        #  numbers are shared.
        #
        an_agent ? self.relations_work_phoneno(self.relationship2) : self.home_phoneno(self.relationship1),
        an_agent ? self.relations_work_mobile_phoneno(self.relationship2) : self.relations_mobile_phoneno(self.relationship2),
        self.email2,
        self.fax_phoneno(self.relationship2),
        self.occupation2 ? self.occupation2.name : ""
      ] +
      self.trailing_array
      written += 1
      #
      #  Can we also get a work entry for this individual?
      #
      work_phoneno = relations_work_phoneno(self.relationship2)
      work_mobile_phoneno = relations_work_mobile_phoneno(self.relationship2)
      unless an_agent || (work_phoneno.empty? && work_mobile_phoneno.empty?)
        entries <<
        [
          self.pupil_ident,
          "Work",
          self.get_relationship2,
          "No",
          self.title2,
          "",                                  # Name initials
          self.first_name2,
          "",                                  # Middle names
          self.get_surname2
        ] +
        self.blank_address +
        [
          work_phoneno,
          work_mobile_phoneno,
          "",
          self.fax_phoneno(self.relationship2),
          ""             # Don't bother putting occupation a 2nd time
        ] +
        self.trailing_array(true)
        written += 1
      end
    end
    if entries.size > 0
      spn = spare_phonenos_note
      unless spn.empty?
        #
        #  Only need to add this to one contact record, because they
        #  will all appear on the same screen.  If we add it more than
        #  once it will just be repeated on screen.
        #
        existing = entries[0][23]
        if existing.empty?
          entries[0][23] = spn
        else
#          puts "Adding #{spn} to #{existing}"
          entries[0][23] = "#{existing} - #{spn}"
        end
      end
      entries.each do |entry|
        csv_file << entry
      end
    end
    written
  end

  def unused_phonenos
    @phonenos.select {|pn| pn.unused_by?(@pupil_ident)}
  end

  def unused_emails
    @spare_emails
  end

  #
  #  Set ourselves up and add ourselves to the accumulator.
  #
  PRE_REQUISITES = [:pupils]

  def self.setup(accumulator)
    PRE_REQUISITES.each do |pr|
      unless accumulator[pr]
        puts "Pre-requisite #{pr} missing from accumulator and needed by adultoffspring."
        return false
      end
    end
    records, message = self.slurp(accumulator, false)
    if records
      #
      #  There may be more than one adultoffspring record for a given
      #  adult_ident, and we need to keep all of them.  This hash is
      #  used subsequently only to add telephone numbers.
      #
      aohash = Hash.new
      records.each do |record|
        aohash[record.adult_ident] ||= Array.new
        aohash[record.adult_ident] << record
      end
      accumulator[:adultoffspring] = aohash
      SB_Address.report_most
      true
    else
      puts message
      false
    end
  end

end
