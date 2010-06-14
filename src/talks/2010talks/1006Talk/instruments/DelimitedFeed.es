/* -------------------------------------------------------
 *   DelimitedFeed.es
 *  Author:    G. Wade Johnson
 *  Created:   08/29/2003
 *  Copyright 2003 G. Wade Johnson
 *  Available for any use if this notice is maintained.
 *
 *  Designed for use with the Instrument classes developed by
 *  G. Wade Johnson
 */

//constructor
function  DelimitedFeed( gauges, delim, recdelim )
 {
  this.gauges   = gauges;
  this.delim    = (null == delim)    ? "\t" : delim;
  this.recdelim = (null == recdelim) ? /\r?\n/ : recdelim;
 }

DelimitedFeed.prototype.update = function( input )
 {
  var records = input.split( this.recdelim );
  for(var i = 0;i < records.length;++i)
   {
    var fields = records[i].split( this.delim );
    gauges.feedInstruments( fields[0], fields[1], fields[2] );
   }
 };
