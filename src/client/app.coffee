###
 * PROJECT_NAME
 *
 * ~/app.js - Client entry point
 *
 * by krkn
 * started at XX/XX/XXXX
###

"use strict"

$ = require "jquery"
glogger = ( require "glogger" )
	level: "info"

hello = require "./modules/hello.js"

$ ->
    glogger.info "app. started"

    hello.world()
