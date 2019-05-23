// 
//
// r2d3: https://rstudio.github.io/r2d3
//
//console.log(data[1]);
devData = data;
chartData = HTMLWidgets.dataframeToD3(data.d);
//data.stackKey = 0;
/*Object.prototype.getKeyTextLocation2UNZ = function(index) {
    if (data.stackKey == 1) {
        this.attr("cy", index * 20 + 15)
            .attr("cx", margin.left + 10);
    }
    else {
        this.attr("cy", 15)
            .attr("cx", index * 60 + 10);
    }
    
    return this;
};*/
//console.log(data.indicator);
isIncomeIndicator = function (ind) {
    return (ind == "Earnings from wages or salary (mean)" || ind == "Earnings from wages or salary (median)" || data.incomeOnly == 1)
}
function getKeySpacing() {
    if (data.multiLine == 1) {
        if (!Array.isArray(data.lineNames)) {
            data.lineNames = [data.lineNames];
        }
        if (data.stackKey == 1) {
            return data.lineNames.length * 20 + 10;
        } else {
            return 30;
        }
    } else {
        return 10;
    }

}
if (data.multiLine == 1) {
    if (!Array.isArray(data.lineNames)) {
        data.lineNames = [data.lineNames];
    }
    if (!Array.isArray(data.indicator)) {
        data.indicator = [data.indicator];
    }
}
// set the dimensions and margins of the graph
var margin = { right: 25, bottom: 30, left: 85, top: getKeySpacing() },
    width = svg.attr("width") - margin.left - margin.right,
    height = svg.attr("height") - margin.top - margin.bottom - margin.bottom;

svg.selectAll("g").remove();

chart = svg
    //.attr("width", width + margin.left + margin.right)
    //.attr("height", height + margin.top + margin.bottom + 20)
    .append("g")
    .attr("transform",
        "translate(" + margin.left + "," + (margin.top) + ")");
keySpace = svg.append("g");
// parse the date / time
//var parseTime = d3.timeParse("%d-%b-%y");

// set the ranges
var x = d3.scaleLinear().range([0, width - 40]);
var y = d3.scaleLinear().range([height, 0]);

// define the lines


if (isIncomeIndicator(data.indicator)) {
    //console.log("Needs income y axis and grid!");
    var yFormat = d3.format("($,");
} else {
    var yFormat = d3.format(".0%");
}
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
/* chartData.forEach(function(d) {
     d.month = +d.month;
     d.prop = +d.prop;
 });*/

// Scale the range of the data
x.domain([0, 72] /*d3.extent(data, function(d) { return d.month; })*/);
if (isIncomeIndicator(data.indicator)) {
    y.domain([0, 12000]);
} else {
    y.domain([0, 1]); // this needs to change for income!
}

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

chart.append("g")
    .attr("class", "grid")
    .attr("transform", "translate( " + (width - margin.right - 10) + ", 0 )")
    //.attr("transform", "translate("+(0 - margin.left)+",0)")
    .call(d3.axisRight(y).ticks(10)
        //.tickSize(-width)
        .tickFormat(yFormat)
    )
/*var yAxis = d3.svg.axisLeft()
  .scale(y)
  .orient("left")
  .tickFormat(formatPercent);*/

//console.log(valueline);
// Add the valueline path.

class KeyPlacer {
    constructor(index, stackKey) {
        this.index = index;
        if (stackKey == 1) {
            this.stackKey = true;
        } else {
            this.stackKey = false;
        }
        this.lineLength = 30;
    }

    // Getter
    get circleY() {
        if (this.stackKey) {
            return this.index * 20 + 10;
        } else {
            return 10;
        }

    }
    get circleX() {
        if (this.stackKey) {
            return margin.left;
        } else {
            return this.index * 60 + margin.left;
        }
    }
    get lineY() {
        if (this.stackKey) {
            return this.index * 20 + 10;
        } else {
            return 10;
        }

    }

    get lineX1() {
        if (this.stackKey) {
            return margin.left;
        } else {
            return this.index * 80 + margin.left;
        }
    }

