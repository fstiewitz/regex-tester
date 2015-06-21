{$, TextEditorView, View} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

module.exports =
  class RegexView extends View
    RegexEditor: null
    TestEditor: null

    @content: ->
      @div class:'regex-tester', =>
        @div class: 'header', =>
          @div class: 'name bold', 'RegEx Tester'
        @div class:'block flex', =>
          @div class:'editor-item', =>
            @subview 'regex_data', new TextEditorView({mini:true, placeholderText:'Regular Expression'})
          @div class:'btn-group', =>
            @button outlet:'global', class:'btn icon icon-globe'
            @button outlet:'ignore_case', class:'btn', 'Aa'
        @div class:'block', =>
          @subview 'test_data', new TextEditorView({mini:true, placeholderText:'Test Input'})
        @div class:'output', outlet: 'output'

    initialize: ->
      @RegexEditor = @regex_data.getModel()
      @TestEditor = @test_data.getModel()

      @on 'click', '.btn', (e) =>
        item = e.currentTarget
        if item.classList.contains 'selected'
          item.classList.remove 'selected'
        else
          item.classList.add 'selected'
        @update()
        @test_data.focus()

      @disposables = new CompositeDisposable
      @disposables.add atom.commands.add 'atom-workspace', 'core:cancel': => @close()
      @disposables.add atom.tooltips.add(@global, title: 'Global Match')
      @disposables.add atom.tooltips.add(@ignore_case, title: 'Ignore Case')

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
        options = ''
        options = 'g' if @global.hasClass('selected')
        options += 'i' if @ignore_case.hasClass('selected')
        @regex = new RegExp(@RegexEditor.getText(), options)
        text = @TestEditor.getText()
        if @regex? and @RegexEditor.getText() isnt '' and text isnt ''
          output = []
          while (res = @regex.exec text)?
            output.push(JSON.stringify {match: res[0], groups: res.slice(1)}, null, 2)
            break if not @global.hasClass('selected')
          if output.length isnt 0
            if output.length isnt 1 and not @global.hasClass('selected')
              output.splice(0,1)
            @output.html(output.toString())
          else
            @output.html("<span class='error'>RegExp failed!</span>")
        else
          @output.html('')
      catch error
        @output.html "<span class='error'>#{error.message}</span>"
