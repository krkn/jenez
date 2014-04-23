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
        stylus:
            options:
                compress: no
            static:
                files:
                    "static/css/styles.css": "static/stylus/styles.styl"
        csslint:
            options:
                "box-model": no
                "non-link-hover": no
                "adjoining-classes": no
                "box-sizing": no
                "compatible-vendor-prefixes": no
                "gradients": no
                "text-indent": no
                "fallback-colors": no
                "font-faces": no
                "universal-selector": no
                "unqualified-attributes": no
                "overqualified-elements": no
                "floats": no
                "font-sizes": no
                "ids": no
                "important": no
                "outline-none": no
                "qualified-headings": no
                "unique-headings": no
                "duplicate-background-images": no
            static:
                src: [ "static/css/styles.css" ]
        csso:
            static:
                files:
                    "static/css/styles.min.css": "static/css/styles.css"
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
            static:
                files: [
                    "static/stylus/**/*.styl"
                ]
                options:
                    nospawn: yes
                tasks: [
                    "clear"
                    "stylus:static"
                    "csslint:static"
                    "csso:static"
                    "bumpup:prerelease"
                ]
        concurrent:
            work:
                tasks: [
                    "supervisor:server"
                    "watch"
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
        # static
        "stylus:static"
        "csslint:static"
        "csso:static"
        # bump
        "bumpup:prerelease"
    ]

    grunt.registerTask "work", [
        "default"
        "concurrent"
    ]

    grunt.registerTask "lint", [
        "clear"
        "coffeelint:server"
        # client
        "stylus:static"
        "csslint:static"
        "csso:static"
    ]

    grunt.registerTask "patch", [
        "clear"
        # server
        "clean:server"
        "coffeelint:server"
        "coffee:server"
        "copy:server"
        # client (TODO)
        # static
        "stylus:static"
        "csslint:static"
        "csso:static"
        # bump
        "bumpup:patch"
        "bumpup:prerelease"
        "bumpup:prerelease"
    ]

    grunt.registerTask "minor", [
        "clear"
        # server
        "clean:server"
        "coffeelint:server"
        "coffee:server"
        "copy:server"
        # client (TODO)
        # static
        "stylus:static"
        "csslint:static"
        "csso:static"
        # bump
        "bumpup:minor"
        "bumpup:prerelease"
        "bumpup:prerelease"
    ]
