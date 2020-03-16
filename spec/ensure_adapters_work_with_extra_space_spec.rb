require 'spec_helper'
require "capistrano"

describe Database::Base do
  
  let(:base) { 
    Database::Base.new({}) 
  }
  
  describe "identifying mysql adapter" do

    context "when mysql" do
      it "it is positive" do
        base.config = { "adapter" => "mysql" }
        expect(base.mysql?).to be_truthy
      end
    end
    
    context "when mysql with extra space" do
      it "it is positive" do
        base.config = { "adapter" => "  mysql  " }
        expect(base.mysql?).to be_truthy
      end
    end
    
    context "when postgresql" do
      it "it is positive" do
        base.config = { "adapter" => "postgresql" }
        expect(base.mysql?).to be_falsey
      end
    end
    
    context "when pg" do
      it "it is positive" do
        base.config = { "adapter" => "pg" }
        expect(base.mysql?).to be_falsey
      end
    end
    
    context "when something else" do
      it "it is positive" do
        base.config = { "adapter" => "foo" }
        expect(base.mysql?).to be_falsey
      end
    end

  end

  describe "identifying postgres adapter" do
    
    context "when postgresql" do
      it "it is positive" do
        base.config = { "adapter" => "postgresql" }
        expect(base.postgresql?).to be_truthy
      end
    end
    
    context "when postgresql with extra space" do
      it "it is positive" do
        base.config = { "adapter" => "  postgresql  " }
        expect(base.postgresql?).to be_truthy
      end
    end
    
    context "when pg" do
      it "it is positive" do
        base.config = { "adapter" => "pg" }
        expect(base.postgresql?).to be_truthy
      end
    end
    
    context "when pg with extra space" do
      it "it is positive" do
        base.config = { "adapter" => "  pg  " }
        expect(base.postgresql?).to be_truthy
      end
    end
    
    context "when mysql" do
      it "it is positive" do
        base.config = { "adapter" => "mysq" }
        expect(base.postgresql?).to be_falsey
      end
    end
    
    context "when something else" do
      it "it is positive" do
        base.config = { "adapter" => "foo" }
        expect(base.postgresql?).to be_falsey
      end
    end
    
  end

end
