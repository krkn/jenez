"use strict"

module.exports = ( grunt ) ->

    require( "matchdep" ).filterDev( "grunt-*" ).forEach grunt.loadNpmTasks

