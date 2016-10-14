#
#  Class for SB AsScore records.
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_AsScore
  FILE_NAME = "asscore.csv"
  REQUIRED_COLUMNS = [
    Column["AsScoreIdent", :ident,          :integer],
    Column["AsScore",      :score,          :integer],
    Column["AsIdent",      :as_ident,       :integer],
    Column["AsGPartIdent", :as_gpart_ident, :integer]
  ]

  DEPENDENCIES = [
    #          Accumulator key  Record ident  Our attribute   Req'd
    Dependency[:as,             :as_ident,    :as,            true]
  ]

  include Slurper
  include Depender


  def adjust(accumulator)
    @complete = find_dependencies(accumulator, DEPENDENCIES, false)
#    unless @complete
#      if @score == 0 || @score == nil
#        puts "Dropping zero score"
#      else
#        puts "Dropping non-zero one (#{@ident})"
#      end
#    end
  end

  def wanted?
    @complete && @score != nil && @score != 0
  end

  def result_to_csv(csv_file)
    if self.score
      csv_file << [
        self.as_ident,
        "Exam mark",
        self.score
      ]
      1
    else
      0
    end
  end

  #
  #  Set ourselves up and add ourselves to the accumulator.
  #
  def self.setup(accumulator)
    records, message = self.slurp(accumulator, false)
    if records
      accumulator[:asscores] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end

  RESULT_ELEMENTS_FILENAME = "reports_and_assessments_result_elements.csv"
  RESULTS_FILENAME = "reports_and_assessments_result.csv"

  def self.do_writing(accumulator, target_dir)
    ours = accumulator[:asscores]
    if ours
      written = 0
      csv = CSV.open(File.expand_path(
                       RESULTS_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.result_to_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{RESULTS_FILENAME}."
      written = 0
      csv = CSV.open(File.expand_path(
                       RESULT_ELEMENTS_FILENAME,
                       target_dir),
                     "wb")
      csv << ["Exam mark", "Rep"]
      written = 1
      csv.close
      puts "Wrote #{written} records to #{RESULT_ELEMENTS_FILENAME}."
    end
  end

end
