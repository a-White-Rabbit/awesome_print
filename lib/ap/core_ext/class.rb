# Copyright (c) 2010 Michael Dvorkin
#
# Awesome Print is freely distributable under the terms of MIT license.
# See LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class Class
  methods.grep(/instance_methods$/) do |name|
    alias_method :"original_#{name}", name
    define_method name do |*args|
      methods = self.send(:"original_#{name}", *args)
      methods.instance_variable_set('@__awesome_methods__', self) # Evil?!
      methods.sort!
    end
  end
end
