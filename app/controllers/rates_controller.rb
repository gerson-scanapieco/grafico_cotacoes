class RatesController < ApplicationController
  respond_to :html, :js

  def get_chart
    start_date = Rate.calculate_start_date(charts_params[:time_span])
    @rate = Rate.new(charts_params[:currency],start_date, Date.today.to_s)
    @rate.get_data
    @rate.calculate_ema(21,@rate.historical_data.size-1)
  end

  private

  def charts_params
    params.permit(:utf8,:commit,:currency,:time_span)
  end
end