require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Single method" do
  after do
    Object.instance_eval{ remove_const :Hello } if defined?(Hello)
  end

  it "plain: should handle a method with no arguments" do
    method = ''.method(:upcase)
    method.ai(:plain => true).should == 'String#upcase()'
  end

  it "color: should handle a method with no arguments" do
    method = ''.method(:upcase)
    method.ai.should == "\e[1;33mString\e[0m#\e[1;35mupcase\e[0m\e[0;37m()\e[0m"
  end

  it "plain: should handle a method with one argument" do
    method = ''.method(:include?)
    method.ai(:plain => true).should == 'String#include?(arg1)'
  end

  it "color: should handle a method with one argument" do
    method = ''.method(:include?)
    method.ai.should == "\e[1;33mString\e[0m#\e[1;35minclude?\e[0m\e[0;37m(arg1)\e[0m"
  end

  it "plain: should handle a method with two arguments" do
    method = ''.method(:tr)
    method.ai(:plain => true).should == 'String#tr(arg1, arg2)'
  end

  it "color: should handle a method with two arguments" do
    method = ''.method(:tr)
    method.ai.should == "\e[1;33mString\e[0m#\e[1;35mtr\e[0m\e[0;37m(arg1, arg2)\e[0m"
  end

  it "plain: should handle a method with multiple arguments" do
    method = ''.method(:split)
    method.ai(:plain => true).should == 'String#split(*arg1)'
  end

  it "color: should handle a method with multiple arguments" do
    method = ''.method(:split)
    method.ai.should == "\e[1;33mString\e[0m#\e[1;35msplit\e[0m\e[0;37m(*arg1)\e[0m"
  end

  it "plain: should handle a method defined in mixin" do
    method = ''.method(:is_a?)
    method.ai(:plain => true).should == 'String (Kernel)#is_a?(arg1)'
  end

  it "color: should handle a method defined in mixin" do
    method = ''.method(:is_a?)
    method.ai.should == "\e[1;33mString (Kernel)\e[0m#\e[1;35mis_a?\e[0m\e[0;37m(arg1)\e[0m"
  end

  it "plain: should handle an unbound method" do
    class Hello
      def world; end
    end
    method = Hello.instance_method(:world)
    method.ai(:plain => true).should == 'Hello (unbound)#world()'
  end

  it "color: should handle an unbound method" do
    class Hello
      def world(a,b); end
    end
    method = Hello.instance_method(:world)
    method.ai.should == "\e[1;33mHello (unbound)\e[0m#\e[1;35mworld\e[0m\e[0;37m(arg1, arg2)\e[0m"
  end
end

describe "Object methods" do
  after do
    Object.instance_eval{ remove_const :Hello } if defined?(Hello)
  end

  describe "object.methods" do
    it "index: should handle object.methods" do
      out = nil.methods.ai(:plain => true).split("\n").grep(/is_a\?/).first
      out.should =~ /^\s+\[\s*\d+\]\s+is_a\?\(arg1\)\s+NilClass \(Kernel\)$/
    end

    it "no index: should handle object.methods" do
      out = nil.methods.ai(:plain => true, :index => false).split("\n").grep(/is_a\?/).first
      out.should =~ /^\s+is_a\?\(arg1\)\s+NilClass \(Kernel\)$/
    end
  end

  describe "object.public_methods" do
    it "index: should handle object.public_methods" do
      out = nil.public_methods.ai(:plain => true).split("\n").grep(/is_a\?/).first
      out.should =~ /^\s+\[\s*\d+\]\s+is_a\?\(arg1\)\s+NilClass \(Kernel\)$/
    end

    it "no index: should handle object.public_methods" do
      out = nil.public_methods.ai(:plain => true, :index => false).split("\n").grep(/is_a\?/).first
      out.should =~ /^\s+is_a\?\(arg1\)\s+NilClass \(Kernel\)$/
    end
  end

  describe "object.private_methods" do
    it "index: should handle object.private_methods" do
      out = nil.private_methods.ai(:plain => true).split("\n").grep(/sleep/).first
      out.should =~ /^\s+\[\s*\d+\]\s+sleep\(\*arg1\)\s+NilClass \(Kernel\)$/
    end

    it "no index: should handle object.private_methods" do
      out = nil.private_methods.ai(:plain => true, :index => false).split("\n").grep(/sleep/).first
      out.should =~ /^\s+sleep\(\*arg1\)\s+NilClass \(Kernel\)$/
    end
  end

  describe "object.protected_methods" do
    it "index: should handle object.protected_methods" do
      class Hello
        protected
        def m1; end
        def m2; end
      end
      Hello.new.protected_methods.ai(:plain => true).should == "[\n    [0] m1() Hello\n    [1] m2() Hello\n]"
    end

    it "no index: should handle object.protected_methods" do
      class Hello
        protected
        def m3(a,b); end
      end
      Hello.new.protected_methods.ai(:plain => true, :index => false).should == "[\n     m3(arg1, arg2) Hello\n]"
    end
  end

  describe "object.private_methods" do
    it "index: should handle object.private_methods" do
      class Hello
        private
        def m1; end
        def m2; end
      end
      out = Hello.new.private_methods.ai(:plain => true).split("\n").grep(/m\d/)
      out.first.should =~ /^\s+\[\d+\]\s+m1\(\)\s+Hello$/
      out.last.should  =~ /^\s+\[\d+\]\s+m2\(\)\s+Hello$/
    end

    it "no index: should handle object.private_methods" do
      class Hello
        private
        def m3(a,b); end
      end
      out = Hello.new.private_methods.ai(:plain => true).split("\n").grep(/m\d/)
      out.first.should =~ /^\s+\[\d+\]\s+m3\(arg1, arg2\)\s+Hello$/
    end
  end

  describe "object.singleton_methods" do
    it "index: should handle object.singleton_methods" do
      class Hello
        class << self
          def m1; end
          def m2; end
        end
      end
      out = Hello.singleton_methods.ai(:plain => true).split("\n").grep(/m\d/)
      out.first.should =~ /^\s+\[\d+\]\s+m1\(\)\s+Hello$/
      out.last.should  =~ /^\s+\[\d+\]\s+m2\(\)\s+Hello$/
    end

    it "no index: should handle object.singleton_methods" do
      class Hello
        def self.m3(a,b); end
      end
      out = Hello.singleton_methods.ai(:plain => true, :index => false).split("\n").grep(/m\d/)
      out.first.should =~ /^\s+m3\(arg1, arg2\)\s+Hello$/
    end
  end
