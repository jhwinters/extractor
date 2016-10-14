#
#  Class for SB Company records.
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_Company
  FILE_NAME = "company.csv"
  REQUIRED_COLUMNS = [
    Column["CompanyId",     :ident,          :integer],
    Column["Company",       :name,           :string],
    Column["ComAddress",    :address_string, :string],
    Column["ComPostCode",   :postcode,       :string],
    Column["ComCity",       :city,           :string],
    Column["ComPhone",      :phone,          :string],
    Column["ComFax",        :fax,            :string],
    Column["ComContact",    :contact,        :string],
    Column["ComDateChange", :date_change,    :date]
  ]

  include Slurper


  def adjust(accumulator)
    @address = SB_Address.new(address_string, postcode)
  end

  def wanted?
    true
  end

  #
  #  Set ourselves up and add ourselves to the accumulator.
  #
  def self.setup(accumulator)
    records, message = self.slurp(accumulator, false)
    if records
      accumulator[:companies] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end
end
