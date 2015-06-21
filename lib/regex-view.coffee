{TextEditorView, View} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

module.exports =
  class RegexView extends View
    RegexEditor: null
    TestEditor: null

    @content: ->
      @div class:'regex-tester', =>
        @div class: 'header', =>
          @div class: 'name bold', 'RegEx Tester'
          @div class: 'icon-close'
        @div class:'block', =>
          @subview 'regex_data', new TextEditorView({mini:true, placeholderText:'Regular Expression'})
        @div class:'block', =>
          @subview 'test_data', new TextEditorView({mini:true, placeholderText:'Test Input'})
        @div class:'output', outlet: 'output'

    initialize: ->
      @RegexEditor = @regex_data.getModel()
      @TestEditor = @test_data.getModel()

      @disposables = new CompositeDisposable
      @disposables.add atom.commands.add 'atom-workspace', 'core:cancel': => @close()
      @on 'click', '.icon-close', => @close()
      @RegexEditor.onDidStopChanging => @update()
      @TestEditor.onDidStopChanging => @update()

    destroy: ->
      @disposables.dispose()
      @panel?.destroy()
      @panel = null

    close: ->
      @panel?.hide()

    show: ->
      @panel ?= atom.workspace.addBottomPanel(item: this)
      @panel.show()
      @regex_data.focus()

    update: ->
      try
        @regex = new RegExp(@RegexEditor.getText())
        text = @TestEditor.getText()
        if @regex? and text isnt ''
          output = @regex.exec text
          if output?
            if output.length isnt 1
              output.splice(0,1)
            @output.html(output.toString())
          else
            @output.html("<span class='error'>RegExp failed!</span>")
      catch error
        @output.html "<span class='error'>#{error.message}</span>"
