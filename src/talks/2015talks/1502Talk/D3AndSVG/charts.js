
function load_chart (raw_data)
{
	var data = raw_data.chart_data;

	var title_ele = "#my_chart_title";
	var svg_ele   = "#my_svg";

	if ("title_ele" in raw_data)
	{
		title_ele = "#" + raw_data.title_ele;
	}

	if ("svg_ele" in raw_data)
	{
		svg_ele = "#" + raw_data.svg_ele;
	}

	$(title_ele).html ("<H3>" + raw_data.name + "</H3>");

	var base_width = 1200;
	var base_height = 700;

	var x_min;
	var x_max;
	var y_min;
	var y_max;

	var x_date_min;
	var x_date_max;

	var bar;
	var barWidth;
	var candleWidth;

	var xAxis;
	var yAxis;

	var i;

	var margin = {top: 10, right: 20, bottom: 50, left: 50};

    width = base_width - margin.left - margin.right,
    height = base_height - margin.top - margin.bottom;

	var ys = d3.scale.linear ().range ([height, 0]);
	var xs = d3.time.scale ().range ([0, width]);

	var svg = d3.select (svg_ele).append ("svg")
		.attr ("width", width + margin.left + margin.right)
		.attr ("height", height + margin.top + margin.bottom)
		.style ("background-color", "black")
		.append ("g")
			.attr ("transform", "translate(" + margin.left + "," + margin.top + ")");

	xAxis = d3.svg.axis()
    	.scale(xs)
    	.orient("bottom");

	yAxis = d3.svg.axis()
    	.scale(ys)
    	.orient("left");

	xAxis.tickFormat (d3.time.format ("%b %d %Y"));

	function getYLow (d)
	{
		return ys (d.Low);
	}

	function getYHigh (d)
	{
		return ys (d.High);
	}

	function getYOC (d)
	{
		var yOpen = ys (d.Open);
		var yClose = ys (d.Close);

		if (yOpen < yClose)
		{
			return yOpen;
		}

		return yClose;
	}

	function getYHeight (d)
	{
		var yHeight = ys (d.Open) - ys (d.Close);
		if (yHeight < 0)
		{
			yHeight *= -1;
		}

		if (yHeight < 1)
		{
			yHeight = 1;
		}

		return yHeight;
	}

	function getXCandle (d)
	{
		var x = xs (d.Time) + (barWidth * bMargin);

		return x;
	}

	function getXHighLow (d)
	{
		var x = xs (d.Time) + (barWidth / 2.0);

		return x;
	}

	function getColor (d)
	{
		if (d.Close > d.Open)
			return "green";

		return "red";
	}

	var numPerTick = 10;
	if (raw_data.period == 1 ) { numPerTick = 7200; }
	if (raw_data.period == 60 ) { numPerTick = 48; }
	if (raw_data.period == 120) { numPerTick = 24; }
	if (raw_data.period == 240) { numPerTick = 24; }
	if (raw_data.period == 720) { numPerTick = 20; }
	if (raw_data.period == 1440) { numPerTick = 10; }
	if (raw_data.period == 10080 ) { numPerTick = 5; }
	if (raw_data.period == 43200 ) { numPerTick = 5; }

	numTicks = data.length / numPerTick;
	if (numTicks < 5)
	{
		numTicks = 5;
	}

	if (numTicks > 10)
	{
		numTicks = 10;
	}

	xAxis.ticks (numTicks);

	y_min = data [0].Low;
	y_max = data [0].High;

	if ("ema" in data [0])
	{
		y_min = Math.min (y_min, data [0].ema);
		y_max = Math.max (y_max, data [0].ema);
	}

	if ('ma' in data [0])
	{
		y_min = Math.min (y_min, data [0].ma);
		y_max = Math.max (y_max, data [0].ma);
	}

	for (i = 1; i < data.length; ++i)
	{
		y_min = Math.min (y_min, data [i].Low);
		y_max = Math.max (y_max, data [i].High);

		if ('ma' in data [i])
		{
			y_min = Math.min (y_min, data [i].ma);
			y_max = Math.max (y_max, data [i].ma);
		}

		if ('ema' in data [i])
		{
			y_min = Math.min (y_min, data [i].ema);
			y_max = Math.max (y_max, data [i].ema);
		}
	}

	x_min = data [0].Time;
	x_max = data [data.length - 1].Time;

	x_min = +x_min - (raw_data.period * 60 * 1000);
	x_max = +x_max + (raw_data.period * 60 * 1000);

	ys.domain ([y_min, y_max]);
	xs.domain ([x_min, x_max]);

	var bMargin = 0.125;

	barWidth = xs (+x_min + (raw_data.period * 60 * 1000)) - xs (+x_min);
	if (barWidth < 1) { barWidth = 1; }
	candleWidth = barWidth * (1.0 - (2.0 * bMargin));
	if (candleWidth < 1) { candleWidth = 1; }

	svg.append("g")
		.attr("class", "x axis")
		.attr("transform", "translate(0," + height + ")")
		.attr("stroke", "white")
		.call(xAxis);

	svg.append("g")
		.attr("class", "y axis")
		.attr("stroke", "white")
		.call(yAxis);

	svg.selectAll (".candle_bar")
		.data (data)
		.enter ().append ("rect")
			  .attr ("class",  "candle_bar")
			  .attr ("x",      getXCandle)
			  .attr ("y",      getYOC)
			  .attr ("height", getYHeight)
			  .attr ("width",  candleWidth)
			  .attr ("fill",   getColor);

	svg.selectAll ("candle_hl")
		.data (data)
		.enter ().append ("svg:line")
			.attr ("x1",       getXHighLow)
			.attr ("y1",       getYLow)
			.attr ("x2",       getXHighLow)
			.attr ("y2",       getYHigh)
			.style ("stroke",  getColor);

	var data_sma = new Array ();
	var data_ema = new Array ();

	for (i = 0; i < data.length; ++i)
	{
		if ('ma' in data [i])
		{
			data_sma.push (data [i]);
		}

		if ('ema' in data [i])
		{
			data_ema.push (data [i]);
		}
	}

	var line_sma = d3.svg.line ().x (function (d, i) { return xs (d.Time); })
		.y (function (d, i) { return ys (d.ma); });

	svg.append ("path")
		.attr ("d", line_sma (data_sma))
		.attr ("stroke", "white")
		.attr ("fill", "none");

	var line_ema = d3.svg.line ().x (function (d, i) { return xs (d.Time); })
		.y (function (d, i) { return ys (d.ema); });

	svg.append ("path")
		.attr ("d", line_ema (data_ema))
		.attr ("stroke", "orange")
		.attr ("fill", "none");
}

