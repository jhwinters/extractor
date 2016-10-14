#
#  Class for SB Passcode records.
#
#  These don't actually come from SchoolBase, but from Pass.
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_Passcode
  FILE_NAME = "passcodes.csv"
  REQUIRED_COLUMNS = [
    Column["Name", :name,         :string],
    Column["Code", :finance_code, :string]
  ]

  include Slurper

  def adjust(accumulator)
    @complete = true
  end

  def wanted?
    @complete
  end

  #
  #  Set ourselves up and add ourselves to the pupil records.
  #
  def self.setup(accumulator)
    records, message = self.slurp(accumulator, false)
    if records
      #
      #  Now for each of our records we need to try to find a matching
      #  pupil record.  Unfortunately this is inefficient because the
      #  pupils aren't indexed by name.  Nothing to stop us indexing
      #  them though.
      #
      pupils = accumulator[:pupils]
      pupil_hash = Hash.new
      pupils.each do |key, pupil|
        if pupil.current?
          surname = pupil.exam_surname
          forename = pupil.exam_forenames.split(" ")[0]
          hash_key = "#{surname}, #{forename}"
  #        puts hash_key
          if pupil_hash[hash_key]
            #
            #  Already exists, therefore ambiguous
            #
#            puts "#{hash_key} is ambiguous."
            pupil_hash[hash_key] = :ambiguous
          else
            pupil_hash[hash_key] = pupil
          end
        end
      end
      #
      #  Now try to match up our records with pupil records.
      #
      match_count = 0
      ambiguous_count = 0
      notfound_count = 0
      rejected_count = 0
      records.each do |pcrec|
        splut = pcrec.name.split(",")
        surname = splut[0]
        if splut[1]
          forename = splut[1].split(" ")[0]
        else
          forename = ""
        end
        hash_key = "#{surname}, #{forename}"
        pupil = pupil_hash[hash_key]
        if pupil
          if pupil == :ambiguous
            puts "#{pcrec.name} matches ambiguously."
            ambiguous_count += 1
          else
            if pupil.note_finance_code(pcrec.finance_code)
#              puts "#{pcrec.name} matches #{pupil.name}."
              match_count += 1
            else
              puts "#{pupil.name} rejected #{pcrec.name} as duplicate."
              rejected_count += 1
            end
          end
        else
          puts "#{pcrec.name} doesn't match."
          notfound_count += 1
        end
      end
      puts "Matched #{match_count} passcodes."
      puts "#{ambiguous_count} were ambiguous (two pupil records with same name)."
      puts "#{notfound_count} didn't match."
      puts "#{rejected_count} were rejected (two passcode records with same name)."
      true
    else
      puts message
      false
    end
  end
end
