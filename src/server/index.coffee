###
 * PROJECT_NAME
 *
 * /index.js - Main entry point
 *
 * by krkn
 * started at XX/XX/XXXX
###

"use strict"

root = __dirname
zouti = require "zouti"
pkg = require "#{ root }/../package.json"

app = require "#{ root }/core/express.js"

zouti.log "server launched.", pkg.name, "YELLOW"
