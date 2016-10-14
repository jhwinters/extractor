#  See COPYING and LICENCE in the root directory of the application
#  for more information

PHOTO_DIR    = File.expand_path("../photos/",    File.dirname(__FILE__))

class PhotoDumper

  @@password = nil

  #
  #  A class to dump photos out of SB as separate files.
  #
  def initialize
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


  def do_dump
    require 'tiny_tds'

    get_password unless @@password
    client = TinyTds::Client.new(
      username: "winters",
      password: @@password,
      dataserver: "Schoolbase",
      database: "Schoolbase")
    result = client.execute("SELECT * FROM [Photos];")
    fields = result.fields
    result.each do |row|
      puts "Ph_CompNo: #{row["Ph_CompNo"]}, PhIdent: #{row["PhIdent"]}, PhLink: #{row["PhLink"]}, PhFileName: #{row["PhFileName"]}"
      IO.binwrite(File.expand_path("#{row["Ph_CompNo"]}.jpg", PHOTO_DIR),
                  row["PhPhoto"])
#      csv << fields.collect {|f| row[f]}
    end
    client.close
#    csv.close

  end

end
