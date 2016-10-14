#
#  Class for SB Group records.
#  Copyright (C) 2016 Abingdon School
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#
#

require 'yaml'

class SB_Pupil
  attr_reader :pupil_ident
end

class SB_AcademicRecord
  attr_reader :pupil

end

class SB_Year
end

class SB_Curriculum
end

class Era
end

class SB_Group

  attr_reader :records, :subject_ident

  TRANSLATIONS = [
    {original: /^S/,      replacement: ''},
    {original: / Ma /,    replacement: ' Ma'},
    {original: /^1 Ar /,   replacement: '1R Ar'},
    {original: /^1 Comp /, replacement: '1R IC'},
    {original: /^1 Dr /,   replacement: '1R Dr'},
    {original: /^1 DT /,   replacement: '1R DT'},
    {original: /^1 Spt/,   replacement: 'LS Sp1'},
    {original: /^2 Ar /,   replacement: '2R Ar'},
    {original: /^2 Comp /, replacement: '2R IC'},
    {original: /^2 Dr /,   replacement: '2R Dr'},
    {original: /^2 DT /,   replacement: '2R DT'},
    {original: /^2 Spt/,   replacement: 'LS Sp2'},
    {original: /^2 F Fr-/, replacement: '2 Fr'},
    {original: /^2 F Gn-/, replacement: '2 Gn'},
    {original: /^2 MuS /,  replacement: '2R Mu'},
    {original: /^3 Ar ([ABCD])([123])/, replacement: '3\1 Ar\2'},
    {original: /^3 Comp /, replacement: '3 IC'},
    {original: /^3 DT ([ABCD])([123])/, replacement: '3\1 DT\2'},
    {original: /^3 En ([12345678])/, replacement: '3H En\1'},
    {original: /^([345]) F Fr-/, replacement: '\1F Fr'},
    {original: /^([345]) F Gn-/, replacement: '\1F Gn'},
    {original: /^3 Gg /,   replacement: '3H Gg'},
    {original: /^3 Hi /,   replacement: '3H Hi'},
    {original: /^([345]) Ma-/,   replacement: '\1M Ma'},
    {original: /^3 PE /,   replacement: '3 PE'},
    {original: /^3 RS /,   replacement: '3H RS'},
    {original: /^([3456]) Spt/,   replacement: '\1 Sp1'},
    {original: /^7 Spt/,   replacement: '6 Sp2'},
    {original: /^3 X/,     replacement: '3X'},
    {original: /^3X La-/,  replacement: '3X La'},
    {original: /^3X Sp-/,  replacement: '3X Sp'},
    {original: /^3 Y/,     replacement: '3Y'},
    {original: /^3Y Dr-/,  replacement: '3Y Dr'},
    {original: /^3Y Sp-/,  replacement: '3Y Sp'},
    {original: /^4 ([ABCD]) /, replacement: '4\1 '},
    {original: /^([45]) (Bi|Ch|Ph) /,   replacement: '\1S \2'},
    {original: /^([45]) En /,   replacement: '\1S En'},
    {original: /^([45]) F Sp-/, replacement: '\1F Sp'},
    {original: /^4 F Gn/,  replacement: '4F Gn'},
    {original: /^4 ([FS]) (Hi|Ar)/, replacement: '4\1 \2'},
    {original: /^4 A Hi-/, replacement: '4A Hi'},
    {original: /^([45]) PE /,   replacement: '\1S PE'},
    {original: /^4([ABC]) (La|Hi|Gg|RS)-/, replacement: '4\1 \2'},
    {original: /^5 ([ABC]) (DT|Gg|Hi|La|RS)-/, replacement: '5\1 \2'},
    {original: /^5 ([ABCFS]) (Ar|CC|Dr|DT|El|Fr|Hi|Gg|Gk|Gn|La|Mn|Mu|RS|Sp)/, replacement: '5\1 \2'},
    {original: /^([67]) ([PQRS]) (Bi|Ch|En|Ec|FM|Fr|Gg|Hi|Ma|Ph|Th)-/, replacement: '\1\2 \3'},
    {original: /^([67]) ([PQRS]) (AH|Ar|Bi|DT|Ec|En|Fr|Gg|Gk|Gn|Hi|La|Mu|Ps|Py|Sp|RS|Th|Sp)/, replacement: '\1\2 \3'},
  ]

  def effective_name
    result = @name
    TRANSLATIONS.each do |t|
      result.sub!(t[:original], t[:replacement])
    end
    result
  end

  #
  #  Some groups we don't really want at all.
  #
  NOT_WANTED = [
    /^1C/,
    /^1E/,
    /^1W/,
    /^2M/,
    /^2P/,
    /^2T/,
    /^S[34567] EFL/,
    /^S[45] [BC] EFL/,
    /^S[345] F EFL/,
    /^S[345] PSHCE/,
    /^S3 S /,
    /^S[45] (Bi|Ch|Ph) D[12]/,
    /^S5 X/,
    /^S[67] GSCS/,
    /^S7 GS GSRA/
  ]

  def wanted?
    NOT_WANTED.each do |nw|
      if nw.match(@name)
        return false
      end
    end
    return true
  end

  def tell_pupils(subjects, pupil_hash)
    subject = subjects.detect {|s| s.subject_ident == self.subject_ident}
    if wanted? && subject && subject.type == :proper_subject
      @records.each do |record|
        pupil = pupil_hash[record.pupil.pupil_ident]
        if pupil
          pupil.note_set_name(self.effective_name)
        else
          puts "Can't find pupil with id #{record.pupil.pupil_ident} for group #{@name}"
        end
      end
#    else
#      puts "Ignoring #{@name}"
    end
  end

  def self.read_yaml_file(filename)

    groups = YAML.load_file(filename)
    puts "Loaded #{groups.size} groups."
    groups
  end

end

