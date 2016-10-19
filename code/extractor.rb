#!/usr/bin/env ruby
#
#  SchoolBase => iSAMS data extractor.
#  
#  This program exists to move certain categories of data from
#  an existing SchoolBase installation into the format required
#  by iSAMS for loading into a new iSAMS system.
#
#  Author: John Winters <john.winters@abingdon.org.uk>
#  Copyright (C) 2016 Abingdon School
#  Portions copyright (C) 2014-16 John Winters
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

#
#  The data extraction is a two-phase process:
#
#  1) Dump SB database tables to CSV files
#  2) Process said files to produce iSAMS required format
#
#  The tool can be invoked to do either or both stages in order
#  to allow development remote from the source database.
#
#  The progam expects to find writable directories called csv, yml
#  and output in the parent directory of the one in which it resides.
#
#  parent ----- code ---- extractor.rb
#         \---- csv
#          \--- output
#           \-- yml
#

require 'tempfile'
require 'csv'
require 'optparse'
require 'ostruct'
require 'charlock_holmes'
require 'time'
require 'pathname'

#
#  And stuff local to this program
#
require_relative 'string_extras'
require_relative 'date_extras'
require_relative 'slurper'
require_relative 'depender'
require_relative 'years'
require_relative 'days'
require_relative 'address'
require_relative 'feeder'
require_relative 'feederfeature'
require_relative 'feederfeaturelink'
require_relative 'pupil'
require_relative 'adultoffspring'
require_relative 'phoneno'
require_relative 'regtype'
require_relative 'regpup'
require_relative 'asheaders'
require_relative 'aspartreporttype'
require_relative 'asgroups'
require_relative 'asgroupparts'
require_relative 'asheaderparts'
require_relative 'as'
require_relative 'ascomment'
require_relative 'asgrade'
require_relative 'asscore'
require_relative 'nationality'
require_relative 'language'
require_relative 'religion'
require_relative 'ethnicity'
require_relative 'sbclass'
require_relative 'house'
require_relative 'stageofprospect'
require_relative 'boardertype'
require_relative 'staff'
require_relative 'stageofprospect'
require_relative 'sibling'
require_relative 'passporttype'
require_relative 'h1'
require_relative 'h2'
require_relative 'checkpoint'
require_relative 'pupintakecheck'
require_relative 'termname'
require_relative 'term'
require_relative 'tutorgroup'
require_relative 'stabcovreason'
require_relative 'staffabsence'
require_relative 'dbdistributiontype'
require_relative 'dbtypecategory'
require_relative 'dbtype'
require_relative 'dbook'
require_relative 'medcondition'
require_relative 'pupmedcondition'
require_relative 'puptreatment'
require_relative 'treatment'
require_relative 'vacsite'
require_relative 'nurseall'
require_relative 'vaccination'
require_relative 'givenconsent'
require_relative 'consenttype'
require_relative 'medcheck'
require_relative 'medcheckpup'
require_relative 'company'
require_relative 'pupfeeder'
require_relative 'subjects'
require_relative 'groups'
require_relative 'country'
require_relative 'pupcategories'
require_relative 'features'
require_relative 'pupilfeatures'
require_relative 'occupation'
require_relative 'specialneed'
require_relative 'pupsn'
require_relative 'passcodes'
require_relative 'pupfed'
require_relative 'application'
require_relative 'pupapp'
require_relative 'pupildocuments'

require_relative 'photodumper'

CSV_DIR    = File.expand_path("../csv/",    File.dirname(__FILE__))
OUTPUT_DIR = File.expand_path("../output/", File.dirname(__FILE__))
SQL_DIR    = File.expand_path("../sql/",    File.dirname(__FILE__))
YML_DIR    = File.expand_path("../yml/",    File.dirname(__FILE__))

UTILITY    = "/usr/bin/isql"

class EscapedField
  def initialize(name)
    @name = name
  end

  def to_s
    @name
#    "REPLACE(#{@name}, '\"', '\"\"') AS #{@name}"
  end
end

