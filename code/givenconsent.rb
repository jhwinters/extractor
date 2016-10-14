#
#  Class for SB GivenConsent records
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_GivenConsent
  FILE_NAME = "givenconsent.csv"
  REQUIRED_COLUMNS = [
    Column["GivenConsentIdent", :ident, :integer],
    Column["ConsentName",       :name,  :string]
  ]

  include Slurper

  def consent_given?
    @status == :consent_given
  end

  def adjust(accumulator)
    #
    #  The SB table doesn't actually contain the crucial positive/negative
    #  information, except in the form of words.  We therefore need to
    #  hard code it here.
    #
    @complete = true
    case self.ident
    when 0
      @status = :unknown

    when 1
      @status = :consent_given

    when 2
      @status = :consent_withheld

    when 3
      @status = :contact_parent

    else
      puts "Don't understand consent value of #{@status}."
      @complete = false
    end

  end

  def wanted?
    @complete
  end

  def consenttype_to_csv(csv_file)
    csv_file << [
      self.name
    ]
    1
  end

  def consenttype_to_choices(csv_file)
    csv_file << [
      "Consent type",
      self.name
    ]
    1
  end

  #
  #  Set ourselves up and add ourselves to the accumulator.
  #
  def self.setup(accumulator)
    records, message = self.slurp(accumulator, false)
    if records
      accumulator[:givenconsents] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end

  def self.write_select_values(accumulator, csv_file)
    written = 0
    ours = accumulator[:givenconsents]
    if ours
      ours.each do |key, entry|
        written += entry.consenttype_to_choices(csv_file)
      end
    end
    written
  end

end
