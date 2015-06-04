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

var svg = d3.select("body").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
  .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

d3.csv("d3_notebook_example/data/dfMelt.csv", function(error, dataMelt) {
  d3.csv("d3_notebook_example/data/df.csv", function(error, data) {
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
  svg.append("g")
      .classed("x axis",true)
      .attr("transform", "translate(0," + height + ")")
      .call(xAxis)
      .selectAll("text")
      .attr("dx",-23)
      .attr("dy",5)
      .attr("transform", "rotate(-20)");

  svg.append("g")
      .attr("class", "y axis")
      .call(yAxis)
    .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", ".71em")
      .style("text-anchor", "end")
      .text("Mentions Count");

  var diet = svg.selectAll(".diet")
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
