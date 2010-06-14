/* -------------------------------------------------------
 *   asv_patch.es
 *  Author:    G. Wade Johnson
 *  Created:   11/15/2003
 *  Copyright 2003 G. Wade Johnson
 *  Available for any use if this notice is maintained.
 *
 *  Correction for a few EcmaScript incompatibilities I've
 *  encountered with ASV3.
 */

/** Add missing Number.toFixed().
 */
try { (100).toFixed( 1 ); }
catch(ex)
 {
  Number.prototype.toFixed = function(dec) {
    var scale = Math.pow(10,dec)
    var val   = ""+(Math.floor((this*scale)+0.5)/scale);
    var dp    = val.indexOf(".");
    var zeros = dec;
    if(dp == -1)
     {
      val+=".";
     }
    else
     {
      zeros -= (val.length - (dp + 1));
     }
    for(var i=0;i < zeros;++i) val += "0";

    return val;
   };
 }


/** Add missing Array.push().
 */
try
 {
  var arr = new Array();
  arr.push( 1 );
 }
catch(ex)
 {
  function _array_push( item )
   {
    var args = _array_push.arguments;
    
    for(var i=0;i < args.length;++i)
      this[this.length++] = args[i];

    return this.length;
   }
  Array.prototype.push = _array_push;
 }

/** Add missing Array.shift().
 */
try
 {
  var arr = new Array( 1, 2 );
  arr.shift();
 }
catch(ex)
 {
  Array.prototype.shift = function() {
    var ret = this[0];

    for(var i=0;i < this.length-1;++i)
     {
      this[i] = this[i+1];
     }

    this.length--;

    return ret;
   };
 }

