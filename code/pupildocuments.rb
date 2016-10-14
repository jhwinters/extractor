#
#  Class for SB_PupilDocument records.
#
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class SB_PupilDocument
  FILE_NAME = "pupildocuments.csv"
  REQUIRED_COLUMNS = [
    Column["PupilDocumentIdent", :ident,       :integer],
    Column["DocLink",            :link,        :string],
    Column["PupOrigNum",         :pupil_ident, :integer]
  ]

  DEPENDENCIES = [
    #          Accumulator key  Record ident      Our attribute Req'd
    Dependency[:pupils,         :pupil_ident,     :pupil,       true],
  ]

  include Slurper
  include Depender

  DOC_SRC_DIR  = File.expand_path("../PrepSchool/", File.dirname(__FILE__))
  DOC_DEST_DIR = File.expand_path("../DocumentDataImport/", File.dirname(__FILE__))

  def adjust(accumulator)
    @complete = find_dependencies(accumulator, DEPENDENCIES)
    if @complete
      splut = @link.split("#")
      #
      #  It's seems it is just possible for there to be no
      #  description.
      #
      if splut.size == 0
        puts "Can't handle \"#{@link}\"."
        @complete = false
      elsif splut.size == 1
        @description = "None available"
        @full_raw_filename = splut[0].gsub("\\", "/")
      else
        @description = splut[0]
        @full_raw_filename = splut[1].gsub("\\", "/")
      end
    end
    if @complete
      #
      #  Directory name must begin U:/, but we don't want that bit.
      #
      if /^U:\// =~ @full_raw_filename
        @full_raw_filename = @full_raw_filename.gsub("U:/", "")
        @leafname = File.basename(@full_raw_filename)
        @sourcename = File.expand_path(@full_raw_filename, DOC_SRC_DIR)
        if !File.exists?(@sourcename)
          puts "File \"#{@sourcename}\" does not seem to exist."
          @complete = false
        end
#        puts "Description \"#{@description}\"."
#        puts "Full raw filename \"#{@full_raw_filename}\"."
#        puts "Leaf name \"#{@leafname}\"."
      else
        puts "Can't process file \"#{@full_raw_filename}\"."
        @complete = false
      end
    end
  end

  def wanted?
    @complete
  end

  def pupil_dir_name
    "#{self.pupil_ident}.#{self.pupil.first_name} #{self.pupil.surname}"
  end

  def pupil_dir_full_path
    File.expand_path(pupil_dir_name, DOC_DEST_DIR)
  end

  def target_leafname
    "#{self.pupil_ident}.#{@leafname}"
  end

  def destname
    File.expand_path(target_leafname, pupil_dir_full_path)
  end

  #
  #  Make sure our pupil's directory exists.
  #
  def ensure_directory
    unless Dir.exist?(pupil_dir_full_path)
      Dir.mkdir(pupil_dir_full_path)
    end
  end

  #
  #  Copy the corresponding file from source to destination, creating
  #  any required directories as we do so.
  #
  #  We have already checked that the source file exists, and have its
  #  name.
  #
  def copyfile
    ensure_directory
    FileUtils.cp(@sourcename, destname)
    true
  end

  def write_csv(csv_file)
    if copyfile
      csv_file << [
        self.pupil_ident,
        @description,
        "D:\\iSAMS\\Abingdon\\iSAMS.Files\\",
        "DocumentDataImport\\#{pupil_dir_name}",
        target_leafname,
        "SB Document"
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
      accumulator[:pupildocuments] = records.collect {|r| [r.ident, r]}.to_h
      true
    else
      puts message
      false
    end
  end

  DOCUMENTS_FILENAME = "documents_document.csv"

  def self.process_documents(accumulator, target_dir)
    ours = accumulator[:pupildocuments]
    if ours
      written = 0
      csv = CSV.open(File.expand_path(
                       DOCUMENTS_FILENAME,
                       target_dir),
                     "wb")
      ours.each do |key, entry|
        written += entry.write_csv(csv)
      end
      csv.close
      puts "Wrote #{written} records to #{DOCUMENTS_FILENAME}."
    end
  end

end
