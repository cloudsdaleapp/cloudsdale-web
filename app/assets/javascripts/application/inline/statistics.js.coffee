$ ->
  new Highcharts.Chart
    chart: {
      renderTo: 'users_chart',
      defaultSeriesType: 'spline',
      backgroundColor: 'rgba(255,255,255,0)'
    }
    title: { text: 'Users' }
    xAxis: { type: 'datetime' }
    yAxis: {
      title: null,
      allowDecimals: false,
      min: 0
    }
    plotOptions: {
       spline: {
          lineWidth: 4,
          states: {
             hover: {
                lineWidth: 5
             }
          },
          marker: {
             enabled: false,
             states: {
                hover: {
                   enabled: true,
                   symbol: 'circle',
                   radius: 5,
                   lineWidth: 1
                }
             }   
          },
          pointInterval: 86400000,
          pointStart: $('#users_chart').data().start_date
          pointEnd: $('#users_chart').data().end_date
       }
    }
    series: [{
      name: "Total"
      data: $('#users_chart').data().total_users
    },
    {
      name: "New"
      data: $('#users_chart').data().new_users
    }]