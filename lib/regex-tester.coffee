RegexView = require './regex-view'
{CompositeDisposable} = require 'atom'

module.exports = RegexTester =
  RegexView: null
  regexview: null

  disposables: null

  createRegexView: ->
    @RegexView ?= require './regex-view'
    @regexview ?= new @RegexView

  activate: (state) ->
    @createRegexView()
    @disposables = new CompositeDisposable
    @disposables.add atom.commands.add 'atom-workspace', 'regex-tester:toggle': => @regexview.show()

  deactivate: ->
    @dispoables.dispose()
    @regexview.destroy()
