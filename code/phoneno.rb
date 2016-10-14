#
#  Class for SB PhoneNo records.
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_PhoneNo
  @@accumulator = nil

  FILE_NAME = "phonenos.csv"
  REQUIRED_COLUMNS = [
    Column["Ph_ParentId",   :parent_ident, true],
    Column["Ph_Location",   :location,     false],
    Column["AdultNo",       :adult_ident,  true],
    Column["Ph_PhoneNo",    :phone_number, false]
  ]

  include Slurper

  attr_reader :start_date

  def initialize
    @complete = false
    @used_by = Hash.new
  end

  def adjust(accumulator)
    ao_records = accumulator[:adultoffspring]
    if ao_records
      relevant_adults = ao_records[self.adult_ident]
      if relevant_adults
        relevant_adults.each do |ra|
          ra.note_phoneno(self)
        end
        @complete = true
      end
    end
  end

  def wanted?
    @complete
  end

  def mark_used_by(pupil_id)
    @used_by[pupil_id] = true
  end

  def used_by?(pupil_id)
    @used_by[pupil_id] == true
  end

  def unused_by?(pupil_id)
    @used_by[pupil_id] != true
  end

  def text_version
    "#{self.location}: #{self.phone_number.as_telno}"
  end

  PRE_REQUISITES = [:adultoffspring]

  def self.setup(accumulator)
    PRE_REQUISITES.each do |pr|
      unless accumulator[pr]
        puts "Pre-requisite #{pr} missing from accumulator and needed by regpup."
        return false
      end
    end
    records, message = self.slurp(accumulator, false)
    if records
      accumulator[:phonenos] = records
      @@accumulator = accumulator
      true
    else
      puts message
      false
    end
  end

end