class SchoolBaseTable
  @@password = nil

  def initialize(table_name, fields)
    @table_name = table_name
    @fields = []
    if fields == :all
      @get_all = true
    else
      @get_all = false
      if fields.is_a?(String)
        @fields << fields
      elsif fields.is_a?(Array)
        fields.each do |field|
          @fields << field
        end
      else
        raise "Can't cope with \"fields\" as a #{fields.class}"
      end
    end
  end

  def columns
    if @get_all
      "*"
    else
      @fields.collect {|f| f.to_s}.join(",")
    end
  end

  def dump
    get_password unless @@password
    csv = CSV.open(File.expand_path(@table_name + ".csv", CSV_DIR), "wb")
    client = TinyTds::Client.new(
      username: "youruser",             # Adjust
      password: @@password,
      host: "127.0.0.1",                # Adjust
      port: 1433,                       # May need to adjust
      database: "Schoolbase")
    result = client.execute("SELECT #{columns} FROM [#{@table_name}];")
    fields = result.fields
    csv << fields
    result.each do |row|
      csv << fields.collect {|f| row[f]}
    end
    client.close
    csv.close
  end

  def get_password
    if ENV["PASSWORD"]
      @@password = ENV["PASSWORD"]
    else
      begin
        print 'Password: '
        # We hide the entered characters before to ask for the password
        system 'stty -echo'
        @@password = $stdin.gets.chomp
        system 'stty echo'
      rescue NoMethodError, Interrupt
        # When the process is exited, we display the characters again
        # And we exit
        system 'stty echo'
        exit
      end
      puts ""
    end
  end

  TABLES = [
    SchoolBaseTable.new("adultoffspring",
                        [
                         "PupOrigNum",
                         "Name1",
                         "Name2",
                         "Address",
                         "PostCode",
                         "Relationship1",
                         "Relationship2",
                         "[Primary]",       # Primary is a SQL keyword.
                         "Report",
                         "FeePayer",
                         "Occupation1",
                         "Occupation2",
                         EscapedField.new("Notes"),
                         "PTag1",
                         "PTag2",
                         "PAddressName",
                         "Salutation",
                         "EMail2",
                         "EMail1",
                         "AdultAllowDist",
                         "AdultAllowE1",
                         "AdultAllowE2",
                         "AdultTitle1",
                         "AdultTitle2",
                         "AdultFirst1",
                         "AdultFirst2",
                         "AdultSurname1",
                         "AdultSurname2",
                         "AdultGuardian",
                         "AdultAdmissions",
                         "AdCurrent",
                         "AdultPriority",
                         "AdultMoveMarker",
                         "AdultNo",
                         "Adult1Priority",
                         "Adult2Priority",
                         "SelfRef"
                         ]),
    SchoolBaseTable.new("days", :all),
    SchoolBaseTable.new("pupil", :all),
    SchoolBaseTable.new("nationality", :all),
    SchoolBaseTable.new("language", :all),
    SchoolBaseTable.new("rel", :all),
    SchoolBaseTable.new("ethnicity", :all),
    SchoolBaseTable.new("class", :all),
    SchoolBaseTable.new("house", :all),
    SchoolBaseTable.new("stageofprospect", :all),
    SchoolBaseTable.new("boardertype", :all),
    SchoolBaseTable.new("regpup", :all),
    SchoolBaseTable.new("regtype", :all),
    SchoolBaseTable.new("phonenos", :all),
    SchoolBaseTable.new("phonelocation", :all),
    SchoolBaseTable.new("as", :all),
    SchoolBaseTable.new("ascomment", :all),
    SchoolBaseTable.new("asgrade", :all),
    SchoolBaseTable.new("asgroupsparts", :all),
    SchoolBaseTable.new("asgroups", :all),
    SchoolBaseTable.new("asheaders", :all),
    SchoolBaseTable.new("asheaderparts", :all),
    SchoolBaseTable.new("aspartreporttype", :all),
    SchoolBaseTable.new("astype", :all),
    SchoolBaseTable.new("asscore", :all),
    SchoolBaseTable.new("years", :all),
    SchoolBaseTable.new("staff", :all),
    SchoolBaseTable.new("siblings", :all),
    SchoolBaseTable.new("passporttype", :all),
    SchoolBaseTable.new("h1", :all),
    SchoolBaseTable.new("h2", :all),
    SchoolBaseTable.new("feeder", :all),
    SchoolBaseTable.new("feederfeature", :all),
    SchoolBaseTable.new("feederfeaturelink", :all),
    SchoolBaseTable.new("schtype", :all),
    SchoolBaseTable.new("checkpoints", :all),
    SchoolBaseTable.new("pupintakechecks", :all),
    SchoolBaseTable.new("term", :all),
    SchoolBaseTable.new("termname", :all),
    SchoolBaseTable.new("tutorgroup", :all),
    SchoolBaseTable.new("stabcovreason", :all),
    SchoolBaseTable.new("staffabsence", :all),
    SchoolBaseTable.new("dbook", :all),
    SchoolBaseTable.new("dbtype", :all),
    SchoolBaseTable.new("dbtypecategory", :all),
    SchoolBaseTable.new("dbookactions", :all),
    SchoolBaseTable.new("dbdistributiontype", :all),
    SchoolBaseTable.new("medcheck", :all),
    SchoolBaseTable.new("medcheckpup", :all),
    SchoolBaseTable.new("medcondition", :all),
    SchoolBaseTable.new("pupmedcondition", :all),
    SchoolBaseTable.new("putreatmeasurements", :all),
    SchoolBaseTable.new("putreatment", :all),
    SchoolBaseTable.new("putreatmentdest", :all),
    SchoolBaseTable.new("remedies", :all),
    SchoolBaseTable.new("treatment", :all),
    SchoolBaseTable.new("treatmeasurements", :all),
    SchoolBaseTable.new("vaccination", :all),
    SchoolBaseTable.new("consenttypes", :all),
    SchoolBaseTable.new("pupilfeatures", :all),
    SchoolBaseTable.new("givenconsent", :all),
    SchoolBaseTable.new("company", :all),
    SchoolBaseTable.new("pupfeeder", :all),
    SchoolBaseTable.new("country", :all),
    SchoolBaseTable.new("pupcategories", :all),
    SchoolBaseTable.new("features", :all),
    SchoolBaseTable.new("vacsite", :all),
    SchoolBaseTable.new("nurseall", :all),
    SchoolBaseTable.new("offspring", :all),
    SchoolBaseTable.new("specialneeds", :all),
    SchoolBaseTable.new("pupsn", :all),
    SchoolBaseTable.new("occupations", :all),
    SchoolBaseTable.new("pupfed", :all),
    SchoolBaseTable.new("application", :all),
    SchoolBaseTable.new("pupapp", :all),
    SchoolBaseTable.new("hraccidentbook", :all),
    SchoolBaseTable.new("hraccinvest", :all),
    SchoolBaseTable.new("hraccinvesttype", :all),
    SchoolBaseTable.new("pupildocuments", :all)
  ]

  def self.dump_tables
    #
    #  Require tiny_tds only if we are actually doing a data dump.
    #  This is because it has dependencies which might not be available
    #  on a development system.
    #
    require 'tiny_tds'

    TABLES.each do |table|
      table.dump
    end
  end

