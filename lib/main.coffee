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
    @disposables.add atom.commands.add 'atom-workspace', 'regex-tester:show': => @regexview.show()
    @disposables.add atom.commands.add 'atom-workspace', 'regex-tester:hide': => @regexview.hide()

  deactivate: ->
    @disposables.dispose()
    @regexview.destroy()
