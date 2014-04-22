"use strict"

module.exports = ( grunt ) ->

    require( "matchdep" ).filterDev( "grunt-*" ).forEach grunt.loadNpmTasks

    grunt.initConfig
        bumpup: "package.json"
        clean:
            server: [ "bin/server/" ]
        coffeelint:
            options:
                arrow_spacing:
                    level: "error"
                camel_case_classes:
                    level: "error"
                duplicate_key:
                    level: "error"
                indentation:
                    level: "ignore"
                max_line_length:
                    level: "ignore"
                no_backticks:
                    level: "error"
                no_empty_param_list:
                    level: "error"
                no_stand_alone_at:
                    level: "error"
                no_tabs:
                    level: "error"
                no_throwing_strings:
                    level: "error"
                no_trailing_semicolons:
                    level: "error"
                no_unnecessary_fat_arrows:
                    level: "error"
                space_operators:
                    level: "error"
            server:
                files:
                    src: [ "src/server/**/*.coffee" ]
        coffee:
            server:
                expand: yes
                cwd: "src/server/"
                src: [ "**/*.coffee" ]
                dest: "bin/server/"
                ext: ".js"
                options:
                    bare: yes
        copy:
            server: # views
                files: [
                    expand: yes
                    cwd: "src/server/views/"
                    src: [ "**/*.jade" ]
                    dest: "bin/server/views/"
                ]
        supervisor:
            server:
                script: "bin/server/index.js"
                options:
                    watch: [ "bin" ]
                    extensions: [ "js", "jade" ]
        watch:
            server:
                files: [
                    "src/server/**/*.coffee"
                    "src/server/views/**/*.jade"
                ]
                options:
                    nospawn: yes
                tasks: [
                    "clear"
                    "newer:coffeelint:server"
                    "newer:coffee:server"
                    "newer:copy:server"
                    "bumpup:prerelease"
                ]
        concurrent:
            work:
                tasks: [
                    "supervisor:server"
                    "watch:server"
                ]
                options:
                    logConcurrentOutput: yes
        todo:
            server:
                src: [
                    "src/server/**/*.coffee"
                    "src/server/**/*.jade"
                ]

    grunt.registerTask "default", [
        "clear"
        # server
        "clean:server"
        "coffeelint:server"
        "coffee:server"
        "copy:server"
        # client (TODO)
        # static (TODO)
        "bumpup:prerelease"
    ]
