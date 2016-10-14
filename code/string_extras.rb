#
#  Extra facilities for manipulating strings.
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class String
  def clean
    #
    #  Microsoft Excel can't cope with carriage returns or line feeds,
    #  in strings within CSV files.  Strip them out.
    #
    self.gsub(/[\n\r]/, " ")
  end

  def split_emails
    self.clean.gsub(" @", "@").
               split(/;|,| /).
               collect {|s| s.strip}.
               select {|s| !s.empty?}
  end

  #
  #  We put telephone numbers into fields within Excel.  We regard them
  #  as strings, but if they lack any spaces then Excel arbitrarily decides
  #  that they are actually numbers, and strips off the leading 0.
  #
  #  Try to prevent that.
  #
  def as_telno
    #
    #  Only need to do anything if we start with a 0.
    #
    if /^0/ =~ self
      fixed = self
      #
      #  Deal with some specific number formats.
      #
      temp = self.gsub(/\s+/, "")
      if temp.size == 11
        if /02[03489]/ =~ temp[0,3]
          #
          #  London 020 NNNN NNNN and friends.
          #
          fixed = "#{temp[0,3]} #{temp[3,4]} #{temp[7,4]}"
        elsif temp[0,3] == "011"
          #
          #  Reading and similar
          #  0118 NNN NNNN
          #
          fixed = "#{temp[0,4]} #{temp[4,3]} #{temp[7,4]}"
        elsif temp[0,3] == "010"
          #
          #  This isn't a valid number.  010 used to be the international
          #  access code, now replaced by 00.  There are no valid numbers
          #  now which being 010, but there are some in our d/b.  Leave
          #  them alone.
          #
        elsif /01[234569]1/ =~ temp[0,4]
          #
          #  Birmingham, Edinburgh etc.
          #
          fixed = "#{temp[0,4]} #{temp[4,3]} #{temp[7,4]}"
        elsif (temp[0,2] == "01") || (temp[0,2] == "07")
          #
          #  Other geographical number or mobile
          #  01235 NNNNNN
          #  07787 NNNNNN
          #
          fixed = "#{temp[0,5]} #{temp[5,6]}"
        end
      end
      if fixed == self
        #
        #  Haven't changed it.  Just need to check we are still
        #  producing something with a space.
        #
        unless /\d \d/ =~ fixed
          if /^001/ =~ fixed
            # North American Number Area
            index = 3
          elsif /^00/ =~ fixed
            # Other international
            index = 4
          else
            # Everyone else.
            index = 5
          end
          if index > fixed.length
            index = fixed.length
          end
          fixed.insert(index, " ")
        end
      end
#      unless fixed == self
#        puts "Converted #{self} to #{fixed}"
#      end
      fixed
    else
      self
    end
  end
end
