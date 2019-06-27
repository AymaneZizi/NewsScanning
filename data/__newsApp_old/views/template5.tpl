<!DOCTYPE html>
<meta charset="utf-8">

<style>

.table1{
  display: block;
  width: 400px;
  height: 200px;
  overflow-y: scroll;
}
}

body { font-family: 'Helvetica Neue', Helvetica; font-weight: 300; padding: 20px;}

th { text-align: left;
     color: #fff;
     font-size: 16px;
     text-align: center;
     font-family: Helvetica;
     font-weight: normal; 
     height: 20px;
     border-right-style: solid;
     border-left-style: solid;
     border-right-color: rgb(221,221,221);
     border-left-color: rgb(221,221,221);
     border-right-width: 1px;
     border-left-width: 1px;
     background: #24a9d1;
     padding: 1px, 2px
     font-family: Helvetica Neue,Helvetica,Arial,sans-serif;
     }

th, td { padding: 0 1em 0.5ex 0;
         height: 20px;
         text-align: center;
         vertical-align: middle;
         table-layout: fixed;
         overflow: hidden;
         }

tbody {
 width: 200px;
 height: 400px;
 overflow: auto;
}

    th.center, td.center { text-align: center; }
    th.num, td.num { text-align: right; }

button.btn-btn { background:none;border:none; }

.button {
  display: inline-block;
  margin: 0;
  padding: 0.75rem 1rem;
  border: 0;
  border-radius: 0.317rem;
  background-color: #aaa;
  color: #fff;
  text-decoration: none;
  font-weight: 700;
  font-size: 1rem;
  line-height: 1.5;
  font-family: "Helvetica Neue", Arial, sans-serif;
  cursor: pointer;
  -webkit-appearance: none;
  -webkit-font-smoothing: antialiased;
}

.button:hover {
  opacity: 0.85;
}

.button:active {
  box-shadow: inset 0 3px 4px hsla(0, 0%, 0%, 0.2);
}

.button:focus {
  outline: thin dotted #444;
  outline: 5px auto -webkit-focus-ring-color;
  outline-offset: -2px;
}

.button2 {
  display: inline-block;
  margin: 0;
  padding: 0.75rem 1rem;
  border: 0;
  border-radius: 0.317rem;
  background-color: #aaa;
  color: #fff;
  text-decoration: none;
  font-weight: 700;
  font-size: 1rem;
  line-height: 1.5;
  font-family: "Helvetica Neue", Arial, sans-serif;
  cursor: pointer;
  -webkit-appearance: none;
  -webkit-font-smoothing: antialiased;
}

.button2:hover {
  opacity: 0.85;
}

.button2:active {
  box-shadow: inset 0 3px 4px hsla(0, 0%, 0%, 0.2);
}

.button:2focus {
  outline: thin dotted #444;
  outline: 5px auto -webkit-focus-ring-color;
  outline-offset: -2px;
}

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
<script src="https://rawgit.com/gka/d3-jetpack/master/d3-jetpack.js"></script>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"></script>

<div class="row" style="margin:10px 10px 10px 10px;">
    <div class="col-md-4" id="line_chart" style="margin:10px 15px 10px 15px;">
	</div> 
</div>
<div class="row">
  <div class="col-md-12">
    <form action="/hello2" method="GET">
            <button name="querydate" type="submit" value="day" class="button">Previous Day</button>
            <button name="querydate" type="submit" value="week" class="button">Prevous Week</button>
            <button name="querydate" type="submit" value="month" class="button">Previous Month</button>
    </form>
  </div>
</div>
<div class="row">
  <div class="col-md-4" id="companies"></div>
  <div class="col-md-4" id="people"></div>
  <div class="col-md-4" id="orgs"></div>
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
var people_data = {{!response3}};
var company_data = {{!response5}};

console.log(csv_data)

