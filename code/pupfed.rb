#
#  Class for SB PupFed records.
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

#
#  This one is like PupFeeder, except it records the pupil's *next* school.
#  Obviously the author couldn't be bothered to think up an explanatory
#  name.
#
class SB_PupFed
  FILE_NAME = "pupfed.csv"
  REQUIRED_COLUMNS = [
    Column["PupFedIdent", :ident,             :integer],
    Column["PupOrigNum",  :pupil_ident,       :integer],
    Column["FedToIdent",  :next_school_ident, :integer],
    Column["PupFedFinal", :final,             :boolean]
  ]

  DEPENDENCIES = [
    #          Accumulator key  Record ident        Our attribute Req'd
    Dependency[:pupils,         :pupil_ident,       :pupil,       true],
    Dependency[:feeders,        :next_school_ident, :next_school, true]
  ]

  include Slurper
  include Depender


  def adjust(accumulator)
    @complete = find_dependencies(accumulator, DEPENDENCIES, false)
  end

  def wanted?
    @complete
  end

  def to_csv(csv_file)
    csv_file << [
      self.pupil_ident,
      self.next_school_ident
    ]
    1
  end

  #
  #  Set ourselves up and add ourselves to the accumulator.
  #
  def self.setup(accumulator)
    records, message = self.slurp(accumulator, false)
    if records
      #
      #  There may be more than one for a given pupil.  Take the last
      #  one chronologically, unless an earlier one is flagged as Final.
      #
      nsbpih = Hash.new
      records.each do |rec|
        if nsbpih[rec.pupil_ident]
#          puts "Duplicate next school for #{rec.pupil.name} (#{rec.pupil_ident})"
          if nsbpih[rec.pupil_ident].final
#            puts "Earlier one wins"
          else
            nsbpih[rec.pupil_ident] = rec
#            puts "Later one wins"
          end
        else
          nsbpih[rec.pupil_ident] = rec
        end
      end
      accumulator[:pupfeds] = nsbpih
      true
    else
      puts message
      false
    end
  end

  NEXT_SCHOOLS_FILENAME = "nextschools.csv"

  def self.do_writing(accumulator, target_dir)
    ours = accumulator[:pupfeds]
    if ours
      written = 0
      csv = CSV.open(File.expand_path(
                       NEXT_SCHOOLS_FILENAME,
                       target_dir),
                     "wb")
      csv << ["Pupil Id", "School Id"]
      ours.each do |key, entry|
        written += entry.to_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{NEXT_SCHOOLS_FILENAME}."
    end
  end

end
