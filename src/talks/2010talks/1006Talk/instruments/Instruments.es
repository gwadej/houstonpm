/* -------------------------------------------------------
 *   Instruments.es
 *  Author:    G. Wade Johnson
 *  Created:   08/16/2003
 *  Copyright 2003 G. Wade Johnson
 *  Available for any use if this notice is maintained.
 */

var svgNS = "http://www.w3.org/2000/svg";
var gwjNS = "http://www.anomaly.org/2003/instruments";

//constructor
function  Instruments()
 {
  this.number   = 0;
  this.elements = new Object();
  this.feeds    = new Object();
 }

Instruments.factory = new Object();

Instruments.MakeInstrument = function( id, elem ) {
  return new Instruments.factory[elem.localName]( id, elem );
 };

Instruments.register = function( name, ctor )
 {
  Instruments.factory[name] = ctor;
 };

Instruments.getParam = function(meta, attr) {
  var str = meta.getAttributeNS( null, attr );
  if("" == str)
    throw "Missing required '"+attr+"' attribute";

  return str;
 };

// add an object 'obj', named 'name' to the group
Instruments.prototype.add = function( name ) {
  var obj = this.make( name );

  if(null == obj)
    return;

  this.addFeed( obj.src, obj );

  if(null == this.elements[name])
   {
    this.number++;
    this.elements[name] = obj;
   }
  else
   {
    throw "Instrument named '"+name+"' already present.";
   }
 };

// add all of the objects named in the array names.
Instruments.prototype.addAll = function( names ) {
   for(var i=0;i < names.length;++i)
    {
     this.add( names[i] );
    }
 };

// remove the object named 'name' from the group
Instruments.prototype.remove = function ( name ) {
  if(null != this.elements[name])
   {
    this.number--;
    delete this.elements[name];
   }
 };

Instruments.prototype.addFeed = function( src, obj ) {
  var feed = this.feeds[src];
  if(null == feed)
    feed = this.feeds[src] = new Array();

  feed[feed.length] = obj;
 };


Instruments.prototype.feedInstruments = function( src, val, state ) {
  var objs = this.feeds[src];
  if(null != objs)
   {
    for(i=0;i < objs.length;++i)
     {
      if(val != null)
        objs[i].setValue( val );
      if(state != null)
        objs[i].setState( state );
     }
   }
 };

// get a list of the names of all objects in the group
Instruments.prototype.getNames = function() {
  var names = new Array();
  for(name in this.elements)
   {
    names[names.length] = name;
   }
  return names;
 };

// retrieve the object named 'name'
Instruments.prototype.get = function( name ) {
  return this.elements[name];
 };

// return the number of objects in the group
Instruments.prototype.getCount = function() {
  return this.number;
 };

// Set the value of the named instrument
Instruments.prototype.setInstrumentValue = function( name, val ) {
  var inst = this.get( name );
  if(null != inst)
    inst.setValue( val );
 };

// Set the value of the named instrument
Instruments.prototype.setInstrumentState = function( name, state ) {
  var inst = this.get( name );
  if(null != inst)
    inst.setState( state );
 };

Instruments.prototype.make = function( id ) {
  var elem = document.getElementById( id );
  if(null == elem)
    throw "Cannot find '" + id + "'.";

  var meta = getMetadata( elem );

  var obj = Instruments.MakeInstrument( id, meta );

  if(obj != null)
   {
    var src = meta.getAttributeNS( null, "src" );
    obj.src = ("" == src) ? id : src;
   }

  return obj;
 };

function getMetadata(elem) {
  var nodelist = elem.getElementsByTagName("metadata");

  if(nodelist.length == 0)
    throw "Metadata missing.";

  try
   {
    return getFirstInstrument( nodelist.item(0) );
   }
  catch(ex)
   {
    throw "Metadata missing.";
   }
 };

function getFirstInstrument(elem) {
  var nodelist = elem.getElementsByTagNameNS(gwjNS, "*");
  if(nodelist.length == 0)
    throw "Missing Instrument-type element.";

  return nodelist.item(0);
 };

function  setText(elem, str)
 {
   var text = document.createTextNode( str );
   elem.replaceChild( text, elem.firstChild );
 }

// ------------------------------------------------
//  Base class
//   Provides default implementations for some functions.
function BaseInstrument() { }

