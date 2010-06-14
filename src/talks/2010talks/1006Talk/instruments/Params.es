/* -------------------------------------------------------
 *   Params.es
 *  Author:    G. Wade Johnson
 *  Created:   10/12/2008
 *  Copyright 2008 G. Wade Johnson
 *  Available for any use if this notice is maintained.
 *
 * Parse parameters out of the URL.
 * Each parameter becomes an attribute of the Parms object.
 * If more than one copy of a parameter is supplied in the querystr,
 * the value of that item will be an array.
 */

function Params()
{
    var url = document.URL.toString();
    var querystr = url.split( '?' )[1];
    if(null == querystr) return;

    var parms = querystr.split( '&' );
    while(parms.length > 0)
    {
        var parts = parms.shift().split( '=' );
        var name = parts[0];
        var val = parts[1];
        if( null == this[name] )
        {
            this[name] = val;
        }
        else if( 'string' == typeof this[name] )
        {
            this[name] = [ this[name], val ];
        }
        else
        {
            this[name] = this[name].push( val );
        }
    }
}
