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
# == io_spec.rb
#
# Basic tests for NMatrix::IO.
#
require "./lib/nmatrix"

describe NMatrix::IO do
  it "reads MATLAB .mat file containing a single square sparse matrix" do
    n = NMatrix::IO::Matlab.load_mat("spec/4x4_sparse.mat")
    n[0,0].should == 2
    n[1,1].should == 3
    n[1,3].should == 5
    n[3,0].should == 4
  end

  it "reads MATLAB .mat file containing a single dense matrix" do
    n = NMatrix::IO::Matlab.load_mat("spec/4x5_dense.mat")
    m = NMatrix.new(:dense, [4,5], [16,17,18,19,20,15,14,13,12,11,6,7,8,9,10,5,4,3,2,1])
    n.should.eql?(m)
  end
end