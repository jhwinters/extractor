#
#  Class for SB Subject records
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#
#

require 'yaml'

class SB_Subject

  attr_reader :subject_ident, :type

  def self.read_yaml_file(filename)

    subjects = YAML.load_file(filename)
    puts "Loaded #{subjects.size} subjects."
    subjects
  end

end

