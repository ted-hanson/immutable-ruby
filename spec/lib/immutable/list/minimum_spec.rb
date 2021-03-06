require "spec_helper"

describe Immutable::List do
  describe "#min" do
    context "on a really big list" do
      it "doesn't run out of stack" do
        -> { BigList.min }.should_not raise_error
      end
    end

    context "with a block" do
      [
        [[], nil],
        [["A"], "A"],
        [%w[Ichi Ni San], "Ni"],
      ].each do |values, expected|
        context "on #{values.inspect}" do
          it "returns #{expected.inspect}" do
            L[*values].min { |minimum, item| minimum.length <=> item.length }.should == expected
          end
        end
      end
    end

    context "without a block" do
      [
        [[], nil],
        [["A"], "A"],
        [%w[Ichi Ni San], "Ichi"],
      ].each do |values, expected|
        context "on #{values.inspect}" do
          it "returns #{expected.inspect}" do
            L[*values].min.should == expected
          end
        end
      end
    end
  end
end