require 'rails_helper'

RSpec.describe Rate, :type => :model do
  let(:rate) { Rate.new("USD","2014-09-05",Date.today.to_s)}
  
  before(:each) do
    #Stubbing to not make test date dependant on the current date. 
    #This way I can test both the accuracy of the date and the format in the same test
    Date.stub(:today) { Date.new(2014,9,7)}

    #Stubbind API call
    HTTParty.stub_chain(:get,:parsed_response) {"{\"from\":\"USD\",\"to\":\"BRL\",\"rates\":{\"2014-09-06\":{\"utctime\":\"2014-09-06T23:50:02+02:00\",\"rate\":\"2.25\"},\"2014-09-07\":{\"utctime\":\"2014-09-07T21:30:02+02:00\",\"rate\":\"2.26\"}}}"}
  end

  describe ".calculate_start_date(time_span)" do
    it "returns a string with the date of yesterday" do
      expect(Rate.calculate_start_date("1D")).to eq "2014-09-06"
    end

    it "returns a string with the date of 5 days ago" do
      expect(Rate.calculate_start_date("5D")).to eq "2014-09-02"
    end

    it "returns a string with the date of 1 month ago" do
      expect(Rate.calculate_start_date("1M")).to eq "2014-08-07"
    end

    it "returns a string with the date of 3 months ago" do
      expect(Rate.calculate_start_date("3M")).to eq "2014-06-07"
    end

    it "returns a string with the date of 6 months ago" do
      expect(Rate.calculate_start_date("6M")).to eq "2014-03-07"
    end

    it "returns a string with the date of 1 year ago" do
      expect(Rate.calculate_start_date("1Y")).to eq "2013-09-07"
    end

    it "returns a string with the date of 2 years ago" do
      expect(Rate.calculate_start_date("2Y")).to eq "2012-09-07"
    end

    it "returns a string with the date of 5 years ago" do
      expect(Rate.calculate_start_date("5Y")).to eq "2009-09-07"
    end

    it "returns a string with the date of 10 years ago" do
      expect(Rate.calculate_start_date("MAX")).to eq "2004-09-07"
    end
  end

  describe "#get_data" do
    it "sets in self a JSON parsed from the response" do
      expect{rate.get_data}.to change{rate.historical_data}.from([]).to([ ["2014-09-06",2.25],["2014-09-07",2.26]])
    end
  end

  describe "calculate_ema(number_of_days,current_position)" do
    before(:each) do
      rate.historical_data = [ ["2014-09-06",2.25],["2014-09-07",2.26],["2014-09-08",2.27]]
    end

    it "sets in self an array of arrays with the calculated ema for each date point" do
      expect{rate.calculate_ema(21,rate.historical_data.size-1)}.to change{rate.calculated_ema}.from([]).to([ ["2014-09-06",2.25],["2014-09-07",2.2509],["2014-09-08",2.2526] ])
    end

    it "does not calculates if the position is smaller than 0" do
      expect{rate.calculate_ema(21,-1)}.to_not change{rate.calculated_ema}
    end

    it "returns itself if the array has only one position" do
      expect{rate.calculate_ema(21,0)}.to change{rate.calculated_ema}.from([]).to([["2014-09-06",2.25]])
    end
  end
end
