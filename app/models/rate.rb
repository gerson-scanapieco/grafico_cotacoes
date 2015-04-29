class Rate
  attr_reader :url, :currency
  attr_accessor :historical_data, :calculated_ema

  def initialize(currency,start_date,end_date)
    @url = 
      "http://jsonrates.com/historical/?from=" + currency + "&to=BRL" + "&dateStart=" + start_date + "&dateEnd=" + end_date +
      "&apiKey=" + ENV['API_KEY'] 
    @currency = currency
    @calculated_ema = []
    @historical_data = []
  end

  #Calculates the starting date based on the time-span selected by the user.
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
    else
      return (Date.today - 1.days).to_s
    end
  end

  #Gets data from the API and inserts in the @historial_data field.
  def get_data
    parsed_response = JSON.parse(HTTParty.get(self.url).parsed_response)["rates"]

    #Add to @historical_data the date in milliseconds and the value in that day
    parsed_response.each_value do |value|
      self.historical_data << [Date.parse(value["utctime"]).strftime("%Q").to_i,value["rate"].to_f]
    end
  end

  #Recursively calculates the EMA from each date point in @historical_data field.
  def calculate_ema(number_of_days,current_position)
    #Weird condition
    if current_position < 0
      return
    end

    #Base Case
    if current_position == 0
      self.calculated_ema << [self.historical_data[current_position][0], self.historical_data[current_position][1]]
      return self.historical_data[current_position][1]
    end

    #Recursive call. Since the recursive call is called twice in the calculation process, it makes sense to detach it from
    #the formula and call it only once
    previous_ema = calculate_ema(number_of_days,current_position-1)

    #EMA calculation
    current_ema = (self.historical_data[current_position][1] - previous_ema) * (2.0/(number_of_days+1)) + previous_ema

    #Inserts the calculated EMA in @calculated_ema array
    self.calculated_ema << [self.historical_data[current_position][0],current_ema.round(4)]

    #Returns the current_ema to next calculation
    return current_ema
  end
end