var pointRadius = 5;

function drawPoint (svg, x, y, color, xchar)
{
	if (xchar == 'x')
	{
		svg.append ("line")
			.attr ("x1", x - 5)
			.attr ("y1", y + 5)
			.attr ("x2", x + 5)
			.attr ("y2", y - 5)
			.attr ("stroke", color);

		svg.append ("line")
			.attr ("x1", x - 5)
			.attr ("y1", y - 5)
			.attr ("x2", x + 5)
			.attr ("y2", y + 5)
			.attr ("stroke", color);
	}
	else if (xchar == '+')
	{
		svg.append ("line")
			.attr ("x1", x)
			.attr ("y1", y + 5)
			.attr ("x2", x)
			.attr ("y2", y - 5)
			.attr ("stroke", color);

		svg.append ("line")
			.attr ("x1", x - 5)
			.attr ("y1", y)
			.attr ("x2", x + 5)
			.attr ("y2", y)
			.attr ("stroke", color);
	}
	else if (xchar == '*')
	{
		svg.append ("line")
			.attr ("x1", x - 5)
			.attr ("y1", y + 5)
			.attr ("x2", x + 5)
			.attr ("y2", y - 5)
			.attr ("stroke", color);

		svg.append ("line")
			.attr ("x1", x - 5)
			.attr ("y1", y - 5)
			.attr ("x2", x + 5)
			.attr ("y2", y + 5)
			.attr ("stroke", color);

		svg.append ("line")
			.attr ("x1", x)
			.attr ("y1", y + 5)
			.attr ("x2", x)
			.attr ("y2", y - 5)
			.attr ("stroke", color);

		svg.append ("line")
			.attr ("x1", x - 5)
			.attr ("y1", y)
			.attr ("x2", x + 5)
			.attr ("y2", y)
			.attr ("stroke", color);
	}
}

function type (d) 
{
	d.Time = +d.Time;
	d.Open = +d.Open;
	d.High = +d.High;
	d.Low = +d.Low;
	d.Close = +d.Close;
	d.ma= +d.ma;
	d.ema = +d.ema;

	return d;
}

