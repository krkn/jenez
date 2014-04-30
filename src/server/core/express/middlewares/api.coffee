###
 * PROJECT_NAME
 *
 * /core/express/middlewares/api.js - api middleware
 *
 * by krkn
 * started at XX/XX/XXXX
###

"use strict"

# send()
# Send a json with data to the client, for successful requests.

exports.send = ( oRequest, oResponse, oData ) ->
    oResponse.json
        url: "[#{ oRequest.method }] #{ oRequest.originalUrl }"
        data: oData
        error: no

# error()
# Send a json with error message to the client, for errored requests.

exports.error = ( oRequest, oResponse, sMessage, oData ) ->
    oResponse.json
        url: "[#{ oRequest.method }] #{ oRequest.originalUrl }"
        data: null
        error:
            type: sMessage
            data: oData
