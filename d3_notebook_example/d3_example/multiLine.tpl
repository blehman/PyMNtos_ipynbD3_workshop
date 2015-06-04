<style>

.overlay {
  fill: none;
  pointer-events: all;
}
body {
  font: 10px sans-serif;
}

.axis path,
.axis line {
  fill: none;
  stroke: #000;
  shape-rendering: crispEdges;
}

.x.axis path {
  /*display: none;*/
}

.line {
  fill: none;
  stroke: steelblue;
  stroke-width: 1.5px;
}
</style>
<div id="graph_{{id}}"></div>

<script type="text/javascript">

graph_{{id}} = function(){


    var margin = {top: 20, right: 80, bottom: 30, left: 50},
        width = 960 - margin.left - margin.right,
        height = 500 - margin.top - margin.bottom;

    var parseDate1 = d3.time.format("%Y-%m-%d").parse;
    var parseDate2 = d3.time.format("%Y-%m-%d %H:%M:%S").parse;
    var x = d3.time.scale()
        .range([0, width]);

    var y = d3.scale.linear()
        .range([height, 0]);

    var color = d3.scale.ordinal()
        .domain(['paleo','kale','dairy'])
        .range(['blue','green','red']);

    var xAxis = d3.svg.axis()
        .scale(x)
        .orient("bottom")
        .tickFormat(d3.time.format("%b %Y"));

    var yAxis = d3.svg.axis()
        .scale(y)
        .orient("left");

    var line = d3.svg.line()
        .interpolate("basis")
        .x(function(d) { return x(parseDate2(d.date)); })
        .y(function(d) { return y(d.mentions); });

    var svg_{{id}} = d3.select("#graph_{{id}}").append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
      .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    d3.csv("../data/dfMelt.csv", function(error, dataMelt) {
      d3.csv("../data/df.csv", function(error, data) {
        data.forEach(function(d) {
          d.date = parseDate2(d.timeStamp);
          d.kale = +d.kale;
          d.paleo = +d.paleo;
          d.dairy = +d.dairy;
        });

        dataMelt.forEach(function(d) {
          d.date = parseDate1(d.timeStamp);
          d.value = +d.value;
        });

      console.log(['dataMelt: ',dataMelt]);
      console.log(['data: ',data]);

      x.domain(d3.extent(dataMelt, function(d) { return d.date; }));
      y.domain(d3.extent(dataMelt, function(d) { return d.value; }));


      var diets = color.domain().map(function(name) {
        return {
          name: name,
          values: data.map(function(d) {
            return {date: d.timeStamp, mentions: +d[name]};
          })
        };
      });

      console.log(diets);

      svg_{{id}}.append("g")
          .classed("x axis",true)
          .attr("transform", "translate(0," + height + ")")
          .call(xAxis)
          .selectAll("text")
          .attr("dx",-23)
          .attr("dy",5)
          .attr("transform", "rotate(-20)");

      svg_{{id}}.append("g")
          .attr("class", "y axis")
          .call(yAxis)
        .append("text")
          .attr("transform", "rotate(-90)")
          .attr("y", 6)
          .attr("dy", ".71em")
          .style("text-anchor", "end")
          .text("Mentions Count");

      var diet = svg_{{id}}.selectAll(".diet")
          .data(diets)
        .enter().append("g")
          .attr("class", "diet");

      diet.append("path")
          .attr("class", "line")
          .attr("d", function(d) { 
            console.log(d.values);
            return line(d.values); })
          .style("stroke", function(d) { return color(d.name); });

      diet.append("text")
          .datum(function(d) { return {name: d.name, value: d.values[d.values.length - 1]}; })
          .attr("transform", function(d) { 
            return "translate(" + x(parseDate2(d.value.date)) + "," + y(d.value.mentions) + ")"; })
          .attr("x", 3)
          .attr("dy", ".35em")
          .text(function(d) { return d.name; });
      });
    });
}
/*
###################################################################
var margin = {top: 50, right: 20, bottom: 50, left:20},
    width = 700 - margin.left - margin.right,
    height = 500 - margin.top - margin.bottom;

var svg_{{id}} = d3.select("#graph_{{id}}").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
    .append("g")
    .call(d3.behavior.zoom().scaleExtent([0.75, 8]).on("zoom", zoom_{{id}}))
    .append("g");

svg_{{id}}.append("rect")
    .attr("class", "overlay")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom);

    draw = function(nodes, svg){

     var x_scale = d3.scale.linear()
                    .domain([d3.min(nodes, function(d){ return d['x'];}), 
                             d3.max(nodes, function(d){ return d['x'];})])
                    .range([0, width]);

    var y_scale = d3.scale.linear()
                    .domain([d3.min(nodes, function(d){ return d['y'];}), 
                             d3.max(nodes, function(d){ return d['y'];})])
                    .range([height, 0]);

    svg.selectAll("circle")
       .data(nodes)
       .enter()
       .append("circle")
       .attr("cx", function(d) { return x_scale(d['x']); })
       .attr("cy", function(d) { return y_scale(d['y']); })
       .attr("r",  function(d) { return d['r']; })
       .attr("fill", "red")
       .attr("stroke-width",  0.25)
       .attr("stroke",  "#d3d3d3");

    svg.selectAll("text")
       .data(nodes)
       .enter()
       .append("text")
       .attr("x", function(d) { return x_scale(d['x']); })
       .attr("y", function(d) { return y_scale(d['y']); })
       .attr("dy", ".55em")
       .text(function(d){ return d['name']; });

    }

    var nodes_{{id}} = {{nodes}};

    draw(nodes_{{id}}, svg_{{id}});

    function zoom_{{id}}() {
      svg_{{id}}.attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")");
    }

}
###################################################################
*/

function load_lib(url, callback){
  var s = document.createElement('script');
  s.src = url;
  s.async = true;
  s.onreadystatechange = s.onload = callback;
  s.onerror = function(){console.warn("failed to load library " + url);};
  document.getElementsByTagName("head")[0].appendChild(s);
}

if ( typeof(d3) !== "undefined" ){
    console.log('d3 is defined');
    graph_{{id}}();
}else if(typeof define === "function" && define.amd){
  console.log('trying d3 with require');
  require.config({paths: {d3: "{{ d3_url[:-3] }}"}});
      console.log('trying {{ d3_url[:-3] }}');
        
      require(["d3"], function(d3){
        window.d3 = d3;
        console.log('loaded d3 with require');
        graph_{{id}}();
  });
}else{
    consle.log('trying to load from load_lib');
    load_lib("http://d3js.org/d3.v3.min.js", graph_{{id}}());
}

</script>
