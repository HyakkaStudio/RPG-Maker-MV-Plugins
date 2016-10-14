fs = require 'fs'

{spawn} = require 'child_process'

build = (dist) ->
    _dist = dist or 'dist'
    coffee = spawn 'coffee', ['-c', '-b', '-o', _dist, 'src']
    coffee.stderr.on 'data', (data) ->
        console.error data.toString()
    coffee.stdout.on 'data', (data) ->
        console.log data.toString()
    coffee.on 'exit', (code) ->
        console.log 'Done!' if code is 0

option '-o', '--output [DIR]', 'Set the directory that store the output files'

task 'build', 'Build target directory from src/', (options) ->
    build options.output