// Set the state of the instrument, useful for changing the
//  style of the display for alarm conditions and such.
BaseInstrument.prototype.setState = function(state) {
   this.elem.setAttributeNS( null, "class", state );
 };

// Set the state of the instrument, useful for changing the
//  style of the display for alarm conditions and such.
BaseInstrument.prototype.relativeValue = function(val) {
  return (val-this.min)/this.range;
 };

// Clear current value, if such a concept exists.
BaseInstrument.prototype.clearValue = function() { };

function derive(sub,base)
 {
  sub.prototype = new base();
  sub.prototype.constructor = sub;
 }

// ------------------------------------------------
//  Gauge
// Create a Gauge object associated with the SVG element 'id'.
function Gauge(id,meta)
 {
  this.id    = id;
  this.init( meta );
 }
derive( Gauge, BaseInstrument );

Instruments.register( "gauge", Gauge );

Gauge.prototype.toString = function () {
  return "Gauge(" + this.id + ")";
 };

// initialize some element references
Gauge.prototype.init   = function(meta) {
  this.elem = document.getElementById( this.id );
  this.bar  = document.getElementById( this.id+".bar" );

  try
   {
    if(null == meta)
      meta = getMetadata( this.elem );

    this.max   = Instruments.getParam( meta, "high" )-0;
    this.min   = Instruments.getParam( meta, "low" )-0;
    this.range = this.max-this.min;
   }
  catch(ex)
   {
    throw this.toString() + ": " + ex;
   }
 };

// set the value of the gauge and update the display
Gauge.prototype.setValue = function(val) {
   var xfrm="scale(1,"+this.relativeValue(val)+")";
   this.bar.setAttributeNS( null, "transform", xfrm );
 };

// ------------------------------------------------
//  Dial
// Create a Dial object associated with the SVG element 'id'.
//  Set the legal min and max values to the supplied values.
//  deg is the number of degrees for the range (pos cw, neg ccw)
function Dial(id,meta)
 {
  this.id    = id;
  this.init( meta );
 }
derive( Dial, BaseInstrument );

Instruments.register( "dial", Dial );

Dial.prototype.toString = function () {
  return "Dial(" + this.id + ")";
 };

Dial.prototype.init = function(meta) {
  this.elem   = document.getElementById( this.id );
  this.needle = document.getElementById( this.id+".needle" );

  try
   {
    if(null == meta)
      meta = getMetadata( this.elem );

    this.max   = Instruments.getParam( meta, "high" )-0;
    this.min   = Instruments.getParam( meta, "low" )-0;
    this.range = this.max-this.min;
    this.angle = Instruments.getParam( meta, "angle" )-0;
   }
  catch(ex)
   {
    throw this.toString() + ": " + ex;
   }
 };

// set the value of the gauge and update the display
//  Currently no support for dealing with out-of-range values
Dial.prototype.setValue = function(val) {
   val = this.angle*this.relativeValue(val);
   var xfrm="rotate("+val+")";
   this.needle.setAttributeNS( null, "transform", xfrm );
 };

// ------------------------------------------------
//  Lamps

// Create a Lamp object associated with the SVG element 'id'.
function Lamp(id, meta)
 {
  this.id    = id;
  this.init( meta );
 }
derive( Lamp, BaseInstrument );

Instruments.register( "lamp", Lamp );

Lamp.prototype.toString = function () {
  return "Lamp(" + this.id + ")";
 };

Lamp.prototype.init = function(meta) {
  this.elem  = document.getElementById( this.id );
  this.lamp  = document.getElementById( this.id+".lamp" );
 };

// set the value of the gauge and update the display
//  Currently no support for dealing with out-of-range values
Lamp.prototype.setValue = function(val) {
   this.lamp.setAttributeNS( null, "class", val );
 };

// ------------------------------------------------
//  Readout

// Create a Readout object associated with the SVG element 'id'.
//  Set the legal min and max values to the supplied values.
//  deg is the number of degrees for the range (pos cw, neg ccw)
function Readout(id, meta)
 {
  this.id    = id;
  this.init( meta );
 }
derive( Readout, BaseInstrument );

Instruments.register( "readout", Readout );

Readout.prototype.toString = function () {
  return "Readout(" + this.id + ")";
 };

