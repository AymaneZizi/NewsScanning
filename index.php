<?php

   /* Include the ../src/fusioncharts.php file that contains functions to embed the charts.*/
   include("scripts/fusioncharts.php");
?>
<html>

<head>
    <title>FusionCharts | My First Chart</title>
    <script src="scripts/fusion/fusioncharts.js"></script>
    <script src="https://cdn.fusioncharts.com/fusioncharts/latest/themes/fusioncharts.theme.fusion.js"></script>
    <style>
        html {
            font-family: Arial;
            text: rgba(40,40,40,0);
            background: rgba(250,250,250,0.95);
            margin: 0;
            padding: 0;
            width: 100%;
            height: 100%;
        }
        
        #main {
            margin: auto 30%;
        }
        
    </style>
</head>

<body>
    <div id='main'>
    <?php
        echo "<p>I'll proabably build this in <b>PHP/Javascript/Node.js/SQL</b> using pipes to Python files for data manipulation if needed.<br>";
        echo "The backend will consist of a <b>SQLite3 or NoSQL</b> database that is populated by a scheduled Python script that pulls full-text news articles from RSS feeds.<br>";
        echo "That database will also have NLP algoritms applied to it to tag it with metadata such as <b>named entities, topic classification, and sentiment analysis</b>.</p>";
        echo "<p>The frontend will show current trends/analytics using various visualisations and allow for custom querying.<br>";
        echo "It could also feature a form/method to add/modify RSS feeds."
    ?>
    </div>

    <?php
    //Tutorial: https://www.fusioncharts.com/dev/getting-started/php/your-first-chart-using-php
    // Chart Configuration stored in Associative Array
    $arrChartConfig = array(
        "chart" => array(
            "caption" => "Countries With Most Oil Reserves [2017-18]",
            "subCaption" => "In MMbbl = One Million barrels",
            "xAxisName" => "Country",
            "yAxisName" => "Reserves (MMbbl)",
            "numberSuffix" => "K",
            "exportEnabled" => "1",
            "theme" => "fusion"
        )
    );
    // An array of hash objects which stores data
    $arrChartData = array(
        ["Venezuela", "290"],
        ["Saudi", "260"],
        ["Canada", "180"],
        ["Iran", "140"],
        ["Russia", "115"],
        ["UAE", "100"],
        ["US", "30"],
        ["China", "30"]
    );

    $arrLabelValueData = array();

    // Pushing labels and values
    for($i = 0; $i < count($arrChartData); $i++) {
        array_push($arrLabelValueData, array(
            "label" => $arrChartData[$i][0], "value" => $arrChartData[$i][1]
        ));
    }

    $arrChartConfig["data"] = $arrLabelValueData;

    // JSON Encode the data to retrieve the string containing the JSON representation of the data in the array.
    $jsonEncodedData = json_encode($arrChartConfig);

    // chart object
    $Chart = new FusionCharts("column2d", "MyFirstChart" , "700", "400", "chart-container", "json", $jsonEncodedData);

    // Render the chart
    $Chart->render();
    ?>

    <center>
        <div id="chart-container">Chart will render here!</div>
    </center>
</body>
</html>
<script>

function hide_stamp(){
    console.log(document.getElementsByClassName('raphael-group-21-creditgroup')[0].style.visibility = 'hidden');
};

//setTimeout(hide_stamp,90);

</script>