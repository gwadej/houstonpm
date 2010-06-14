/* -------------------------------------------------------
 *   StripChart.es
 *  Author:    G. Wade Johnson
 *  Created:   09/11/2003
 *  Copyright 2003 G. Wade Johnson
 *  Available for any use if this notice is maintained.
 *  Dependency:  Instruments.es
 */

var svgNS = "http://www.w3.org/2000/svg";
var gwjNS = "http://www.anomaly.org/2003/instruments";

// ------------------------------------------------
//  BarGauge
// Create a StripChart object associated with the SVG element 'id'.
function  StripChart(id,meta)
 {
  this.id    = id;
  this.init( meta );
 }
derive( StripChart, BaseInstrument );

Instruments.register( "stripchart", StripChart );

StripChart.prototype.toString = function() {
  return "StripChart("+this.id+")";
 };


// initialize some element references
StripChart.prototype.init   = function(meta) {
  this.elem = document.getElementById( this.id );
  this.fill = document.getElementById( this.id+".fill" );
  this.line = document.getElementById( this.id+".line" );

  try
   {
    if(null == meta)
      meta = getMetadata( this.elem );

    this.max    = Instruments.getParam( meta, "high" )-0;
    this.min    = Instruments.getParam( meta, "low" )-0;
    this.range  = this.max-this.min;
    this.height = Instruments.getParam( meta, "height" )-0;
    var width   = Instruments.getParam( meta, "width" )-0;
    this.step   = Instruments.getParam( meta, "step" )-0;
    this.maxnum = Math.floor(width/this.step)+1;
    if(this.max > 0 && this.min < 0)
     {
      var axis = this.relativeValue(0)*this.height;
      this.closefill = "V"+axis+"H0z";
     }
    else
      this.closefill = "V0H0z";
   }
  catch(ex)
   {
    throw this.toString() + ": " + ex;
   }
   
   this.pnts   = new Array();
 };


// add a value to the stripchart and update the display
StripChart.prototype.setValue = function(val) {
  val = this.relativeValue(val)*this.height;
  this.pnts.push( Math.floor(val+0.5) );
  if(this.pnts.length > this.maxnum)
    this.pnts.shift();

  this.draw();
 };

StripChart.prototype.clearValue = function() {
  this.pnts   = new Array();
 };

StripChart.prototype.draw = function() {
  var path = '';
  if(this.pnts.length > 0)
  {
    var i=0;
    var x=0;
    path = "M0,"+this.pnts[0];
    x = this.step;
    for(i=1;i < this.pnts.length;++i)
    {
      path += "L" + x +","+this.pnts[i];
      x += this.step;
    }
  }
  if(null != this.line)
    this.line.setAttributeNS( null, "d", path );

  if(null != this.fill)
    this.fill.setAttributeNS( null, "d", path+this.closefill );
 };
