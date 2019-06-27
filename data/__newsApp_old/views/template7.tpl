<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8"/>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/underscore.js/1.8.3/underscore.js"></script>
    <script src="http://d3js.org/d3.v3.js"></script>
    <script src="http://d3js.org/colorbrewer.v1.min.js"></script>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/crossfilter/1.3.12/crossfilter.js"></script>
    <script src="https://cdn.jsdelivr.net/bootstrap.tagsinput/0.8.0/bootstrap-tagsinput.min.js"></script>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/bootstrap.tagsinput/0.8.0/bootstrap-tagsinput.css" />
    <link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.css">


<style type="text/css">

.label-info {
    background-color: #999999;
}

p {
    padding: 0px 0px 0px 0px;
    margin: 0px 0px 0px 0px;
}

.bootstrap-tagsinput {
  border: none;
}

.bootstrap-tagsinput .tag [data-role="remove"]:after {
  content: none;
  padding: 0px 0px;
  box-shadow: none;
}

.node circle {
  cursor: pointer;
  fill: #fff;
  stroke: steelblue;
  stroke-width: 1.5px;
}

.node text {
  font-size: 11px;
}

path.link {
  fill: none;
  stroke: #ccc;
  stroke-width: 1.5px;
}

#curve-text {
  font: 14px sans-serif;
  stroke: url(#gradient);
  opacity: 0.5;
}


