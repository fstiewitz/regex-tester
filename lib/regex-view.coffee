{$, $$, TextEditorView, View} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'
xregex = require './xregex'
regex = require './regex'

module.exports =
  class RegexView extends View
    RegexEditor: null
    TestEditor: null

    @content: ->
      @div class:'regex-tester', =>
        @div class: 'header', =>
          @div class: 'name bold', 'RegEx Tester'
        @div class:'block flex', =>
          @div class:'editor-item flex-editor', =>
            @subview 'regex_data', new TextEditorView({mini: true, placeholderText:'Regular Expression'})
          @div class:'btn-groups', =>
            @div id:'regex-type', class:'btn-group', =>
              @button outlet:'xregexp', class:'btn bold', 'X'
            @div id:'regex-config', class:'btn-group', =>
              @button outlet:'global', class:'btn icon icon-globe'
              @button outlet:'ignore_case', class:'btn bold', 'Aa'
              @button outlet:'multiline', class:'btn icon icon-three-bars'
              @button outlet:'explicit_capture', class:'btn icon icon-code xregexp hidden'
              @button outlet:'free_space', class:'btn bold xregexp hidden', '__'
              @button outlet:'dot_all', class:'btn bold xregexp hidden', '.'
        @div class:'block', =>
          @div class:'editor-item', =>
            @subview 'test_data', new TextEditorView({mini:true, placeholderText:'Test Input'})
        @div class:'output', outlet: 'output'

    initialize: ->
      @RegexEditor = @regex_data.getModel()
      @TestEditor = @test_data.getModel()

      @RegexEditor.setText ''
      @TestEditor.setText ''
      @find('.btn').removeClass 'selected'

      @on 'click', '#regex-config .btn', (e) =>
        item = e.currentTarget
        if item.classList.contains 'selected'
          item.classList.remove 'selected'
        else
          item.classList.add 'selected'
        @update()
        @test_data.focus()

      @on 'click', '#regex-type .btn', (e) =>
        item = e.currentTarget
        item.classList.toggle 'selected'
        if item.classList.contains 'selected'
          @find('#regex-config .xregexp').removeClass 'hidden'
        else
          @find('#regex-config .xregexp').addClass 'hidden'
        @update()
        @regex_data.focus()

      @disposables = new CompositeDisposable
      @disposables.add atom.commands.add 'atom-workspace', 'core:cancel': => @close()
      @disposables.add atom.tooltips.add(@global, title: 'Global Match')
      @disposables.add atom.tooltips.add(@ignore_case, title: 'Ignore Case')
      @disposables.add atom.tooltips.add(@multiline, title: 'Multiline')
      @disposables.add atom.tooltips.add(@explicit_capture, title: 'Explicit capture')
      @disposables.add atom.tooltips.add(@free_space, title: 'Free-spacing and line comments')
      @disposables.add atom.tooltips.add(@dot_all, title: 'Dot matches all')
      @disposables.add atom.tooltips.add(@xregexp, title: 'Use XRegExp')

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

    setEditorMinis: (reg, test) ->
      @RegexEditor.setMini(reg)
      @TestEditor.setMini(test)

    update: ->
      @setEditorMinis not (@xregexp.hasClass('selected') and @free_space.hasClass('selected')), not @multiline.hasClass('selected')

      options =
        global: @global.hasClass('selected')
        multiline: @multiline.hasClass('selected')
        ignore_case: @ignore_case.hasClass('selected')
        free_space: @free_space.hasClass('selected')
        explicit: @explicit_capture.hasClass('selected')
        dot: @dot_all.hasClass('selected')
      try
        if @xregexp.hasClass 'selected'
          m = xregex.getMatches @RegexEditor.getText(), @TestEditor.getText(), options
        else
          m = regex.getMatches @RegexEditor.getText(), @TestEditor.getText(), options
        if m?
          if m.length isnt 0
            @output.html JSON.stringify m
          else
            @output.html "<span class='error'>RegExp failed!</span>"
        else
          @output.html ''
      catch error
        @output.html "<span class='error'>#{error.message}</span>"
