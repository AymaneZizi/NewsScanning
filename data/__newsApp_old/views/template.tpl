<!DOCTYPE html>
<html>

<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css">
 
<style>

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

    th.center, td.center { text-align: center; }
    th.num, td.num { text-align: right; }
    button.btn-btn { background:none;border:none; }
</style>

<head>

    <title>Simple tables in D3</title>
    <meta charset="utf-8">
    <script src="http://d3js.org/d3.v3.min.js"></script>
    <script src="https://rawgit.com/gka/d3-jetpack/master/d3-jetpack.js"></script>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"></script>

</head>

<body>

<form action="/hello" method="GET">
            <button name="query" type="submit" value="$people">People</button>
            <button name="query" type="submit" value="$organizations">Organizations</button>
            <button name="query" type="submit" value="$keyphrases">Key Phrases</button>
            <button name="query" type="submit" value="$locations">Locations</button>
            <button name="query" type="submit" value="$career">Career</button>
</form>
<form action="/hello3" method="GET">
            <button name="querydate" type="submit" value="day">Previous Day</button>
            <button name="querydate" type="submit" value="week">Prevous Week</button>
            <button name="querydate" type="submit" value="month">Previous Month</button>
</form>

    <script>

    var vals = {{!response}};
    console.log(vals)


    // column definitions
    var columns = [
        { head: 'Type', cl: '_id', html: ƒ('_id') },
        { head: 'count', cl: 'num', html: ƒ('count') }
        ];

    // create table
    var table = d3.select('body')
        .append('table');

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
        .attr("action", "/hello2")
        .attr("method", "GET")
        .selectAll('tr')
        .data(vals).enter()
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
</html>