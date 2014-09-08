# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
# data: [[x, y], [x, y], [x, y]]

$ ->

  $(".container-grafico").highcharts
    chart:
      title:
        text: "Currencies Historical Data"

      subtitle:
        text: "Source: JSONRates"    

      zoomType: "xy"  

    yAxis:
      title:
        text: "Value in BRL"
      tickPositioner: () ->
        positions = []
        unless this.series[0].yData.length == 0
          increment = (this.series[0].dataMax - this.series[0].dataMin)/3
          tick = this.series[0].dataMin - increment

          for i in [tick..this.series[0].dataMax + increment] by increment
            positions.push(i.toFixed(3))
          return positions

    xAxis:
       type: "datetime"
    
    series: [
      {
        name: "Historical Values",
        type: "area",
        data: [
        ]
      },
      { 
        name: "Exponential Moving Average",
        type: "line",
        color: "#ED475B",
        data: [
        ]
      }
    ]

  #ATENTION
  #JS RETURNS MONTH 0-11
  #Calculates the time frame start date by subtracting the selected amount by the user from the current date
  subtract_date = (start_date_text,current_date) ->
    start_date = new Date()
    switch start_date_text
      when "1D"
        start_date = start_date.setDate(current_date.getDate() - 1)
        break
      when "5D"
        start_date = start_date.setDate(current_date.getDate() - 5)
        break
      when "1M"
        start_date = start_date.setMonth(current_date.getMonth() - 1)
        break
      when "3M"
        start_date = start_date.setMonth(current_date.getMonth() - 3)
        break
      when "6M"
        start_date = start_date.setMonth(current_date.getMonth() - 6)
        break
      when "1Y"
        start_date = start_date.setYear(current_date.getFullYear() - 1)
        break
      when "2Y"
        start_date = start_date.setFullYear(current_date.getFullYear() - 2)
        break
      when "5Y"
        start_date = start_date.setFullYear(current_date.getFullYear() - 5)
        break
      when "MAX"
        start_date = start_date.setFullYear(current_date.getFullYear() - 10)
        break
    return start_date

  #TODO Remove method
  #Gets the selected time frame start from the user and calls subtract_date to calculate the start date
  calculate_start_date = (option,current_date)->
    return subtract_date(option,current_date)

  #Receives an array of pairs [date,value], the number of days for the average, an empty array that will keep the values
  #of the calculated average and the current position in the array(for the recursion)
  calculate_exponential_moving_average = (values,number_of_days,calculated_mme,current_position) ->
    #Weird condition
    if current_position < 0
      return

    #Base case: the average for only one element is itself
    if current_position == 0
      calculated_mme.push [values[current_position][0],values[current_position][1]]
      return values[current_position][1]

    #Recursive call
    previous_mme = calculate_exponential_moving_average(values,number_of_days,calculated_mme,current_position-1) 

    #Formula obtained in: http://www.investpedia.com.br/artigo/Indicadores+Conheca+as+medias+moveis.aspx
    current_mme = (values[current_position][1] - previous_mme) * (2/(number_of_days+1)) + previous_mme
    
    calculated_mme.push [values[current_position][0],current_mme]

    return current_mme

  $(".botao-js").click (event)->
    event.preventDefault();
    btn = $(this)
    btn.button('loading')
    currency = $(".select-currency option:selected").text()
    time_span = $(".select-time-span option:selected").text()

    current_date = new Date()
    current_date_formated = current_date.getFullYear().toString() + "-" + (current_date.getMonth() + 1).toString() + "-" + current_date.getDate().toString()
    
    start_date = new Date(calculate_start_date(time_span,current_date))
    start_date_formated = start_date.getFullYear().toString() + "-" + (start_date.getMonth() + 1).toString() + "-" + start_date.getDate().toString()

    url = "http://jsonrates.com/historical/?from=" + currency + "&to=BRL" +
    "&dateStart=" + start_date_formated + 
    "&dateEnd=" + current_date_formated + 
    "&callback=?"

    $.getJSON url, (data) ->
      $(".container-dados").empty()
      array = []
      calculated_mme = []
      chart = $(".container-grafico").highcharts()

      for date of data["rates"]
        valor = data["rates"][date]["rate"]
        array.push [new Date(date).getTime(),parseFloat(valor)]
      
      if time_span.indexOf("D") != -1
        chart.tickInterval = 24 * 3600 * 1000
      else if time_span.indexOf("M") != -1
        chart.tickInterval = 24 * 3600 * 1000 * 7
      else if time_span.indexOf("Y") != -1
        chart.tickInterval = 24 * 3600 * 1000 * 30

      calculate_exponential_moving_average(array,21,calculated_mme,array.length - 1)

      chart.series[0].setData(array)
      chart.series[1].setData(calculated_mme)

      $(".container-dados").append("<p>" + new Date(array[array.length-1][0]).toUTCString()+ ":</p>")
      $(".container-dados").append("<p class='currency'>" + currency + "BRL=X " + array[array.length-1][1] + "</p>")
      $(".container-dados").append("<p class='ema'>EMA(21) " + calculated_mme[calculated_mme.length-1][1] + "</p>")
      btn.button('reset')

  $(".botao-ruby").click (event) ->
    $(this).button('loading')