end

class Accumulator < Hash
  attr_accessor :options
end

#
#  It is assumed that there will be a hierarchy of SB record types,
#  loaded in order.  Each one will add itself to the collection, and
#  may well expect others to have been added before it itself is
#  loaded.
#
#  Each record type knows what it is to be called.  This class just
#  acts as a facilitator.
#
class Generator

  TO_SLURP = [
    SB_Years,
    SB_Days,
    SB_Nationality,
    SB_Language,
    SB_Religion,
    SB_Ethnicity,
    SB_Class,
    SB_House,
    SB_StageOfProspect,
    SB_BoarderType,
    SB_PassportType,
    SB_TutorGroup,
    SB_Staff,
    SB_H1Record,
    SB_H2Record,
    SB_Feeder,
    SB_Country,
    SB_Occupation,
    SB_PupilRecord,
    SB_SpecialNeed,
    SB_PupSN,
    SB_AdultOffspring,
    SB_PhoneNo,
    SB_RegType,
    SB_RegPup,
    SB_AsHeaders,
    SB_AsPartReportType,
    SB_AsHeaderParts,
    SB_AsGroups,
    SB_AsGroupParts,
    SB_As,
    SB_AsComment,
    SB_AsGrade,
    SB_AsScore,
    SB_Sibling,
    SB_FeederFeature,
    SB_FeederFeatureLink,
    #
    #  Note that SB_PupFeeder must come after SB_FeederFeatureLink
    #  so that we know what kind each feeder is.
    #
    SB_PupFeeder,
    SB_Checkpoint,
    SB_PupIntakeCheck,
    SB_Class,
    SB_TermName,
    SB_Term,
    SB_StAbCovReason,
    SB_StaffAbsence,
    SB_DayBookDistributionType,
    SB_DayBookTypeCategory,
    SB_DayBookType,
    SB_DayBook,
    SB_MedCondition,
    SB_PupMedCondition,
    SB_PupTreatment,
    SB_Treatment,
    SB_VacSite,
    SB_NurseAll,
    SB_Vaccination,
    SB_GivenConsent,
    SB_ConsentType,
    SB_MedCheck,
    SB_MedCheckPup,
    SB_Company,
    SB_PupCategory,
    SB_Feature,
    SB_PupilFeature,
    SB_Passcode,
    SB_PupFed,
    SB_Application,
    SB_PupApp,
    SB_PupilDocument
  ]

  def initialize(options)
    @accumulator = Accumulator.new
    @accumulator.options = options
    TO_SLURP.each do |sb_type|
      unless sb_type.setup(@accumulator)
        puts "Failed to load #{sb_type}"
      end
    end
    @accumulator.each do |key, contents|
      puts "Accumulator contains #{contents.size} #{key} records."
