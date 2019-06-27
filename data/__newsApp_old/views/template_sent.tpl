<!DOCTYPE html>
<meta charset="utf-8">

<style>
.tooltip {
  color: #222; 
  background: #fff; 
  padding: .5em; 
  text-shadow: #f5f5f5 0 1px 0;
  border-radius: 2px; 
  box-shadow: 0px 0px 2px 0px #a6a6a6; 
  opacity: 0.9; 
  position: absolute;
}

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
    <div class="col-md-4" id="scatter" style="margin:10px 15px 10px 15px;">
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

tooltip = d3.select("#scatter")
    .append("div")
    .attr("class", "tooltip")
    .attr("style", "hidden")

var margin_line = {top: 20, right: 80, bottom: 30, left: 50},
    width_line = 960 - margin_line.left - margin_line.right,
    height_line = 500 - margin_line.top - margin_line.bottom;

var svg = d3.select("#scatter").append("svg")
    .attr("width", width_line + margin_line.left + margin_line.right)
    .attr("height", height_line + margin_line.top + margin_line.bottom)
  .append("g")
    .attr("transform", "translate(" + margin_line.left + "," + margin_line.top + ")");

var xScale = d3.time.scale()
    .range([0,width_line - 50]);
    
var yScale = d3.scale.linear()
    .range([height_line,0]);

var xAxis = d3.svg.axis().scale(xScale)
    .orient("bottom").ticks(5);

var yAxis = d3.svg.axis().scale(yScale)
    .orient("left").ticks(5);

var csv_data = {{!response3}};

console.log(csv_data)

function fixDates(){

 csv_data.forEach(function(d){d['date2'] = new Date(d['date2']['$date'])})
 csv_data.forEach(function(d){d['date3'] = new Date(d['date3']['$date'])})

 csv_data.forEach(function(d){d['date3'] = d['date3'].toString()})
 csv_data.forEach(function(d){d['date2'] = d['date2'].toString()})

 csv_data.forEach(function(d){d['date3'] = d['date3'].slice(0, 24)})
 csv_data.forEach(function(d){d['date2'] = d['date2'].slice(0, 24)})

 parseDate2 = d3.time.format("%a %b %d %Y %H:%M:%S").parse;
 parseDate = d3.time.format("%Y-%m-%d %H:%M:%S").parse;

};

var color = d3.scale.threshold()
    .domain([-.9, -.05, .05, .2, .5, .9])
    .range(["#ff0000","#ff6666","#666699","#666699", "#99ff66", "#33cc33"]);

fixDates();

 csv_data.forEach(function(d){ d['date2'] = parseDate2(d['date2']); }); 
 csv_data.forEach(function(d){ d['date3'] = parseDate2(d['date3']); });    
 day = d3.time.day.round;
 csv_data.forEach(function(d){ d['date2'] = day(d['date2'])});

function sortByDateAscending(a, b) {
    // Dates will be cast to numbers automagically:
    return a.date2 - b.date2;
}

csv_data2 = csv_data.sort(sortByDateAscending);
csv_data2.forEach(function(d){d['docSentiment']['score'] = +d['docSentiment']['score']})
csv_data2.forEach(function(d){ if (isNaN(d['docSentiment']['score']) == true) {
  d['docSentiment']['score'] = 0;
}})
console.log(csv_data2)


xScale.domain(d3.extent(csv_data2, function(d) { return d.date3; }));
yScale.domain([d3.min(csv_data2, function(d) { return d.docSentiment.score; })-.1, d3.max(csv_data2, function(d) { return d.docSentiment.score; })+.1]);

svg.selectAll("dot")
        .data(csv_data2)
      .enter().append("circle")
        .attr("r", 5.0)
        .attr("cx", function(d) { return xScale(d.date3); })
        .attr("cy", function(d) { return yScale(d.docSentiment.score); })
        .style("fill", function(d) { return color(d.docSentiment.score); })
        .on("mousemove", function(d,i) {
      
        var mouse = d3.mouse(svg.node()).map( function(d) { return parseInt(d); } );

         tooltip.classed("hidden", false)
            .attr("style", "left:"+(mouse[0]+25)+"px;top:"+(mouse[1]-25)+"px")
            .attr("href", d.url);
          })
      .on("mouseout",  function(d,i) {
         tooltip.classed("hidden", true)});

svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + height_line + ")")
        .call(xAxis);

svg.append("g")
        .attr("class", "y axis")
        .call(yAxis);


//To open in a new tab include `target="_blank"` in your opening `a` tag per this page http://www.w3schools.com/html/html_links.asp. And for retrieving your url from a data set you will want to edit the line that says `http://google.com` with `'+d.imdb+'` (make sure you pay attention to the quotes :-)
</script>
</body>
