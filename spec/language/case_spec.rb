require File.expand_path('../../spec_helper', __FILE__)

describe "The 'case'-construct" do
  it "evaluates the body of the when clause matching the case target expression" do
    case 1
      when 2; false
      when 1; true
    end.should == true
  end

  it "evaluates the body of the when clause whose array expression includes the case target expression" do
    case 2
      when 3, 4; false
      when 1, 2; true
    end.should == true
  end

  it "evaluates the body of the when clause in left-to-right order if it's an array expression" do
    @calls = []
    def foo; @calls << :foo; end
    def bar; @calls << :bar; end

    case true
      when foo, bar;
    end

    @calls.should == [:foo, :bar]
  end

  it "evaluates the body of the when clause whose range expression includes the case target expression" do
    case 5
      when 21..30; false
      when 1..20; true
    end.should == true
  end

  it "returns nil when no 'then'-bodies are given" do
    case "a"
      when "a"
      when "b"
    end.should == nil
  end

  it "evaluates the 'else'-body when no other expression matches" do
    case "c"
      when "a"; 'foo'
      when "b"; 'bar'
      else 'zzz'
    end.should == 'zzz'
  end

  it "returns nil when no expression matches and 'else'-body is empty" do
    case "c"
      when "a"; "a"
      when "b"; "b"
      else
    end.should == nil
  end

  it "returns 2 when a then body is empty" do
    case Object.new
    when Numeric then
      1
    when String then
      # ok
    else
      2
    end.should == 2
  end

  it "returns the statement following 'then'" do
    case "a"
      when "a" then 'foo'
      when "b" then 'bar'
    end.should == 'foo'
  end

  it "tests classes with case equality" do
    case "a"
      when String
        'foo'
      when Symbol
        'bar'
    end.should == 'foo'
  end

  it "tests with matching regexps" do
    case "hello"
      when /abc/; false
      when /^hell/; true
    end.should == true
  end

  it "does not test with equality when given classes" do
    case :symbol.class
      when Symbol
        "bar"
      when String
        "bar"
      else
        "foo"
    end.should == "foo"
  end

  it "takes lists of values" do
    case 'z'
      when 'a', 'b', 'c', 'd'
        "foo"
      when 'x', 'y', 'z'
        "bar"
    end.should == "bar"

    case 'b'
      when 'a', 'b', 'c', 'd'
        "foo"
      when 'x', 'y', 'z'
        "bar"
    end.should == "foo"
  end

  it "expands arrays to lists of values" do
    case 'z'
      when *['a', 'b', 'c', 'd']
        "foo"
      when *['x', 'y', 'z']
        "bar"
    end.should == "bar"
  end

  it "takes an expanded array in addition to a list of values" do
    case 'f'
      when 'f', *['a',  'b', 'c', 'd']
        "foo"
      when *['x', 'y', 'z']
        "bar"
    end.should == "foo"

    case 'b'
      when 'f', *['a', 'b', 'c', 'd']
        "foo"
      when *['x', 'y', 'z']
        "bar"
    end.should == "foo"
  end

  it "concats arrays before expanding them" do
    a = ['a', 'b', 'c', 'd']
    b = ['f']

    case 'f'
      when 'f', *a|b
        "foo"
      when *['x', 'y', 'z']
        "bar"
    end.should == "foo"
  end

  it "never matchers when clauses with no values" do
    case nil
      when *[]
        "foo"
    end.should == nil
  end
end