#      puts "Contents are of type #{contents.class}."
    end
  end

  WRITERS = [
    SB_RegPup,
    SB_PupilRecord,
    SB_Sibling,
    SB_AsHeaders,
    SB_As,
    SB_AsComment,
    SB_AsHeaderParts,
    SB_AsGrade,
    SB_AsGroupParts,
    SB_AsScore,
    SB_Feeder,
    SB_FeederFeature,
    SB_Staff,
    SB_PupIntakeCheck,
    SB_Years,
    SB_House,
    SB_Class,
    SB_Term,
    SB_TermName,
    SB_StAbCovReason,
    SB_StaffAbsence,
    SB_DayBook,
    SB_DayBookType,
    SB_PupMedCondition,
    SB_PupTreatment,
    SB_Treatment,
    SB_Vaccination,
    SB_MedCheck,
    SB_MedCheckPup,
    SB_PupilFeature,
    SB_SpecialNeed,
    SB_PupSN,
    SB_PupFed
  ]

  def write_records
    WRITERS.each do |writer|
      writer.do_writing(@accumulator, OUTPUT_DIR)
    end
  end

  #
  #  The photo dumper has no info about the pupil other than
  #  his ID, so saves them with that.  This function finds all
  #  such files which it can and renames them with the pupil's
  #  e-mail address.
  #
  PHOTO_DIR       = File.expand_path("../photos/",      File.dirname(__FILE__))
  STAFF_PHOTO_DIR = File.expand_path("../staffphotos/", File.dirname(__FILE__))

  def rename_photos
    pupil_recs = @accumulator[:pupils]
    staff_recs = @accumulator[:staff]
    raise "Can't find the pupil records." unless pupil_recs
    raise "Can't find the staff records." unless staff_recs
    Dir.glob("#{PHOTO_DIR}/*.jpg").each do |filename|
#      puts filename
#      puts Pathname.new(filename).basename
#      puts File.basename(filename, ".jpg")
      pupil_id = File.basename(filename, ".jpg").to_i
      if pupil_id != 0
        pupil = pupil_recs[pupil_id]
        if pupil
          newname = filename.gsub("#{pupil_id}", pupil.email.downcase)
