#
#  Class for SB PupTreatment records.
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_PupTreatment
  FILE_NAME = "putreatment.csv"
  REQUIRED_COLUMNS = [
    Column["PuTrIdent",     :ident,           :integer],
    Column["PuTrDate",      :date,            :date],
    Column["PuTrTime",      :time,            :time],
    Column["PupOrigNum",    :pupil_ident,     :integer],
    Column["PuTrComplaint", :complaint,       :string],
    Column["PuTreatment",   :treatment,       :string]
  ]

  DEPENDENCIES = [
    #          Accumulator key  Record ident      Our attribute Req'd
    Dependency[:pupils,         :pupil_ident,     :pupil,       true]
  ]

  include Slurper
  include Depender


  def adjust(accumulator)
    @complete = find_dependencies(accumulator, DEPENDENCIES)
  end

  def wanted?
    @complete
  end

  def treatment_to_csv(csv_file)
    #
    #  Some of the treatment logs exceed iSAMS's arbitrary limit of 1000
    #  characters.  For these, break it into chunks and produce several
    #  entries.
    #
    treatment_text = self.treatment.clean
    if treatment_text.size > 1000
      chunks = treatment_text.scan(/\S.{1,995}(?!\S)/)
      chunks.each_with_index do |chunk, i|
        csv_file << [
          self.pupil_ident,
          "SB Treatment History",
          self.date.for_isams,
          self.time.strftime("%H:%M"),
          self.complaint.clean + " (part #{i + 1})",
          chunk
        ]
      end
      chunks.size
    else
      csv_file << [
        self.pupil_ident,
        "SB Treatment History",
        self.date.for_isams,
        self.time.strftime("%H:%M"),
        self.complaint.clean,
        treatment_text
      ]
      1
    end
  end

  #
  #  Set ourselves up and add ourselves to the accumulator.
  #
  def self.setup(accumulator)
    records, message = self.slurp(accumulator, false)
    if records
      accumulator[:puptreatments] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end

  TREATMENTS_FILENAME = "sanatorium_diary.csv"

  def self.do_writing(accumulator, target_dir)
    ours = accumulator[:puptreatments]
    if ours
      written = 0
      csv = CSV.open(File.expand_path(
                       TREATMENTS_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.treatment_to_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{TREATMENTS_FILENAME}."
    end
  end

end
