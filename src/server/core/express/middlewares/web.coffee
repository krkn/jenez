###
 * PROJECT_NAME
 *
 * /core/express/middlewares/web.js - web middleware
 *
 * by krkn
 * started at XX/XX/XXXX
###

"use strict"

root = "#{ __dirname }/../../.."

zouti = require "zouti"

exports.log = ( oRequest, oResponse, fNext ) ->
    zouti.log "(#{ oRequest.method }) #{ oRequest.url }", "express"
    fNext()