function fixDates(){

 csv_data.forEach(function(d){d['date2'] = new Date(d['date2'])})
 csv_data.forEach(function(d){d['date3'] = new Date(d['date3'])})

 csv_data.forEach(function(d){d['date3'] = d['date3'].toString()})
 csv_data.forEach(function(d){d['date2'] = d['date2'].toString()})

 csv_data.forEach(function(d){d['date3'] = d['date3'].slice(0, 24)})
 csv_data.forEach(function(d){d['date2'] = d['date2'].slice(0, 24)})

 parseDate2 = d3.time.format("%a %b %d %Y %H:%M:%S").parse;
 parseDate = d3.time.format("%Y-%m-%d %H:%M:%S").parse;

};

fixDates();

 csv_data.forEach(function(d){ d['date2'] = parseDate2(d['date2']); });   
 day = d3.time.day.round;
 csv_data.forEach(function(d){ d['date2'] = day(d['date2'])});

function sortByDateAscending(a, b) {
    // Dates will be cast to numbers automagically:
    return a.date2 - b.date2;
}

csv_data2 = csv_data.sort(sortByDateAscending);

var count = d3.nest()
      .key(function(d) { return d['category']})
      .key(function(d) { return d['date2']})
      .rollup(function(csv_data) { return csv_data.length; })
      .sortValues(d3.descending)
      .entries(csv_data2)

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

xScale.domain(d3.extent(csv_data, function(d) { return d.date2; }))

yScale.domain([0, 40]);
                                                                       
svg.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0," + height_line + ")")
    .call(xAxis);

svg.append("g")
    .attr("class", "y axis")
    .call(yAxis);


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

  var columns = [
        { head: 'Company', cl: '_id', html: ƒ('_id') },
        { head: 'Mentions', cl: 'num', html: ƒ('count') }
        ];

    // create table
  var table = d3.select('#companies')
        .append('table')
        .attr("class", "table1");

    // create table header
    table.append('thead').append('tr')
        .selectAll('th')
        .data(columns).enter()
        .append('th')
        .attr('class', ƒ('cl'))
        .text(ƒ('head'));

    // create table body
    table.append('tbody')
        .append("xhtml:form")
        .attr("action", "/hello3")
        .attr("method", "GET")
        .selectAll('tr')
        .data(company_data).enter()
        .append('tr')
        .selectAll('td')
        .data(function(row, i) {
            return columns.map(function(c) {
                // compute cell values for this specific row
                var cell = {};
                d3.keys(c).forEach(function(k) {
                    cell[k] = typeof c[k] == 'function' ? c[k](row,i) : c[k];
                });
                return cell;
            });
        }).enter()
        .append('td')
        .append('button')
        .html(ƒ('html'))
      //  .attr('class', ƒ('cl'))
        .attr('type', 'submit')
        .attr('class', 'btn-btn')
        .attr('name', "query2")
        .attr('value', function(d) { return d.html });

  var columns2 = [
        { head: 'People', cl: '_id', html: ƒ('_id') },
        { head: 'Mentions', cl: 'num', html: ƒ('count') }
        ];

    // create table
  var table2 = d3.select('#people')
        .append('table')
        .attr("class", "table1");

    // create table header
    table2.append('thead').append('tr')
        .selectAll('th')
        .data(columns2).enter()
        .append('th')
        .attr('class', ƒ('cl'))
        .text(ƒ('head'));

    // create table body
    table2.append('tbody')
        .append("xhtml:form")
        .attr("action", "/hello3")
        .attr("method", "GET")
        .selectAll('tr')
        .data(people_data).enter()
        .append('tr')
        .selectAll('td')
        .data(function(row, i) {
            return columns.map(function(c) {
                // compute cell values for this specific row
                var cell = {};
                d3.keys(c).forEach(function(k) {
                    cell[k] = typeof c[k] == 'function' ? c[k](row,i) : c[k];
                });
                return cell;
            });
        }).enter()
        .append('td')
        .append('button')
        .html(ƒ('html'))
      //  .attr('class', ƒ('cl'))
        .attr('type', 'submit')
        .attr('class', 'btn-btn')
        .attr('name', "query2")
        .attr('value', function(d) { return d.html });


function length() {
        var fmt = d3.format('02d');
        return function(l) { return Math.floor(l / 60) + ':' + fmt(l % 60) + ''; };
}


</script>
</body>