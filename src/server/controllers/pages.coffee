###
 * PROJECT NAME
 *
 * /controllers/pages.js - Controller for common pages
 *
 * by krkn
 * started at XX/XX/XXXX
###

"use strict"

root = "#{ __dirname }/.."

# [GET] /

homepage = ( oRequest, oResponse ) ->
    oResponse.render "index"

# Declare routes.

exports.init = ( oApp ) ->
    oApp.get "/", homepage