Readout.prototype.init = function(meta) {
  this.elem = document.getElementById( this.id );
  this.disp = document.getElementById( this.id+".disp" );
  this.sign = document.getElementById( this.id+".sign" );

  try
   {
    if(null == meta)
      meta = getMetadata( this.elem );

    var signed  = meta.getAttributeNS( null, "signed" ); // is optional
    this.dec    = meta.getAttributeNS( null, "dec" );    // is optional
    this.places = Instruments.getParam( meta, "digits" )-0;

    if(this.sign)
      this.setValue = Readout.prototype.method_setValue_withSign;
    else
      this.setValue = Readout.prototype.method_simpleSetValue;

    if("" == this.dec)
     {
      this.valueToString = Readout.method_noDec;
     }
    else if(0 == this.dec)
     {
      this.valueToString = Readout.method_Int;
     }
    else
     {
      this.valueToString = Readout.method_Ecma_toFixed;
     }
  
    signed = (null == signed || "no" != signed);

    var val    = Math.pow(10,this.places)-1;
    this.min   = signed ? -val : 0;
    this.max   = val;
    this.range = this.max-this.min;
   }
  catch(ex)
   {
    throw this.toString() + ": " + ex;
   }
 };

Readout.method_noDec = function(val)
 {
  return val;
 }

// Round off the integers
Readout.method_Int = function(val)
 {
  return Math.floor(val+0.5);
 }


Readout.method_Ecma_toFixed = function(val)
 {
  return (new Number(val)).toFixed( this.dec );
 }

Readout.prototype.method_simpleSetValue = function(val) {
   setText( this.disp, this.valueToString( val ) );
 };

// set the value of the gauge and update the display
//  Currently no support for dealing with out-of-range values
Readout.prototype.method_setValue_withSign = function(val) {
   if(val < 0)
    {
     setText( this.sign, "-" );
     this.method_simpleSetValue( -val );
    }
   else
    {
     setText( this.sign, " " );
     this.method_simpleSetValue( val );
    }
 };


// ------------------------------------------------
//  Alpha - displays some dynamic alphanumeric text (Actually any text).

// Create an Alpha object associated with the SVG element 'id'.
function Alpha(id, meta)
 {
  this.id    = id;
  this.init( meta );
 }
derive( Alpha, BaseInstrument );

Instruments.register( "alpha", Alpha );

Alpha.prototype.toString = function () {
  return "Alpha(" + this.id + ")";
 };

Alpha.prototype.init = function(meta) {
  this.elem = document.getElementById( this.id );
  this.disp = document.getElementById( this.id+".disp" );

  try
   {
    if(null == meta)
      meta = getMetadata( this.elem );

    this.length = Instruments.getParam( meta, "length" )-0;
   }
  catch(ex)
   {
    throw this.toString() + ": " + ex;
   }
 };

Alpha.prototype.setValue = function(val) {
   setText( this.disp, val );
 };

// -------- Decorators ----------------------------

// ------------------------------------------------
//  Base class
//   Provides default implementations for some functions.
function Decorator() { }
// Set the state of the instrument, useful for changing the
//  style of the display for alarm conditions and such.
Decorator.prototype.setState = function(state) {
   this.deleg.setState( state );
 };
// Clear current value, if such a concept exists.
Decorator.prototype.clearValue = function() {
   this.deleg.clearValue();
  };
// Clear current value, if such a concept exists.
Decorator.prototype.setValue = function(val) {
   this.deleg.setValue(val);
  };
// init function. I need some way to add the class name
Decorator.prototype.init = function(meta) {
  try
   {
    meta = init_decorator( this, meta );
    this.range = this.max-this.min;
   }
  catch(ex)
   {
    throw this.toString() + " : " + ex;
   }
  };

// find the object I delegate to.
function find_delegate( id, elem ) {
    var delg    = getFirstInstrument( elem );
    return Instruments.MakeInstrument( id, delg );
 }

function init_decorator(self,meta) {
  self.elem  = document.getElementById( self.id );
  self.deleg = null;

  if(null == meta)
    meta = getMetadata( self.elem );

  self.deleg = find_delegate( self.id, meta );
  if(null != self.deleg.min)
    self.min = self.deleg.min;
  if(null != self.deleg.max)
    self.max = self.deleg.max;
  
  return meta;
 };

// ------------------------------------------------
//  Threshholder
function Thresholder(id,meta)
 {
  this.id    = id;
  this.init( meta );
 }
derive( Thresholder, Decorator );

Instruments.register( "threshold", Thresholder );

