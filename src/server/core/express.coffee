###
 * PROJECT NAME
 *
 * /core/express.js - express setup
 *
 * by krkn
 * started at XX/XX/XXXX
###

"use strict"

root = "#{ __dirname }/.."

pkg = require "#{ root }/../../package.json"

express = require "express"
bodyParser = require "body-parser"
cookieParser = require "cookie-parser"
session = require "express-session"
RedisStore = require( "connect-redis" )( session )

middlewares = require "#{ root }/core/express/middlewares/web.js"

# Setting up express application for serving pages
module.exports = app = express()

# Configure default middlewares
app.use bodyParser.json()
app.use bodyParser.urlencoded()
app.use cookieParser()

# Configure the session middleware to use a RedisStore (allowing the sessions to be accessible from different instance of the app in the same cluster).
redisConfig = pkg.config.redis
sessionStore = new RedisStore
    host: redisConfig.host
    port: redisConfig.port
    db: redisConfig.db
app.use session
    store: sessionStore
    secret: "MY SUPER SECRET SECRET KEY"

# Configure logging middleware
app.use middlewares.log

# Configure static middleware (from package.json, usualy handled by nginx)
app.use express.static "#{ root }/../../static" if pkg.config.express.static

# Configure the template engine
app.set "views", "#{ root }/views"
app.set "view engine", "jade"
app.locals.pretty = !pkg.config.express.cache
app.set "view cache", pkg.config.express.cache

# Load controllers for web GUI
require( "#{ root }/controllers/pages.js" ).init app

# Start listening
app.listen pkg.config.express.port
