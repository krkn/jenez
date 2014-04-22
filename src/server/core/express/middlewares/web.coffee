###
 * PROJECT NAME
 *
 * /core/express/middlewares/web.js - web middleware
 *
 * by krkn
 * started at XX/XX/XXXX
###

"use strict"

root = "#{ __dirname }/../../.."

tools = require "#{ root }/core/tools.js"

exports.log = ( oRequest, oResponse, fNext ) ->
    tools.log "(#{ oRequest.method }) #{ oRequest.url }", "express"
    fNext()
