<!DOCTYPE html>
<meta charset="utf-8">

<style>

svg {
  font: 10px sans-serif;
}

.axis path,
.axis line {
    fill: none;
    stroke: grey;
    stroke-width: 1;
    shape-rendering: crispEdges;
}
.x.axis path {
  fill:none;
  stroke:#000;
  shape-rendering: crispEdges;
}

.line {
  fill: none;
  stroke-width: 2.0px;
}

</style>

<body>

<script src="http://d3js.org/d3.v3.js"></script>

<div class="row" style="margin:10px 10px 10px 10px;">
    <div class="col-md-4" id="line_chart" style="margin:10px 15px 10px 15px;">
	</div> 
</div>

<script>

var margin_line = {top: 20, right: 80, bottom: 30, left: 50},
    width_line = 960 - margin_line.left - margin_line.right,
    height_line = 500 - margin_line.top - margin_line.bottom;

var svg = d3.select("#line_chart").append("svg")
    .attr("width", width_line + margin_line.left + margin_line.right)
    .attr("height", height_line + margin_line.top + margin_line.bottom)
  .append("g")
    .attr("transform", "translate(" + margin_line.left + "," + margin_line.top + ")");

var xScale = d3.time.scale()
    .range([0,width_line - 50]);
    
var yScale = d3.scale.linear()
    .range([height_line,0]);

var line = d3.svg.line()
    .interpolate("linear")
    .x(function(d) { return xScale(d.key); })
    .y(function(d) { return yScale(d.values); });

  var csv_data = {{!response2}};
console.log(csv_data)

 parseDate = d3.time.format("%Y-%m-%d %H:%M:%S").parse;
 csv_data.forEach(function(d){ d['date3'] = parseDate(d['date3']); });   
 day = d3.time.day.round;
 csv_data.forEach(function(d){ d['date3'] = day(d['date3'])});

function sortByDateAscending(a, b) {
    // Dates will be cast to numbers automagically:
    return a.date3 - b.date3;
}

csv_data2 = csv_data.sort(sortByDateAscending);

var count = d3.nest()
      .key(function(d) { return d['category']})
      .key(function(d) { return d['date3']})
      .rollup(function(csv_data) { return csv_data.length; })
      .sortValues(d3.descending)
      .entries(csv_data2)

parseDate2 = d3.time.format("%a %b %d %Y %H:%M:%S").parse;

count.forEach(function(d) { 
  d.values.forEach(function(b) { 
    b['key'] = b['key'].slice(0, 24);
    b['key'] = parseDate2(b['key']) 
  });});

new_count = count.splice(0, 10)

var color = d3.scale.category10();

var xAxis = d3.svg.axis()
    .scale(xScale)
    .orient("bottom")

formatValue = d3.format(".2s");

var yAxis = d3.svg.axis()
    .scale(yScale)
    .orient("left")
    .tickFormat(function(d) { return formatValue(d)})

var mindate = new Date(2016,0,22),
    maxdate = new Date(2016,0,27);

xScale.domain([mindate, maxdate]);
yScale.domain([0, 75]);
                                                                       
svg.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0," + height_line + ")")
    .call(xAxis);

svg.append("g")
    .attr("class", "y axis")
    .call(yAxis);

console.log(new_count)    

var lines = svg.selectAll(".line")
    .data(new_count, function(d) { return d.key; })
    .attr("class","line")

    lines.enter()
         .append("path")
         .attr("class", "line")
         .attr("d", function(d) { return line(d.values); })
         .style("stroke", function(d) { return color(d.key); });

var legend = svg.selectAll(".legend")
            .data(new_count, function(d) { return d.key; })
          .enter().append("g")
            .attr("class", "legend")
            .attr("transform", function (d, i) { 
              return "translate(55," + i * 20 + ")"; 
            });

        legend.append("rect")
            .attr("x", width_line - 10)
            .attr("width", 10)
            .attr("height", 10)
            .style("fill", function(d) { return color(d.key); })
            .style("stroke", "grey");

        legend.append("text")
            .attr("x", width_line - 12)
            .attr("y", 6)
            .attr("dy", ".35em")
            .style("text-anchor", "end")
            .text(function (d) { return d.key; });


</script>
</body>