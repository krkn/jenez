"use strict"

module.exports = ( grunt ) ->

    require( "matchdep" ).filterDev( "grunt-*" ).forEach grunt.loadNpmTasks

    aBrowserifyLibs = [
        "jquery"
        # complete with included client-side libs, such as backbone, socket.io, ...
    ]

    grunt.initConfig
        bumpup: "package.json"
        clean:
            server: [ "bin/" ]
            client: [ "_client/" ]
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
            client:
                files:
                    src: [ "src/client/**/*.coffee" ]
        coffee:
            server:
                expand: yes
                cwd: "src/server/"
                src: [ "**/*.coffee" ]
                dest: "bin/"
                ext: ".js"
                options:
                    bare: yes
            client:
                expand: yes
                cwd: "src/client/"
                src: [ "**/*.coffee" ]
                dest: "_client/"
                ext: ".js"
                options:
                    bare: yes
        copy:
            server: # views
                files: [
                    expand: yes
                    cwd: "src/server/views/"
                    src: [ "**/*.jade" ]
                    dest: "bin/views/"
                ]
        browserify:
            libs:
                options:
                    require: aBrowserifyLibs
                src: []
                dest: "static/js/libs.js"
            client:
                options:
                    external: aBrowserifyLibs
                files:
                    "static/js/app.js": "_client/app.js"
        uglify:
            options:
                sourceMap: yes # should be removed for production
            libs:
                files:
                    "static/js/libs.min.js": "static/js/libs.js"
            client:
                files:
                    "static/js/app.min.js": "static/js/app.js"
        stylus:
            options:
                compress: no
            styles:
                files:
                    "static/css/styles.css": "static/stylus/styles.styl"
        csslint:
            options:
                "box-model": no
                "non-link-hover": no
                "adjoining-classes": no
                "box-sizing": no
                "text-indent": no
                "fallback-colors": no # until kouto-swiss is completed
                "font-faces": no
                "regex-selectors": no
                "universal-selector": no
                "unqualified-attributes": no
                "overqualified-elements": no
                "duplicate-background-images": no
                "floats": no
                "font-sizes": no
                "outline-none": no
                "qualified-headings": no
                "unique-headings": no
                "compatible-vendor-prefixes": no
            styles:
                src: [ "static/css/styles.css" ]
        csso:
            styles:
                files:
                    "static/css/styles.min.css": "static/css/styles.css"
        supervisor:
            server:
                script: "bin/index.js"
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
            client:
                files: [
                    "src/client/**/*.coffee"
                ]
                options:
                    nospawn: yes
                    livereload: yes
                tasks: [
                    "clear"
                    "newer:coffeelint:client"
                    "newer:coffee:client"
                    "browserify:client"
                    "uglify:client"
                    "bumpup:prerelease"
                ]
            styles:
                files: [
                    "static/stylus/**/*.styl"
                ]
                options:
                    nospawn: yes
                    livereload: yes
                tasks: [
                    "clear"
                    "stylus:styles"
                    "csslint:styles"
                    "csso:styles"
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
        # client
        "clean:client"
        "coffeelint:client"
        "coffee:client"
        "browserify"
        "uglify"
        # static
        "stylus:styles"
        "csslint:styles"
        "csso:styles"
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
        "coffeelint:client"
        "stylus:styles"
        "csslint:styles"
        "csso:styles"
    ]

    grunt.registerTask "patch", [
        "clear"
        # server
        "clean:server"
        "coffeelint:server"
        "coffee:server"
        "copy:server"
        # client
        "clean:client"
        "coffeelint:client"
        "coffee:client"
        "browserify"
        "uglify"
        # static
        "stylus:styles"
        "csslint:styles"
        "csso:styles"
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
        # client
        "clean:client"
        "coffeelint:client"
        "coffee:client"
        "browserify"
        "uglify"
        # static
        "stylus:styles"
        "csslint:styles"
        "csso:styles"
        # bump
        "bumpup:minor"
        "bumpup:prerelease"
        "bumpup:prerelease"
    ]
