#
#  Extra facilities for manipulating dates.
#  See COPYING and LICENCE in the root directory of the application
#  for more information
#

class Date
  def for_isams
    self.strftime("%F")
  end
end
