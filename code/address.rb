#
#  Class for constructed address records.
#  Copyright (C) 2016 Abingdon School
#  SEE COPYING AND LICENCE IN THE ROOT DIRECTORY OF THE APPLICATION
#  FOR MORE INFORMATION
#

class SB_Address

  def extract(dictionary)
    #
    #  Try to find a word from the dictionary (case insensitive) as
    #  one of the entries in @splut, and if found then remove it and
    #  return it, un-modified.
    #
    #  Otherwise return an empty string.
    #
    @splut.each do |line|
      if dictionary.include?(line.downcase)
        @splut.delete(line)
        return line
      end
    end
    return ""
  end

  KNOWN_COUNTRIES = [
    "australia",
    "belgium",
    "bermuda",
    "canada",
    "china",
    "cyprus",
    "dominican republic",
    "fiji",
    "france",
    "georgia",
    "germany",
    "ghana",
    "hongkong",
    "hong kong",
    "hong kong sar",
    "india",
    "iran",
    "ireland",
    "israel",
    "italy",
    "kenya",
    "korea",
    "maldives",
    "new zealand",
    "nigeria",
    "philippines",
    "poland",
    "republic of korea",
    "russia",
    "russian federation",
    "saudi arabia",
    "scotland",
    "singapore",
    "south korea",
    "s. korea",
    "spain",
    "switzerland",
    "tanzania",
    "thailand",
    "the netherlands",
    "uae",
    "uk",
    "ukraine",
    "usa",
    "u.s.a.",
    "wales"
  ]

  KNOWN_COUNTIES = [
    "bedfordshire",
    "beds",
    "berkshire",
    "berks",
    "buckinghamshire",
    "bucks",
    "cambridgeshire",
    "cambs",
    "cheshire",
    "cleveland",
    "cornwall",
    "county dublin",
    "cumbria",
    "devon",
    "dorset",
    "east sussex",
    "east yorkshire",
    "essex",
    "fife",
    "glos",
    "glous",
    "gloucestershire",
    "gwynedd",
    "hampshire",
    "hants",
    "herefordshire",
    "hertfordshire",
    "herts",
    "isle of wight",
    "lancashire",
    "lancs",
    "lincolnshire",
    "lincs",
    "kent",
    "middlesex",
    "mddx",
    "north devon",
    "north yorkshire",
    "north yorks",
    "northamptonshire",
    "northants",
    "northumberland",
    "oxfordshire",
    "oxofordshire",
    "oxon",
    "shropshire",
    "salop",
    "somerset",
    "south yorkshire",
    "staffordshire",
    "staffs",
    "suffolk",
    "surrey",
    "sussex",
    "tyne & wear",
    "tyne and wear",
    "warks",
    "warwickshire",
    "west berkshire",
    "west sussex",
    "west yorkshire",
    "wiltshire",
    "wilts",
    "wirral",
    "worcs",
    "worcestershire"
  ]

  attr_reader :postcode,
              :address1,
              :address2,
              :address3,
              :town,
              :county,
              :country

  @@most_lines = 0

  #
  #  Passed a SB style address (one long string with line breaks)
  #  we try to break it up intelligently into its component parts.
  #
  #  iSAMS expects the following:
  #
  #    Address 1
  #    Address 2
  #    Address 3
  #    Town
  #    County
  #    Country
  #    Postcode
  #
  #  It makes sense for us to provide corresponding methods.
  #  Where an address is extra long, we need to 
  #
  def initialize(address, postcode)
    @postcode = postcode
    @address1 = ""
    @address2 = ""
    @address3 = ""
    @town     = ""

    @empty = true
    #
    #  Discovered that Furlong's address strings usually have lines
    #  separated with CRLF, but sometimes with just CR, and for all
    #  I know, perhaps sometimes just LF.  Try to cope with all cases.
    #
    @splut = address.split(/\r\n|\r|\n/).collect {|line| line.strip}
    num_lines = @splut.count
#    puts @splut.inspect
    if num_lines > @@most_lines
      @@most_lines = num_lines
    end
    if num_lines > 0
      @empty = false
    end
    #
    #  At its simplest, our algorithm is simply to take the last line
    #  of an address as being the county, the one before as the town
    #  and then everything else goes in lines 1,2,3, but...
    #
    #  Sometimes the county is simply missing.
    #  Sometimes there is a country too.
    #  Sometimes there are too many lines - up to 8.
    #
    @country = extract(KNOWN_COUNTRIES)
    if @country.empty?
      #
      #  Some bright spark seems to have been putting country names
      #  in the postcode field.
      #
      if KNOWN_COUNTRIES.include?(@postcode.downcase.strip)
        @country = @postcode
        @postcode = ""
      end
    end
    @county  = extract(KNOWN_COUNTIES)
    num_lines = @splut.count
    if num_lines > 0
      @town = @splut.pop
    end
    num_lines = @splut.count
    if num_lines >= 1
      @address1 = @splut[0]
      if num_lines >= 2
        @address2 = @splut[1]
        if num_lines == 3
          @address3 = @splut[2]
        else
          #
          #  More than 3.
          #
          @address3 = @splut[2..-1].join(", ")
        end
      end
    end
#    puts "Address:"
#    puts "Address1: #{self.address1}"
#    puts "Address2: #{self.address2}"
#    puts "Address3: #{self.address3}"
#    puts "Town:     #{self.town}"
#    puts "County:   #{self.county}"
#    puts "Country:  #{self.country}"
#    puts "Postcode: #{self.postcode}"
  end

  def empty?
    @empty
  end

  def self.report_most
    puts "Longest address is #{@@most_lines} lines."
  end

end
