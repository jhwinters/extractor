#
#  Class for SB Term records
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_Term
  FILE_NAME = "term.csv"
  REQUIRED_COLUMNS = [
    Column["TermIdent",       :ident,      :integer],
    Column["TermNo",          :term_no,    :integer],
    Column["TermActualStart", :start_date, :date],
    Column["TermActualEnd",   :end_date,   :date]
  ]

  DEPENDENCIES = [
    #          Accumulator key  Record ident  Our attribute   Req'd
    Dependency[:termnames,      :term_no,     :termname,      true]
  ]

  include Slurper
  include Depender


  def adjust(accumulator)
    @complete = find_dependencies(accumulator, DEPENDENCIES)
  end

  def wanted?
    @complete
  end

  def term_to_csv(csv_file)
    csv_file << [
      self.start_date.for_isams,
      self.end_date.for_isams,
      self.termname.get_name
    ]
    1
  end

  #
  #  Set ourselves up and add ourselves to the accumulator.
  #
  def self.setup(accumulator)
    records, message = self.slurp(accumulator, false)
    if records
      accumulator[:terms] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end

  MORE_TERMS = [
    ["2016-09-06", "2016-12-16", "Michaelmas"],
    ["2017-01-10", "2017-03-31", "Lent"],
    ["2017-04-25", "2017-07-07", "Summer"]
  ]

  def self.extra_terms(csv_file)
    #
    #  A few more which aren't in the SB d/b.
    #
    MORE_TERMS.each do |term|
      csv_file << term
    end
    MORE_TERMS.count
  end

  TERMS_FILENAME = "school_structure_term_dates.csv"

  def self.do_writing(accumulator, target_dir)
    ours = accumulator[:terms]
    if ours
      written = 0
      csv = CSV.open(File.expand_path(
                       TERMS_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.term_to_csv(csv)
      end
      written += self.extra_terms(csv)
      csv.close
      puts "Wrote #{written} records to #{TERMS_FILENAME}."
    end
  end

end
