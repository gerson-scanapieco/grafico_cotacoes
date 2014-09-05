# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $("#container").highcharts
    chart:
      type: "bar"

    title:
      text: "Fruit Consumption"

    xAxis:
      categories: [
        "Apples"
        "Bananas"
        "Oranges"
      ]

    yAxis:
      title:
        text: "Fruit eaten"

    series: [
      {
        name: "Jane"
        data: [
          1
          0
          4
        ]
      }
      {
        name: "John"
        data: [
          5
          7
          3
        ]
      }
    ]

  return
