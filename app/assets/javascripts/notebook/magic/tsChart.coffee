define([
    'observable'
    'knockout'
    'd3'
    'c3'
], (Observable, ko, d3, c3) ->
  (dataO, container, options) ->
    w = options.width||600
    h = options.height||400

    chart_container = $("<div>").addClass("custom-c3-chart").attr("width", w+"px").attr("height", h+"px")
    chart_container.attr("id", "custom-c3-chart-"+@genId).appendTo(container)

    data = {}

    # Datetime data are coming as formatted strings. We need to tell about the format to c3 lib. But we still want
    # to support opening old notebooks with old format (timestamp in miliseconds) without need to regenerate the data.
    if (@dataInit.length > 0) && typeof @dataInit[0][options.x] is 'string'
      # https://github.com/d3/d3-time-format/blob/master/README.md#locale_format
      data.xFormat = '%Y-%m-%d %H:%M:%S %a %Z'

    prepareData = (data, ds) ->
      if options.g
        groups = _.unique(ds.map((d) -> d[options.g]))
        xs = {}
        cols = {}
        groups.forEach((g) =>
          xs[""+g] = ""+g+"_x"
          cols[""+g] = []
          cols[""+g+"_x"] = []
        )
        ds.forEach((d) =>
          cols[d[options.g]+"_x"].push(d[options.x])
          cols[d[options.g]].push(d[options.y])
        )
        data.columns = []
        _.each(cols, (c, k) =>
          c.unshift(k)
          data.columns.push(c)
        )
        data.xs = xs
      else
        xs = {}
        xs[options.x] = options.x
        data.x = options.x
        dataI = _.map(ds, (d) -> [d[options.x], d[options.y]])
        dataI.unshift([options.x, options.y])
        data.rows = dataI
      data

    chart = c3.generate(
      bindto: "#" + chart_container.attr("id"),
      data: prepareData(data, @dataInit),
      axis: {
        x: {
          type: 'timeseries',
          tick: {
            format: options.tickFormat
          }
        },
        y: {
          label: options.y
        }
      }
    )

    dataO.subscribe( (newData) =>
      #chart.unload();
      chart.load(prepareData(data, newData));
    )
)
