// 
//
// r2d3: https://rstudio.github.io/r2d3
//
//console.log(data[1]);
devData = data;
// set the dimensions and margins of the graph
var margin = {top: 20, right: 20, bottom: 30, left: 50},
    width = svg.attr("width") - margin.left - margin.right,
    height = svg.attr("height") - margin.top - margin.bottom - margin.bottom;

svg.selectAll("g").remove();
console.log("money chart");
chart = svg
    //.attr("width", width + margin.left + margin.right)
    //.attr("height", height + margin.top + margin.bottom + 20)
    .append("g")
    .attr("transform",
          "translate(" + margin.left + "," + margin.top + ")");
// parse the date / time
//var parseTime = d3.timeParse("%d-%b-%y");

// set the ranges
var x = d3.scaleLinear().range([0, width - 40]);
var y = d3.scaleLinear().range([height, 0]);

// define the line
var valueline = d3.line()
    .x(function(d) { return x(d.month); })
    .y(function(d) { return y(d.weighted_value); });
    var formatPercent = d3.format("$.");
// append the svg obgect to the body of the page
// appends a 'group' element to 'svg'
// moves the 'group' element to the top left margin
/*var svg = d3.select("body").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom + 20)
  .append("g")
    .attr("transform",
          "translate(" + margin.left + "," + margin.top + ")");*/

// gridlines in x axis function
function make_x_gridlines() {		
    return d3.axisBottom(x)
        .ticks(6);
}

// gridlines in y axis function
function make_y_gridlines() {		
    return d3.axisLeft(y)
        .ticks(5);
}

 


// Get the data
//d3.csv("data.csv", function(error, data) {
  //if (error) throw error;

  // format the data
  /*data.forEach(function(d) {
      d.month = +d.month;
      d.weighted_value = + Math.round(d.weighted_value);
  });*/

  // Scale the range of the data
  x.domain([0, 72] /*d3.extent(data, function(d) { return d.month; })*/);
  y.domain([0, 12000]);

  // add the X gridlines
  chart.append("g")			
      .attr("class", "grid")
      .attr("transform", "translate(0," + (height) + ")")
      .call(d3.axisBottom(x) //.ticks(6)
        .tickValues([0, 12, 24, 36, 48, 60, 72])
          .tickSize(-height)
          .tickFormat("")
      )

  // add the Y gridlines
  chart.append("g")			
      .attr("class", "grid")
      //.attr("transform", "translate("+margin.left+",0)")
      .call(d3.axisLeft(y).ticks(10)
      //.tickValues([0, 12, 24, 36, 48, 60, 72])
          .tickSize(-width)
          .tickFormat("")
      )
  /*var yAxis = d3.svg.axisLeft()
    .scale(y)
    .orient("left")
    .tickFormat(formatPercent);*/

  //console.log(valueline);
  // Add the valueline path.
  chart.append("path")
      .data([data])
      .attr("class", "line")
      .attr("d", valueline)
      //.attr("transform", "translate("+margin.left+",0)")
      //.attr("style", "stroke: steelblue;stroke-width: 2px;");

  // Add the X Axis
  chart.append("g")
      .attr("transform", "translate(0," + (height) + ")")
      .call(d3.axisBottom(x).tickValues([0, 12, 24, 36, 48, 60, 72]).tickFormat(function(d) { return d/12; }));
    
    // text label for the x axis
    chart.append("text")             
      .attr("transform",
            "translate(" + (width/2) + " ," + 
                           (height + margin.top + margin.bottom) + ")")
      .attr("class", "xaxis")
      .text("Years after graduation");
  // Add the Y Axis
  chart.append("g")
  //.attr("transform", "translate("+margin.left+",0)")
      .call(d3.axisLeft(y)); //.tickFormat(formatPercent));
      // text label for the y axis
      chart.append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 0 - margin.left)
      .attr("x",0 - (height / 2))
      .attr("dy", "1em")
      .attr ( "class" , "yaxis" )
      //.style("text-anchor", "middle")
      .text("Money");      

//});
