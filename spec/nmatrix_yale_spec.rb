# = NMatrix
#
# A linear algebra library for scientific computation in Ruby.
# NMatrix is part of SciRuby.
#
# NMatrix was originally inspired by and derived from NArray, by
# Masahiro Tanaka: http://narray.rubyforge.org
#
# == Copyright Information
#
# SciRuby is Copyright (c) 2010 - 2012, Ruby Science Foundation
# NMatrix is Copyright (c) 2012, Ruby Science Foundation
#
# Please see LICENSE.txt for additional copyright notices.
#
# == Contributing
#
# By contributing source code to SciRuby, you agree to be bound by
# our Contributor Agreement:
#
# * https://github.com/SciRuby/sciruby/wiki/Contributor-Agreement
#
# == nmatrix_yale_spec.rb
#
# Basic tests for NMatrix's Yale storage type.
#
require "./lib/nmatrix"

describe NMatrix do
  it "correctly compares two empty yale matrices" do
    n = NMatrix.new(:yale, [4,4], :float64)
    m = NMatrix.new(:yale, [4,4], :float64)
    n.should.eql? m
  end

  it "correctly compares two yale matrices following basic assignments" do
    n = NMatrix.new(:yale, [2,2], :float64)
    m = NMatrix.new(:yale, [2,2], :float64)
    m[0,0] = 1
    m[0,1] = 1
    n.should_not.eql? m
    n[0,0] = 1
    n.should_not.eql? m
    n[0,1] = 1
    n.should.eql? m
  end

  it "correctly compares two yale matrices following elementwise operations" do
    n = NMatrix.new(:yale, [2,2], :float64)
    n[0,1] = 1
    m = NMatrix.new(:yale, [2,2], :float64)
    m[0,1] = -1
    r = NMatrix.new(:yale, [2,2], :float64)
    r[0,1] = 0
    (n+m).should.eql? r
  end

  it "correctly sets diagonal values in yale" do
    n = NMatrix.new(:yale, [2,3], :float64)
    n[1,1] = 0.1
    n[0,0] = 0.2
    n.__yale_d__.should == [0.2, 0.1]
  end

  it "does not resize yale until necessary" do
    n = NMatrix.new(:yale, [2,3], :float64)
    n.__yale_size__.should == 3
    n.capacity.should == 5
    n[0,0] = 0.1
    n[0,1] = 0.2
    n[1,0] = 0.3
    n.__yale_size__.should == 5
    n.capacity.should == 5
  end


  it "correctly sets when not resizing (yale)" do
    n = NMatrix.new(:yale, [2,3], :float64)
    n[0,0] = 0.1
    n[0,1] = 0.2
    n[1,0] = 0.3
    n.__yale_a__ == [0.1, 0.0, 0.0, 0.2, 0.3]
    n.__yale_ija__ == [3,4,5,1,0]
  end

  it "correctly sets when resizing (yale)" do
    n = NMatrix.new(:yale, [2,3], :float64)
    n[0,0] = 0.01
    n[1,1] = 0.1
    n[0,1] = 0.2
    n[1,0] = 0.3
    n[1,2] = 0.4
    n.__yale_d__.should == [0.01, 0.1]
    n.__yale_ia__.should == [3,4,6]
    n.__yale_ja__.should == [1,0,2,nil]
    n.__yale_lu__.should == [0.2, 0.3, 0.4, nil]
  end

  it "correctly sets values within rows of yale" do
    n = NMatrix.new(:yale, [3,20], :float64)
    n[2,1]   = 1.0
    n[2,0]   = 1.5
    n[2,15]  = 2.0
    n.__yale_lu__.should == [1.5, 1.0, 2.0]
    n.__yale_ja__.should == [0, 1, 15]
  end

  it "correctly gets values within rows of yale" do
    n = NMatrix.new(:yale, [3,20], :float64)
    n[2,1]   = 1.0
    n[2,0]   = 1.5
    n[2,15]  = 2.0
    n[2,1].should == 1.0
    n[2,0].should == 1.5
    n[2,15].should == 2.0
  end

  it "correctly sets values within large rows of yale" do
    n = NMatrix.new(:yale, [10,300], :float64)
    n[5,1]   = 1.0
    n[5,0]   = 1.5
    n[5,15]  = 2.0
    n[5,291] = 3.0
    n[5,292] = 4.0
    n[5,289] = 5.0
    n[5,290] = 6.0
    n[5,293] = 2.0
    n[5,299] = 7.0
    n[5,100] = 8.0
    n.__yale_lu__.should == [1.5, 1.0, 2.0, 8.0, 5.0, 6.0, 3.0, 4.0, 2.0, 7.0]
    n.__yale_ja__.should == [0,   1,   15,  100, 289, 290, 291, 292, 293, 299]
  end

  it "correctly gets values within large rows of yale" do
    n = NMatrix.new(:yale, [10,300], :float64)
    n[5,1]   = 1.0
    n[5,0]   = 1.5
    n[5,15]  = 2.0
    n[5,291] = 3.0
    n[5,292] = 4.0
    n[5,289] = 5.0
    n[5,290] = 6.0
    n[5,293] = 2.0
    n[5,299] = 7.0
    n[5,100] = 8.0

    n.__yale_ja__.each_index do |idx|
      j = n.__yale_ja__[idx]
      n[5,j].should == n.__yale_lu__[idx]
    end
  end

  it "correctly dots two identical yale matrices" do
    a = NMatrix.new(:yale, 4, :float64)
    a[0,1] = 4.0
    a[1,2] = 1.0
    a[1,3] = 1.0
    a[3,1] = 2.0

    b = a.dup
    c = a.dot b

    c[0,0].should == 0.0
    c[0,1].should == 0.0
    c[0,2].should == 4.0
    c[0,3].should == 4.0
    c[1,0].should == 0.0
    c[1,1].should == 2.0
    c[1,2].should == 0.0
    c[1,3].should == 0.0
    c[2,0].should == 0.0
    c[2,1].should == 0.0
    c[2,2].should == 0.0
    c[2,3].should == 0.0
    c[3,0].should == 0.0
    c[3,1].should == 0.0
    c[3,2].should == 2.0
    c[3,3].should == 2.0
  end

  it "correctly dots two identical yale matrices where a positive and negative partial sum cancel on the diagonal" do
    a = NMatrix.new(:yale, 4, :float64)
    a[0,0] = 1.0
    a[0,1] = 4.0
    a[1,2] = 2.0
    a[1,3] = -4.0
    a[3,1] = 4.0
    a[3,3] = 4.0

    b = a.dup
    c = a.dot b

    #c[0,0].should == 1.0
    #c[0,1].should == 4.0
    #c[0,2].should == 8.0
    #c[0,3].should == -16.0
    #c[1,0].should == 0.0
    #c[1,1].should == -16.0
    #c[1,2].should == 0.0
    #c[1,3].should == -16.0
    #c[2,0].should == 0.0
    #c[2,1].should == 0.0
    #c[2,2].should == 0.0
    #c[2,3].should == 0.0
    #c[3,0].should == 0.0
    #c[3,1].should == 0.0
    #c[3,2].should == 8.0
    #c[3,3].should == 0.0 # this is the positive and negative partial sum cancel

    c.__yale_ija__.reject { |i| i.nil? }.should == [5,8,9,9,11,1,2,3,3,1,2]
    c.__yale_a__.reject { |i| i.nil? }.should == [1.0, -16.0, 0.0, 0.0, 0.0, 4.0, 8.0, -16.0, -16.0, 16.0, 8.0]

  end

  it "correctly transposes yale" do
    a = NMatrix.new(:yale, 4, :float64)
    a[0,0] = 1.0
    a[0,1] = 4.0
    a[1,2] = 2.0
    a[1,3] = -4.0
    a[3,1] = 5.0
    a[3,3] = 6.0
    b = a.transpose

    b[0,0].should == 1.0
    b[1,0].should == 4.0
    b[2,0].should == 0.0
    b[3,0].should == 0.0
    b[0,1].should == 0.0
    b[1,1].should == 0.0
    b[2,1].should == 2.0
    b[3,1].should == -4.0
    b[0,3].should == 0.0
    b[1,3].should == 5.0
    b[2,3].should == 0.0
    b[3,3].should == 6.0
  end

end