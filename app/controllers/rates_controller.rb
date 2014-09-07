class RatesController < ApplicationController

  #Retorna JSON com 2 arrays:
  #array com os pontos do historico
  #calculated_ema com os pontos da media
  def get_chart
    puts "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
    puts charts_params
    respond_to do |format|
      format.json{ }
    end
  end

  private

  def charts_params
    params.permit!
  end
end