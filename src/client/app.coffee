###
 * PROJECT NAME
 *
 * ~/app.js - Client entry point
 *
 * by krkn
 * started at XX/XX/XXXX
###

"use strict"

$ = require "jquery"

hello = require "./modules/hello.js"

$ ->
    console.log "app. started"

    hello.world()