#          puts "Old: #{filename}"
#          puts "New: #{newname}"
          File.rename(filename, newname)
        else
          puts "Can't find pupil with id #{pupil_id}."
        end
      else
        puts "Can't make sense of pupil id from \"#{filename}\"."
      end
    end
    Dir.glob("#{STAFF_PHOTO_DIR}/*.jpg").each do |filename|
      staff_id = File.basename(filename, ".jpg").to_i
      if staff_id != 0
        staff = staff_recs[staff_id]
        if staff
          newname = filename.gsub("#{staff_id}", staff.email.downcase)
#          puts "Old: #{filename}"
#          puts "New: #{newname}"
          File.rename(filename, newname)
        else
          puts "Can't find staff with id #{staff_id}."
        end
      else
        puts "Can't make sense of staff id from \"#{filename}\"."
      end
    end
  end

  #
  #  Go through a pile of group records, telling each pupil which groups
  #  he belongs to.
  #
  def process_groups(groups, subjects)
    pupils_hash = @accumulator[:pupils]
    if pupils_hash
      groups.each do |group|
#        puts "Processing #{group.name}"
#        puts "Group #{group.name} has #{group.records.size} academic records."
        group.tell_pupils(subjects, pupils_hash)
      end
      SB_PupilRecord.write_groups(@accumulator, OUTPUT_DIR)
    else
      puts "Can't find pupil records to add group info."
    end
  end

  def process_documents
    SB_PupilDocument.process_documents(@accumulator, OUTPUT_DIR)
  end

  def do_stats
    WRITERS.each do |writer|
      if writer.respond_to?(:do_stats)
        writer.send(:do_stats, @accumulator)
      end
    end
  end

end


begin
  options = OpenStruct.new
  options.verbose           = false
  options.do_extract        = false
  options.do_photos         = false
  options.do_generate       = false
  options.do_slurp          = false
  options.do_groups         = false
  options.do_stats          = false
  options.do_readmissions   = false
  options.split_checkpoints = false
  options.do_rename         = false
  options.do_documents      = false
  o = OptionParser.new do |opts|
    opts.banner = "Usage: extractor.rb [options]"

    opts.on("-e", "--extract", "Extract data from SB to CSV files") do |e|
      options.do_extract = e
    end

    opts.on("-p", "--photos", "Extract photos from SB to JPG files") do |p|
      options.do_photos = p
    end

    opts.on("--rename", "Rename photos to e-mails") do |r|
      options.do_rename = r
    end

    opts.on("-g", "--generate", "Generate iSAMS files from CSVs") do |g|
      options.do_generate = g
    end

    opts.on("-r", "--readmissions", "Move certain ancillary records over",
                                    "to readmissions records") do |r|
      options.do_readmissions = r
    end

    opts.on("--split-checkpoints", "Split checkpoint records between",
                                   "current and re-admissions records") do |s|
      options.split_checkpoints = s
    end

    opts.on("-s", "--slurp", "Just slurp the CSVs") do |g|
      options.do_slurp = g
    end

    opts.on("-d", "--documents", "Process pupil documents") do |d|
      options.do_documents = d
    end

    opts.on("--groups", "Read and process teaching group membership") do |g|
      options.do_groups = g
    end

    opts.on("--stats", "Print statistics") do |g|
      options.do_stats = g
    end

    opts.on("-v", "--verbose", "Run verbosely") do |v|
      options.verbose = v
    end

  end
  begin
    o.parse!
  rescue OptionParser::InvalidOption => e
    puts e
    puts o
    exit 1
  end

  if options.do_extract
    SchoolBaseTable.dump_tables
  end

  if options.do_photos
    dumper = PhotoDumper.new
    dumper.do_dump
  end

  if options.do_generate || options.do_slurp
    generator = Generator.new(options)
    if options.do_generate
      generator.write_records
    end
    if options.do_rename
      generator.rename_photos
    end
    if options.do_groups
      subjects =
        SB_Subject.read_yaml_file(File.expand_path("subjects.yml", YML_DIR))
      groups =
        SB_Group.read_yaml_file(File.expand_path("groups.yml", YML_DIR))
      generator.process_groups(groups, subjects)
    end
    if options.do_documents
      generator.process_documents
    end

    if options.do_stats
      generator.do_stats
    end
  end

end
