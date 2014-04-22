###
 * PROJECT NAME
 *
 * /core/tools.js - common tools and utils
 *
 * by krkn
 * started at XX/XX/XXXX
###

"use strict"

root = "#{ __dirname }/.."

clc = require "cli-color"

# log()
# Formatted console log, with date, color & context.

exports.log = log = ( sMessage, sContext = "node", sMessageType = "LOG" ) ->
    aMonthName = [ "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" ]
    dDate = new Date()
    sHours = if ( iHours = dDate.getHours() ) < 10 then "0#{ iHours }" else iHours
    sMinutes = if ( iMinutes = dDate.getMinutes() ) < 10 then "0#{ iMinutes }" else iMinutes
    sSeconds = if ( iSeconds = dDate.getSeconds() ) < 10 then "0#{ iSeconds }" else iSeconds
    sDatePrefix = "#{ dDate.getDate() } #{ aMonthName[ dDate.getMonth() ] } #{ sHours }:#{ sMinutes }:#{ sSeconds }"
    sMessage = "[#{ sContext }] #{ sMessage }"
    switch sMessageType.toUpperCase()
        when "ERROR", "ERR", "RED"
            console.log "#{ sDatePrefix } - #{ clc.red.bold( sMessage ) }"
        when "WARNING", "WARN", "YELLOW"
            console.log "#{ sDatePrefix } - #{ clc.yellow( sMessage ) }"
        when "SUCCESS", "GREEN"
            console.log "#{ sDatePrefix } - #{ clc.green( sMessage ) }"
        when "MAGENTA"
            console.log "#{ sDatePrefix } - #{ clc.magenta( sMessage ) }"
        else
            console.log "#{ sDatePrefix } - #{ clc.cyan( sMessage ) }"

# bench()
# Simple bench tools for console.

oBenches = {}
exports.bench = bench = ( sName ) ->
    return oBenches[ sName ] = process.hrtime() unless oBenches[ sName ]
    iDiff = Math.round( ( ( aEnd = process.hrtime( oBenches[ sName ] ) )[ 0 ] * 1e9 + aEnd[ 1 ] ) / 1000 ) / 1000
    sDiff = if iDiff > 1000 then "#{ Math.round( iDiff / 100 ) / 10 }s" else ( if iDiff > 25 then "#{ Math.round( iDiff ) }ms" else "#{ iDiff }ms" )
    log "took #{ sDiff }.", ( sName or "TIMER" ), "YELLOW"
    delete oBenches[ sName ]
    return if iDiff > 25 then Math.round( iDiff ) else iDiff

# md5(), sha1(), sha256(), sha512(), whirlpool()
# Misc hashing functions.

_getCryptoHash = ( sStr, sAlgorythm ) ->
    oShaHash = crypto.createHash sAlgorythm
    oShaHash.update sStr, "utf8"
    oShaHash.digest "hex"

exports.hash = {}

exports.hash.md5 = md5 = ( sStr ) ->
    _getCryptoHash sStr, "md5"

exports.hash.sha1 = sha1 = ( sStr ) ->
    _getCryptoHash sStr, "sha1"

exports.hash.sha256 = sha256 = ( sStr ) ->
    _getCryptoHash sStr, "sha256"

exports.hash.sha512 = sha512 = ( sStr ) ->
    _getCryptoHash sStr, "sha512"

exports.hash.whirlpool = whirlpool = ( sStr ) ->
    _getCryptoHash sStr, "whirlpool"
