App que exibe um gráfico das cotacoes do Dolar, Euro e Libra em relação ao Real nos últimos meses. Os gráficos ainda exibem a Média Móvel Exponencial dos útimos 21 dias.
A fonte dos dados eh a API JSONRates, e os gráficos foram implementados usando Highcharts e Stockcharts.

A app possui 3 formas de exibir os gráficos:

- Botão Verde: usa JavaScript para se comunicar com a API.
- Botão Vermelho: usa o servidor Rails para se comunicar com a API. 
- Botão Amarelo: usa JavaScript para se comunicar com a API, mas renderiza o gráfico StockChart.

Testes para o código Rails implementados com RSpec.