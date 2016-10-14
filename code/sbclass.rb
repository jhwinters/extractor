#
#  Class for SB Class records.
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_Class
  FILE_NAME = "class.csv"
  REQUIRED_COLUMNS = [
    Column["ClassIdent", :ident,       :integer],
    Column["ClassName",  :name,        :string],
    Column["YearIdent",  :year_ident,  :integer],
    Column["StaffIdent", :staff_ident, :integer]
  ]

  DEPENDENCIES = [
    #          Accumulator key  Record ident  Our attribute   Req'd
    Dependency[:years,          :year_ident,  :year,          true]
  ]

  include Slurper
  include Depender


  def adjust(accumulator)
    @complete = find_dependencies(accumulator, DEPENDENCIES)
  end

  def wanted?
    @complete
  end

  def class_to_csv(csv_file)
    csv_file << [
      self.name,
      self.year.effective_isams_year,
      self.staff_ident,
      ""
    ]
    1
  end

  #
  #  Set ourselves up and add ourselves to the accumulator.
  #
  def self.setup(accumulator)
    records, message = self.slurp(accumulator, false)
    if records
      accumulator[:classes] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end

  FORMS_FILENAME = "school_structure_forms.csv"

  def self.do_writing(accumulator, target_dir)
    ours = accumulator[:classes]
    if ours
      written = 0
      csv = CSV.open(File.expand_path(
                       FORMS_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.class_to_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{FORMS_FILENAME}."
    end
  end

end
