#
#  Class for SB Sibling records.
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

#
#  Note that for each sibling relationship, there exist two records
#  in SB's database.
#
#  A is related to B
#  B is related to A
#
#  The sample code provided by iSAMS indicates that they also want
#  two records in their table.
#
#  For three pupils in the same family, you get:
#
#  A is related to B
#  A is related to C
#  B is related to A
#  B is related to C
#  C is related to A
#  C is related to B
#
class SB_Sibling
  FILE_NAME = "siblings.csv"
  REQUIRED_COLUMNS = [Column["PupOrigNum", :left_ident,  true],
                      Column["Sibling",    :right_ident, true]]

  DEPENDENCIES = [
    #          Accumulator key  Record ident    Our attribute   Req'd
    Dependency[:pupils,         :left_ident,    :left_pupil,    true],
    Dependency[:pupils,         :right_ident,   :right_pupil,   true]
  ]

  include Slurper
  include Depender


  def adjust(accumulator)
    @complete = find_dependencies(accumulator, DEPENDENCIES)
    if @complete
      left_pupil.note_right_sibling(right_pupil)
      right_pupil.note_left_sibling(left_pupil)
    end
  end

  def wanted?
    @complete
  end

  def sibling_to_csv(csv_file)
    csv_file << [self.left_ident, self.right_ident]
    1
  end

  def partner?(other)
    self.left_ident == other.right_ident &&
      self.right_ident == other.left_ident
  end

  #
  #  Set ourselves up and add ourselves to the accumulator.
  #
  def self.setup(accumulator)
    records, message = self.slurp(accumulator, false)
    if records
      #
      #  Can't store these as a hash, because the only useful key
      #  may be repeated in different records.  There is a unique
      #  key, but it doesn't relate to anything.
      #
      accumulator[:siblings] = records
      true
    else
      puts message
      false
    end
  end

  SIBLINGS_FILENAME = "pupil_data_siblings.csv"

  def self.do_writing(accumulator, target_dir)
    ours = accumulator[:siblings]
    if ours
      written = 0
      csv = CSV.open(File.expand_path(
                       SIBLINGS_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |entry|
        written += entry.sibling_to_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{SIBLINGS_FILENAME}."
    end
  end

  def self.do_stats(accumulator)
    ours = accumulator[:siblings]
    if ours
      #
      #  Check that every entry has an equal and opposite entry.
      #
      ours.each do |entry|
        #
        #  This is slow, but no easy way to speed it up.
        #
        partner = ours.find { |candidate| entry.partner?(candidate) }
        unless partner
          puts "Imbalanced sibling relationship for #{entry.left_ident} and #{entry.right_ident}."
          puts "#{entry.left_pupil.name} and #{entry.right_pupil.name}."
        end
      end
    end
  end

end