end

describe "Class methods" do
  after do
    Object.instance_eval{ remove_const :Hello } if defined?(Hello)
  end

  describe "class.instance_methods" do
    it "index: should handle unbound class.instance_methods" do
      class Hello
        def m1; end
        def m2; end
      end
      out = Hello.instance_methods.ai(:plain => true).split("\n").grep(/m\d/)
      out.first.should =~ /^\s+\[\s*\d+\]\s+m1\(\)\s+Hello\s\(unbound\)$/
      out.last.should  =~ /^\s+\[\s*\d+\]\s+m2\(\)\s+Hello\s\(unbound\)$/
    end

    it "no index: should handle unbound class.instance_methods" do
      class Hello
        def m3(a,b); end
      end
      out = Hello.instance_methods.ai(:plain => true, :index => false).split("\n").grep(/m\d/)
      out.first.should =~ /^\s+m3\(arg1, arg2\)\s+Hello\s\(unbound\)$/
    end
  end

  describe "class.public_instance_methods" do
    it "index: should handle class.public_instance_methods" do
      class Hello
        def m1; end
        def m2; end
      end
      out = Hello.public_instance_methods.ai(:plain => true).split("\n").grep(/m\d/)
      out.first.should =~ /^\s+\[\s*\d+\]\s+m1\(\)\s+Hello\s\(unbound\)$/
      out.last.should  =~ /^\s+\[\s*\d+\]\s+m2\(\)\s+Hello\s\(unbound\)$/
    end

    it "no index: should handle class.public_instance_methods" do
      class Hello
        def m3(a,b); end
      end
      out = Hello.public_instance_methods.ai(:plain => true, :index => false).split("\n").grep(/m\d/)
      out.first.should =~ /^\s+m3\(arg1, arg2\)\s+Hello\s\(unbound\)$/
    end
  end

  describe "class.protected_instance_methods" do
    it "index: should handle class.protected_instance_methods" do
      class Hello
        protected
        def m1; end
        def m2; end
      end
      out = Hello.protected_instance_methods.ai(:plain => true).split("\n").grep(/m\d/)
      out.first.should =~ /^\s+\[\d+\]\s+m1\(\)\s+Hello\s\(unbound\)$/
      out.last.should  =~ /^\s+\[\d+\]\s+m2\(\)\s+Hello\s\(unbound\)$/
    end

    it "no index: should handle class.protected_instance_methods" do
      class Hello
        protected
        def m3(a,b); end
      end
      out = Hello.protected_instance_methods.ai(:plain => true, :index => false).split("\n").grep(/m\d/)
      out.first.should =~ /^\s+m3\(arg1, arg2\)\s+Hello\s\(unbound\)$/
    end
  end

  describe "class.private_instance_methods" do
    it "index: should handle class.private_instance_methods" do
      class Hello
        private
        def m1; end
        def m2; end
      end
      out = Hello.private_instance_methods.ai(:plain => true).split("\n").grep(/m\d/)
      out.first.should =~ /^\s+\[\s*\d+\]\s+m1\(\)\s+Hello\s\(unbound\)$/
      out.last.should  =~ /^\s+\[\s*\d+\]\s+m2\(\)\s+Hello\s\(unbound\)$/
    end

    it "no index: should handle class.private_instance_methods" do
      class Hello
        private
        def m3(a,b); end
      end
      out = Hello.private_instance_methods.ai(:plain => true, :index => false).split("\n").grep(/m\d/)
      out.first.should =~ /^\s+m3\(arg1, arg2\)\s+Hello\s\(unbound\)$/
    end
  end
end