Thresholder.prototype.toString = function () {
  return "Thresholder(" + this.id + ")";
 };

Thresholder.prototype.init = function(meta) {
  try
   {
    meta = init_decorator( this, meta );

    this.max    = Instruments.getParam( meta, "high" )-0;
    this.min    = Instruments.getParam( meta, "low" )-0;
    this.range  = this.max-this.min;
    this.thresh = Instruments.getParam( meta, "thresh" )-0;

    // optional state values
    if("" == (this.hstate = meta.getAttributeNS( null, "over" )))
      this.hstate = "on";
    if("" == (this.lstate = meta.getAttributeNS( null, "under" )))
      this.lstate = "off";
   }
  catch(ex)
   {
    throw this.toString() + ": " + ex;
   }
 };

Thresholder.prototype.setValue = function(val) {
   val -= 0;
   this.deleg.setValue( (val >= this.thresh) ? this.hstate : this.lstate );
 };

// ------------------------------------------------
//  Clamp
function Clamp(id,meta)
 {
  this.id    = id;
  this.init( meta );
 }
derive( Clamp, Decorator );

Instruments.register( "clamp", Clamp );

Clamp.prototype.toString = function () {
  return "Clamp(" + this.id + ")";
 };

Clamp.prototype.setValue = function(val) {
   if(val < this.min)
     val = this.min;
   else if(val > this.max)
     val = this.max;

   this.deleg.setValue( val );
 };


// ------------------------------------------------
//  Ranged
function Ranged(id,meta)
 {
  this.id    = id;
  this.init( meta );
 }
derive( Ranged, Decorator );

Instruments.register( "ranged", Ranged );

Ranged.prototype.toString = function () {
  return "Ranged(" + this.id + ")";
 };

Ranged.prototype.init = function(meta) {
  this.alarmed = false;

  try
   {
    meta = init_decorator( this, meta );
    this.range = this.max-this.min;

    var str = meta.getAttributeNS( null, "hlim" );
    if("" != str)
     {
      this.hlim = str-0;
      this.over = Instruments.getParam( meta, "over" );
     }
    else // don't test if no high limit
     {
      this.highTest = function(val) { return false; }
     }

    str = meta.getAttributeNS( null, "llim" );
    if("" != str)
     {
      this.llim  = str-0;
      this.under = Instruments.getParam( meta, "under" );
     }
    else // don't test if no low limit
     {
      this.lowTest = function(val) { return false; }
     }

    if(null != this.hlim || null != this.llim)
     {
      this.normal = Instruments.getParam( meta, "normal" );
     }
   }
  catch(ex)
   {
    throw this.toString() + ": " + ex;
   }
 };

Ranged.prototype.setValue = function(val) {
   if(!(this.highTest( val ) || this.lowTest( val )) && this.alarmed)
    {
     this.deleg.setState( this.normal );
     this.alarmed = false;
    }

   this.deleg.setValue( val );
 };


Ranged.prototype.lowTest = function(val) {
   if(val-0 < this.llim)
    {
     this.deleg.setState( this.under );
     this.alarmed = true;
     return true;
    }

   return false;
 };

Ranged.prototype.highTest = function(val) {
   if(val-0 > this.hlim)
    {
     this.deleg.setState( this.over );
     this.alarmed = true;
     return true;
    }

   return false;
 };

// ------------------------------------------------
//  Accumulator
function Accumulator(id,meta)
 {
  this.id    = id;
  this.init( meta );
  this.val = 0;
 }
derive( Accumulator, Decorator );

Instruments.register( "accumulator", Accumulator );

Accumulator.prototype.toString = function () {
  return "Accumulator(" + this.id + ")";
 };

Accumulator.prototype.setValue = function(val) {
   this.val += val;

   this.deleg.setValue( this.val );
 };

Accumulator.prototype.clearValue = function() {
   this.val = 0;
 };


// ------------------------------------------------
//  Delta
function Delta(id,meta)
 {
  this.id    = id;
  this.init( meta );
  this.val = 0;
 }
derive( Delta, Decorator );

Instruments.register( "delta", Delta );

Delta.prototype.toString = function () {
  return "Delta(" + this.id + ")";
 };

Delta.prototype.setValue = function(val) {
   this.deleg.setValue( this.val-val );
   this.val = val;
 };

Delta.prototype.clearValue = function() {
   this.val = 0;
 };
