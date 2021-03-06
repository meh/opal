require File.expand_path('../../spec_helper', __FILE__)

describe "Basic assignment" do
  it "allows the rhs to be assigned to the lhs" do
    a = nil
    a.should == nil
  end

  it "assigns nil to lhs when rhs is an empty expression" do
    a = ()
    a.should be_nil
  end

  it "assigns [] to lhs when rhs is an empty splat expression" do
    a = *()
    a.should == []
  end

  it "allows the assignment of the rhs to the lhs using the rhs splat operator" do
    a = *nil;       a.should == []
    a = *1;         a.should == [1]
    a = *[];        a.should == []
    a = *[1];       a.should == [1]
    a = *[nil];     a.should == [nil]
    a = *[[]];      a.should == [[]]
    a = *[1,2];     a.should == [1,2]
  end
end

describe "Assigning multiple values" do
  it "allows parallel assignment" do
    a, b = 1, 2
    a.should == 1
    b.should == 2

    a, = 1,2
    a.should == 1
  end

  it "allows safe parallel swapping" do
    a, b = 1, 2
    a, b = b, a
    a.should == 2
    b.should == 1
  end

  it "bundles remaining values to an array when using the splat operator" do
    a, *b = 1, 2, 3
    a.should == 1
    b.should == [2, 3]

    *a = 1, 2, 3
    a.should == [1, 2, 3]

    *a = 4
    a.should == [4]

    *a = nil
    a.should == [nil]

    a, = *[1]
    a.should == 1
  end
end

describe "Single assignment" do
  it "Assignment does not modify the lhs, it reassigns its reference" do
    a = 'Foobar'
    b = a
    b = 'Bazquux'
    a.should == 'Foobar'
    b.should == 'Bazquux'
  end

  it "Assignment does not copy the object being assigned, just creates a new reference to it" do
    a = []
    b = a
    b << 1
    a.should == [1]
  end

  it "If rhs has multiple arguments, lhs becomes an Array of them" do
    a = [1, 2, 3]
    a.should == [1, 2, 3]

    a = 1, (), 3
    a.should == [1, nil, 3]
  end
end

describe "Multiple assignment without grouping or splatting" do
  it "An equal number of arguments on lhs and rhs assigns positionally" do
    a, b, c, d = 1, 2, 3, 4
    a.should == 1
    b.should == 2
    c.should == 3
    d.should == 4
  end

  it "If rhs has too few arguments, the missing ones on lhs are assigned nil" do
    a, b, c = 1, 2
    a.should == 1
    b.should == 2
    c.should == nil
  end

  it "If rhs has too many arguments, the extra ones are silently not assigned anywhere" do
    a, b = 1, 2, 3
    a.should == 1
    b.should == 2
  end
end
