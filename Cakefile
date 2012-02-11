fs      = require 'fs'
{spawn} = require 'child_process'
{log}   = require 'util'
{debug} = require 'util'
stylus  = require 'stylus'
jade    = require 'jade'
_       = require 'underscore'


srcDir = 'source'
targetDir = 'build'

srcCoffeeDir = "#{srcDir}/coffee"
srcStylusDir = "#{srcDir}/stylus"
srcJadeDir = "#{srcDir}/jade"

# It walks through a directory and invoke callback function with array of file names.
walk = (dir, callback) ->
  results = []
  fs.readdir dir, (err, list) ->
    return callback err if err
    pending = list.length
    return callback null, results unless pending
    list.forEach (file) ->
      file = "#{dir}/#{file}"
      fs.stat file, (err, stat) ->
        if stat and stat.isDirectory()
          walk file, (err, res) ->
            results = results.concat res
            callback null, results unless --pending
        else
          results.push file
          callback null, results unless --pending


option '-t', '--target [TARGET]', 'target source'

task 'build', 'Build source files', (options) ->
  targets = (options.target or 'coffee,jade,stylus')
    .split(',')
    .filter (target) -> target in ['coffee', 'jade', 'stylus']

  if 'coffee' in targets
    walk srcCoffeeDir, (err, results) ->
      for file in results
        filename = file.split('/')[2].split('.')[0]
        log "compile #{file} -> #{targetDir}/#{filename}.js"
    coffee = spawn 'coffee', ['-c', '-o', targetDir, srcCoffeeDir]
    coffee.stderr.on 'data', (data) -> debug data
    coffee.stdout.on 'data', (data) -> log data

  if 'jade' in targets
    walk srcJadeDir, (err, results) ->
      debug err if err

      for file in results
        filename = file.split('/')[2].split('.')[0]
        log "compile #{file} -> #{targetDir}/#{filename}.html"
        fs.readFile file, 'utf8', (err, content) ->
          html = jade.compile(content, {filename: file})()
          fs.writeFile "#{targetDir}/#{filename}.html"
                     , html
                     , 'utf8'
                     , (err) -> debug err if err

  if 'stylus' in targets
    walk srcStylusDir, (err, results) ->
      debug err if err

      for file in results
        filename = file.split('/')[2].split('.')[0]
        log "compile #{file} -> #{targetDir}/#{filename}.css"
        fs.readFile file, 'utf8', (err, content) ->
          stylus(content)
            .render (err, css) -> 
              fs.writeFile "#{targetDir}/#{filename}.css"
                         , css
                         , 'utf8'
                         , (err) -> debug err if err