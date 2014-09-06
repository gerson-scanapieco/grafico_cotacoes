# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
# data: [[x, y], [x, y], [x, y]]
$ ->

  $(".container-grafico").highcharts
    chart:
      type: "area"

    title:
      text: "Currencies Historical Data"

    subtitle:
      text: "Source: JSONRates"      

    yAxis:
      title:
        text: "Value in BRL"
      tickInterval: 0.1

    xAxis:
       type: "datetime"
       tickInterval: 24 * 3600 * 1000

    series: [
      {
        data: [
          0
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

  #Gets the selected time frame start from the user and calls subtract_date to calculate the start date
  calculate_start_date = (current_date)->
    checked_box = $("input[type=radio]:checked").parent().text().trim()
    return subtract_date(checked_box,current_date)

  $(".botao-teste").click ->
    btn = $(this)
    btn.button('loading')
    currency = $(".select-currency option:selected").text()

    current_date = new Date()
    current_date_formated = current_date.getFullYear().toString() + "-" + current_date.getMonth().toString() + "-" + current_date.getDate().toString()
    
    start_date = new Date(calculate_start_date(current_date))
    start_date_formated = start_date.getFullYear().toString() + "-" + start_date.getMonth().toString() + "-" + start_date.getDate().toString()

    url = "http://jsonrates.com/historical/?from=" + currency + "&to=BRL" +
    "&dateStart=" + start_date_formated + 
    "&dateEnd=" + current_date_formated + 
    "&callback=?"

    $.getJSON url, (data) ->
      array = []
      chart = $(".container-grafico").highcharts()
      for date of data["rates"]
        valor = data["rates"][date]["rate"]
        array.push [new Date(date).getTime(),parseFloat(valor)]
      btn.button('reset')
      console.log(array)
      chart.series[0].setData(array)

  #TODO

  # calcular data passada com base no radio selecionado OK
  # entender como funciona o grafico OK
  # plotar grafico com dados recebidos OK
  # ajustar zoom e unidade de tempo para graficos com longo periodo de tempo
  # testar tudo