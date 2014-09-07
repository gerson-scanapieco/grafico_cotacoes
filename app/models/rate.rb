class Rate
  include ActiveModel::Model

  attr_accessor :currency, :time_span, :url, :historial_data, :calculated_average


  def fetch_data_from_api
  end
end