    get lineX2() {
        if (this.stackKey) {
            return margin.left + this.lineLength;
        } else {
            return this.index * 80 + margin.left + this.lineLength;
        }
    }

    get textY() {
        if (this.stackKey) {
            return this.index * 20 + 15;
        } else {
            return 15;
        }
    }
    get textX() {
        if (this.stackKey) {
            return margin.left + this.lineLength + 10;
        } else {
            return this.index * 80 + margin.left + this.lineLength + 10;
        }
    }
    // Method
}
var hoveredElement = [];
function mouseoverHandler(d, i) {
    console.log("mouse is over2: " + i);
    console.log(d);
}

if (data.multiLine == 1) {
    if (!Array.isArray(data.lineNames)) {
        data.lineNames = [data.lineNames];
    }
    data.lineNames.forEach((lineName, index) => {
        var valueline = d3.line()
            .x(function (d) { return x(d.month); })
            .y(function (d) {
                if (isIncomeIndicator(data.indicator)) {
                    return y(d[lineName]);
                } else {
                    return y(d[lineName]);
                }

            }).defined(function (d) {
                return d[lineName] !== null;
            });
        chart.append("path")
            .data([chartData])
            .attr("class", "line")
            .attr("data-colour-index", index + 1)
            .attr("d", valueline);
        var whereToPutKeys = new KeyPlacer(index, data.stackKey);
        //console.log(index);
        //console.log(lineName);
        lineKey = keySpace.append("g");
        /*
        lineKey.append("circle")
            .attr("class", "line-key")
            .attr("data-colour-index", index + 1)
            .attr("cy", whereToPutKeys.circleY)
            .attr("cx", whereToPutKeys.circleX)
            .attr("r", "0.4em");*/
            
        lineKey.append("line")
            .attr("class", "line-key")
            .attr("data-colour-index", index + 1)
            .attr("y1", whereToPutKeys.lineY)
            .attr("x1", whereToPutKeys.lineX1)
            .attr("y2", whereToPutKeys.lineY)
            .attr("x2", whereToPutKeys.lineX2);
            

        if (data.stackKey == 1) {
            var keyLabel = data.indicator[index];
        } else {
            var keyLabel = lineName;
        }

        lineKey.append("text")
            .attr("class", "line-key-text")
            .attr("y", whereToPutKeys.textY)
            .attr("x", whereToPutKeys.textX)
            //.attr("y", index * 20 + 15)
            //.attr("x", margin.left + 10)
            .text(keyLabel);

       
    });
} else {
    //console.log("adding line for signel indicator");
    var valueline = d3.line()
        .x(function (d) { return x(d.month); })
        .y(function (d) {
            if (isIncomeIndicator(data.indicator)) {
                return y(d.weighted_value);
            } else {
                //console.log(d.prop);
                return y(d.prop);
            }

        });
    chart.append("path")
        .data([chartData])
        .attr("class", "line")
        .attr("data-colour-index", 2) // needs to be set for the styles
        .attr("d", valueline);


}

//.attr("transform", "translate("+margin.left+",0)")
//.attr("style", "stroke: steelblue;stroke-width: 2px;");

// Add the X Axis
chart.append("g")
    .attr("transform", "translate(0," + (height) + ")")
    .call(d3.axisBottom(x).tickValues([0, 12, 24, 36, 48, 60, 72]).tickFormat(function (d) { return d / 12; }));

// text label for the x axis
chart.append("text")
    .attr("transform",
        "translate(" + (width / 2) + " ," +
        (height + margin.bottom + 10) + ")")
    .attr("class", "xaxis")
    .text("Years after graduation");
// Add the Y Axis
chart.append("g")
    //.attr("transform", "translate("+margin.left+",0)")
    .call(d3.axisLeft(y).tickFormat(yFormat));
// text label for the y axis
chart.append("text")
    .attr("transform", "rotate(-90)")
    .attr("y", 0 - margin.left)
    .attr("x", 0 - (height / 2))
    .attr("dy", "1em")
    .attr("class", "yaxis")
    //.style("text-anchor", "middle")
    .text(data.yLabel);
index = 0;
/*data.lineNames.forEach((lineName, index) => {

})*/


//});
