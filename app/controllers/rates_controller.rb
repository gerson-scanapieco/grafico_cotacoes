class RatesController < ApplicationController

  def get_chart
    start_date = Rate.calculate_start_date(charts_params[:time_span])
    rate = Rate.new(currency: charts_params[:currency], start_date: start_date, end_data: Date.today.to_s)
    rate.get_data
    rate.calculate_ema

    respond_to do |format|
      format.js{ }
    end
  end

  private

  def charts_params
    params.permit(:utf8,:commit,:currency,:time_span)
  end
end