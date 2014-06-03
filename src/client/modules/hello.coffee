###
 * PROJECT_NAME
 *
 * ~/modules/hello.js - Random client module
 *
 * by krkn
 * started at XX/XX/XXXX
###

"use strict"

glogger = ( require "glogger" )
	level: "info"

module.exports =
    world: ->
        glogger.info "Hello, World !"