.tooltip {
  color: #222; 
  background: #fff; 
  padding: .5em; 
  text-shadow: #f5f5f5 0 1px 0;
  border-radius: 2px; 
  box-shadow: 0px 0px 2px 0px #a6a6a6; 
  opacity: 0.9; 
  position: absolute;
  font-size: 10px;
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

.lineSent {
  fill: none;
  stroke: grey;
  stroke-width: 1.5px;
}

</style>
</head>

<body>
<div class="row" style="margin:5px 5px 5px 5px;">
  <div class="col-md-12" id="main" style="margin:25px 5px 0px 5px;">
  </div>
</div>
<div class="row" style="margin:5px 5px 5px 5px;" id="testing">
  <div class="col-md-8" id="scatter" style="margin:25px 5px 0px 5px;"></div>
  <div class="col-md-3" id="highlights" style="margin: 40px 5px 0px 5px;">
    <p> People </p>
    <div class="input-group">
       <select multiple data-role="tagsinput" id="persontags">
       </select>
    </div>
    <p> Companies </p>
      <div class="input-group">
       <select multiple data-role="tagsinput" id="companytags">
       </select>
      </div>
    <p> Keywords </p>
      <div class="input-group">
       <select multiple data-role="tagsinput" id="keywordstags">
       </select>
      </div>
    <p> Concepts </p>
      <div class="input-group">
       <select multiple data-role="tagsinput" id="conceptstags">
       </select>
      </div>
  </div>
</div>      
      
<script type="text/javascript">

var json = {{!flare}};
var csv_data = {{!response3}};
var person = {{!person_aggr}};
var company = {{!company_aggr}};
var keywords = {{!keywords_aggr}};
var concepts = {{!concepts_aggr}};

d3.select("#persontags").selectAll("option")
                    .data(person)
                  .enter().append("option")
                    .attr("value", function(d) { return d._id })

d3.select("#companytags").selectAll("option")
                    .data(company)
                  .enter().append("option")
                    .attr("value", function(d) { return d._id })

d3.select("#keywordstags").selectAll("option")
                    .data(keywords)
                  .enter().append("option")
                    .attr("value", function(d) { return d._id })

d3.select("#conceptstags").selectAll("option")
                    .data(concepts)
                  .enter().append("option")
                    .attr("value", function(d) { return d._id })


$('select').tagsinput({
  maxTags: 10
});
                      
var m = [20, 120, 20, 120],
    w = 1280 - m[1] - m[3],
    h = 320 - m[0] - m[2],
    i = 0,
    root;

var tree = d3.layout.tree()
    .size([h, w]);

var diagonal = d3.svg.diagonal()
    .projection(function(d) { return [d.y, d.x]; });

var vis = d3.select("#main").append("svg")
    .attr("width", w + m[1] + m[3])
    .attr("height", h + m[0] + m[2])
  .append("svg:g")
    .attr("transform", "translate(" + m[3] + "," + m[0] + ")");

var tooltip = d3.select("#scatter")
      .append("div")
      .attr("class", "tooltip")
      .attr("style", "hidden")

var margin_line = {top: 20, right: 80, bottom: 30, left: 50},
    width_line = 1080 - margin_line.left - margin_line.right,
    height_line = 500 - margin_line.top - margin_line.bottom;
    width_high = 390 - margin_line.left - margin_line.right,
    height_high = 500 - margin_line.top - margin_line.bottom;

var svg = d3.select("#scatter").append("svg")
    .attr("width", width_line + margin_line.left + margin_line.right)
    .attr("height", height_line + margin_line.top + margin_line.bottom)
  .append("g")
    .attr("transform", "translate(" + margin_line.left + "," + margin_line.top + ")");

var svg_highlights = d3.select("#highlights").append("svg")
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

var color = d3.scale.threshold()
    .domain([-.8, -.6, -.4, -.2, 0, .2, .4, .6, .8])
    .range(colorbrewer.RdYlGn[10]);

root = json;
root.x0 = h / 2;
root.y0 = 0;

function toggleAll(d) {
    if (d.children) {
      d.children.forEach(toggleAll);
      toggle(d);
    }
  };

  // Initialize the display to show a few nodes.
  root.children.forEach(toggleAll);

  toggleAll(root);
  update(root);

function getCategory(name){
  $.ajax({
  type: "GET",
  url: "/main",
  data: {"name":name}, 
  success: function(data) {

    var csv_data = {{!response3}};
    var person = {{!person_aggr}};
    var company = {{!company_aggr}};
    var keywords = {{!keywords_aggr}};
    var concepts = {{!concepts_aggr}};
    div_name = "#testing";

    updateData(csv_data, person, company, keywords, concepts);
  }

})};

function update(source) {
  var duration = d3.event && d3.event.altKey ? 5000 : 500;

  // Compute the new tree layout.
  var nodes = tree.nodes(root).reverse();

  // Normalize for fixed-depth.
  nodes.forEach(function(d) { d.y = d.depth * 180; });

  // Update the nodes…
  var node = vis.selectAll("g.node")
      .data(nodes, function(d) { return d.id || (d.id = ++i); });

  // Enter any new nodes at the parent's previous position.
  var nodeEnter = node.enter()
      .append("g")
      .attr("class", "node")
      .attr("transform", function(d) { return "translate(" + source.y0 + "," + source.x0 + ")"; })
      .on("click", function(d) { toggle(d); update(d); });

  nodeEnter.append("circle")
      .attr("r", 1e-6)
      .style("fill", function(d) { return d._children ? "lightsteelblue" : "#fff"; })

  nodeEnter.append("text")
      .attr("x", function(d) { return d.children || d._children ? -10 : 10; })
      .attr("dy", ".35em")
      .attr("text-anchor", function(d) { return d.children || d._children ? "end" : "start"; })
      .text(function(d) { return d.name; })
      .style("fill-opacity", 1e-6)
      .on("click",  function(d) { getCategory(d.name);
        })

  // Transition nodes to their new position.
  var nodeUpdate = node.transition()
      .duration(duration)
      .attr("transform", function(d) { return "translate(" + d.y + "," + d.x + ")"; });

  nodeUpdate.select("circle")
      .attr("r", 4.5)
      .style("fill", function(d) { return d._children ? "lightsteelblue" : "#fff"; });

  nodeUpdate.select("text")
      .style("fill-opacity", 1);

  // Transition exiting nodes to the parent's new position.
  var nodeExit = node.exit().transition()
      .duration(duration)
      .attr("transform", function(d) { return "translate(" + source.y + "," + source.x + ")"; })
      .remove();

  nodeExit.select("circle")
      .attr("r", 1e-6);

  nodeExit.select("text")
      .style("fill-opacity", 1e-6);

  // Update the links…
  var link = vis.selectAll("path.link")
      .data(tree.links(nodes), function(d) { return d.target.id; });

  // Enter any new links at the parent's previous position.
  link.enter().insert("svg:path", "g")
      .attr("class", "link")
      .attr("d", function(d) {
        var o = {x: source.x0, y: source.y0};
        return diagonal({source: o, target: o});
      })
    .transition()
      .duration(duration)
      .attr("d", diagonal);

  // Transition links to their new position.
  link.transition()
      .duration(duration)
      .attr("d", diagonal);

  // Transition exiting nodes to the parent's new position.
  link.exit().transition()
      .duration(duration)
      .attr("d", function(d) {
        var o = {x: source.x, y: source.y};
        return diagonal({source: o, target: o});
      })
      .remove();

  // Stash the old positions for transition.
  nodes.forEach(function(d) {
    d.x0 = d.x;
    d.y0 = d.y;
  });
}

// Toggle children.
function toggle(d) {
  if (d.children) {
    d._children = d.children;
    d.children = null;
  } else {
    d.children = d._children;
    d._children = null;
  }
}


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

keywords = csv_data2.filter(function(d, i) { return })

var avgSentiment = d3.nest()
  .key(function(d) { return d.date2; })
  .rollup(function(v) { return d3.mean(v, function(d) { return d.docSentiment.score; }); })
  .entries(csv_data2);

avgSentiment.forEach(function(d){d['key'] = d['key'].slice(0, 24)})

parseSentDate = d3.time.format("%a %b %d %Y %H:%M:%S").parse;  

avgSentiment.forEach(function(d){ d['key'] = parseSentDate(d['key']); }); 

xScale.domain(d3.extent(csv_data2, function(d) { return d.date2; }));
yScale.domain([d3.min(csv_data2, function(d) { return d.docSentiment.score; })-.1, d3.max(csv_data2, function(d) { return d.docSentiment.score; })+.1]);

svg.selectAll("dot")
        .data(csv_data2)
      .enter().append("circle")
        .attr("r", 5.0)
        .style("opacity", 0.8)
        .attr("cx", function(d) { return xScale(d.date2); })
        .attr("cy", function(d) { return yScale(d.docSentiment.score); })
        .style("fill", function(d) { return color(d.docSentiment.score); })
        .style("stroke", "#808080")
        .on("mouseover", function(d,i) {

          d3.select(this).style("r", 7.0)
                         .style("opacity", 1)
      
          tooltip.classed("hidden", false)
            .style("left", (d3.event.pageX - 5) + "px")
            .style("top", (d3.event.pageY - 420) + "px")
            .html(d.url);
          })
      .on("mouseout",  function(d,i) {

        d3.select(this).style("r", 5.0)
                         .style("opacity", 0.8)

         tooltip.classed("hidden", true)});

var line = d3.svg.line()
    .interpolate("basis")
    .x(function(d) { return xScale(d.key); })
    .y(function(d) { return yScale(d.values); });

/*
svg.append("linearGradient")
      .attr("id", "gradient")
      .attr("gradientUnits", "userSpaceOnUse")
      .attr("x1", xScale(d3.min(csv_data2, function(d) { return d.date3})))
      .attr("y1", yScale(-0.1))
      .attr("x2", xScale(d3.max(csv_data2, function(d) { return d.date3})))
      .attr("y2", yScale(0.1))
    .selectAll("stop")
      .data([
        {offset: "-1.0", color: "red"},
        {offset: "-0.1", color: "red"},
        {offset: "-0.1", color: "green"},
        {offset: "1.0", color: "green"}
      ])
    .enter().append("stop")
      .attr("offset", function(d) { return d.offset; })
      .attr("stop-color", function(d) { return d.color; });
*/

svg.append("path")
    .attr("d", line(avgSentiment))
    .attr("class", "lineSent")
    .attr("id", "curve")
    .style("stroke-width", 1)
    .style("stroke-dasharray", "6,6");   

/*
svg.append("line")
    .attr("x1", xScale(d3.min(csv_data2, function(d) { return d.date3})))
    .attr("y1", yScale(0.1))
    .attr("x2", xScale(d3.max(csv_data2, function(d) { return d.date3})))
    .attr("y2", yScale(0.1))
    .style("stroke", "#dfdfdf")
    .style("stroke-width", 1)
    .style("stroke-dasharray", "4,4");

svg.append("line")
    .attr("x1", xScale(d3.min(csv_data2, function(d) { return d.date3})))
    .attr("y1", yScale(-0.1))
    .attr("x2", xScale(d3.max(csv_data2, function(d) { return d.date3})))
    .attr("y2", yScale(-0.1))
    .style("stroke", "#dfdfdf")
    .style("stroke-width", 1)
    .style("stroke-dasharray", "4,4");

svg.append("text")
    .attr("x", 15)
    .attr("y", yScale(-0.02))
    .style("fill", "dfdfdf")
    .style("font-size", "24px")
    .text("Neutral")

*/

svg.append("text")
        .attr("x", (width_line / 2))             
        .attr("y", 0 - (margin_line.top / 2.5))
        .attr("text-anchor", "middle")  
        .style("font-size", "16px")
        .style("fill", "#999999") 
        .text("Category Sentiment");

svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + height_line + ")")
        .call(xAxis);

svg.append("text")
            .attr("text-anchor", "middle")  
            .attr("transform", "translate("+ (width_line/2) +","+(height_line + (margin_line.top * 1.5))+")")
            .style("font-size", "14px")
            .style("fill", "#999999")
            .text("Date");

svg.append("g")
        .attr("class", "y axis")
        .call(yAxis);

svg.append("text")
            .attr("text-anchor", "middle")
            .attr("transform", "translate("+ (-margin_line.top *2) +","+(height_line/2)+")rotate(-90)")
            .style("font-size", "14px")
            .style("fill", "#999999")
            .text("Article Sentiment");

svg.append("text")
    .attr("id", "curve-text")
  .append("textPath")
    .attr("xlink:href", "#curve")
    .style("text-anchor","middle")
    .attr("startOffset", "50%") 
    .text("Average Sentiment.");


var csv_data = {{!response3}};
var person = {{!person_aggr}};
var company = {{!company_aggr}};
var keywords = {{!keywords_aggr}};
var concepts = {{!concepts_aggr}};

function updateData(csv_data, person, company, keywords, concepts) {





}

    </script>
  </body>
</html>