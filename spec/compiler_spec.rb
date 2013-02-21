require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
require 'protocol_buffers'
require 'protocol_buffers/compiler'

describe ProtocolBuffers, "compiler" do

  test_files = Dir[File.join(File.dirname(__FILE__), "proto_files", "*.proto")]

  before do
    pending "need protoc installed" unless has_compiler?
  end

  test_files.each do |file|
    it "can compile #{File.basename(file)}" do
      proc do
        ProtocolBuffers::Compiler.compile_and_load(file)
      end.should_not raise_error()
    end
  end

  it "can compile and instantiate a message in a package with under_scores" do
    Object.send(:remove_const, :UnderScore) if defined?(UnderScore)

    ProtocolBuffers::Compiler.compile_and_load(
      File.join(File.dirname(__FILE__), "proto_files", "under_score_package.proto"))

    proc do
      under_test = UnderScore::UnderTest.new
    end.should_not raise_error()
  end

  it "should compile and correctly translate" do
    ProtocolBuffers::Compiler.compile_and_load(
      File.join(File.dirname(__FILE__), "proto_files", "simple.proto"))
    ProtocolBuffers::Compiler.compile_and_load(
      File.join(File.dirname(__FILE__), "proto_files", "featureful.proto"))
  end

end
