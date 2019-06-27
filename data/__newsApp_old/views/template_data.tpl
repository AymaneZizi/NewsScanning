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
</style>

<body>

</body>

<script type="text/javascript">

	document.body.innerHTML = "hello";

	var response_json = {{!response_json}};


	console.log(response_json);
	

	document.body.innerHTML = response_json[0].entities[0].type;
	
	var type_array = {},
		concept_array = {},
		keyword_array = {};
	
	for (var i=0, count = response_json.length; i < count; i++){
		//entities
		for (var j=0, sub_count = response_json[i].entities.length; j < sub_count; j++){
		
			if (response_json[i].entities[j].type === 'Person' || response_json[i].entities[j].type === 'Company'){
				if (!(response_json[i].entities[j].entities_text in type_array))
					type_array[response_json[i].entities[j].entities_text] = 1;
				else
					type_array[response_json[i].entities[j].entities_text] += 1;

			}
		}
		//concepts
		for (var j=0, sub_count = response_json[i].concepts.length; j < sub_count; j++){
				if (!(response_json[i].concepts[j].concepts_text in type_array))
					concept_array[response_json[i].concepts[j].concepts_text] = 1;
				else 
					concept_array[response_json[i].concepts[j].concepts_text] += 1;

			}
			
		//keywords
		for (var j=0, sub_count = response_json[i].keywords.length; j < sub_count; j++){
				if (!(response_json[i].keywords[j].keywords_text in type_array))
					keyword_array[response_json[i].keywords[j].keywords_text] = 1;
				else
					keyword_array[response_json[i].keywords[j].keywords_text] += 1;
				
			}
		}
	
	console.log(type_array);
	console.log(concept_array);
	console.log(keyword_array);

</script>
</html>