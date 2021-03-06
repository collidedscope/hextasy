require "./spec_helper"

include Hextasy

describe Hexagony do
  it "runs the Hello, World! example" do
    hw = Hexagony.new example "hello_world"
    hw.run_on("").should eq "Hello, World!"
  end

  it "interprets the calculator example" do
    calc = Hexagony.new example "calculator"
    calc.run_on("123+456").should eq "579"
    calc.run_on("123-456").should eq "-333"
    calc.run_on("123*456").should eq "56088"
    calc.run_on("123/10").should eq "12"
    calc.run_on("123%10").should eq "3"
  end

  it "interprets the prime example" do
    prime = Hexagony.new example "prime"
    prime.run_on("2").should eq "1"
    prime.run_on("9").should eq "0"
    prime.run_on("17").should eq "1"
    prime.run_on("123").should eq "0"
  end

  it "runs the hexify example on itself" do
    hexify_source = example "hexify"
    hexify = Hexagony.new hexify_source
    hexify.run_on(hexify_source.delete " \n").should eq hexify_source
  end

  it "interprets the tac example" do
    tac = Hexagony.new example "tac"
    tac.run_on("foo bar baz").should eq "zab rab oof"
    tac.run_on("1\n2\n3").should eq "3\n2\n1"
  end
end
