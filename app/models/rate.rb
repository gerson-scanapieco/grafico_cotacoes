class Rate
  attr_reader :url, :currency
  attr_accessor :historical_data, :calculated_ema

  def initialize(currency,start_date,end_date)
    @url = "http://jsonrates.com/historical/?from=" + currency + "&to=BRL" + "&dateStart=" + start_date + "&dateEnd=" + end_date
    @currency = currency
    @calculated_ema = []
    @historical_data = []
  end

  def self.calculate_start_date(time_span)
    case time_span
    when "1D"
      return (Date.today - 1.days).to_s
    when "5D"
      return (Date.today - 5.days).to_s
    when "1M"
      return (Date.today - 1.months).to_s
    when "3M"
      return (Date.today - 3.months).to_s
    when "6M"
      return (Date.today - 6.months).to_s
    when "1Y"
      return (Date.today - 1.years).to_s
    when "2Y"
      return (Date.today - 2.years).to_s
    when "5Y"
      return (Date.today - 5.years).to_s
    when "MAX"
      return (Date.today - 10.years).to_s
    end
  end

  def get_data
    parsed_response = JSON.parse(HTTParty.get(self.url).parsed_response)["rates"]

    parsed_response.each_value do |value|
      self.historical_data << [Date.parse(value["utctime"]).to_s,value["rate"].to_f]
    end
  end

  def calculate_ema(number_of_days,current_position)
    if current_position < 0
      return
    end

    if current_position == 0
      self.calculated_ema << [self.historical_data[current_position][0], self.historical_data[current_position][1]]
      return self.historical_data[current_position][1]
    end

    previous_ema = calculate_ema(number_of_days,current_position-1)

    current_ema = (self.historical_data[current_position][1] - previous_ema) * (2.0/(number_of_days+1)) + previous_ema

    self.calculated_ema << [self.historical_data[current_position][0],current_ema.round(4)]

    return current_ema
  end
end