{$, $$, TextEditorView, View} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'
XRegExp = require('xregexp').XRegExp

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

    updateRegExp: (options) ->
      @regex = new RegExp(@RegexEditor.getText(), options)
      text = @TestEditor.getText()
      if @regex? and @RegexEditor.getText() isnt '' and text isnt ''
        output = []
        while (res = @regex.exec text)?
          output.push(JSON.stringify {match: res[0], groups: res.slice(1)}, null, 2)
          break if not @global.hasClass('selected')
        if output.length isnt 0
          @output.html(output.toString())
        else
          @output.html("<span class='error'>RegExp failed!</span>")
      else
        @output.html('')

    updateXRegExp: (options) ->
      options += 'n' if @explicit_capture.hasClass('selected')
      options += 's' if @dot_all.hasClass('selected')
      options += 'x' if @free_space.hasClass('selected')
      @regex = new XRegExp(@RegexEditor.getText(), options)
      text = @TestEditor.getText()
      if @regex? and @RegexEditor.getText() isnt '' and text isnt ''
        output = []
        _text = text
        while true
          break if _text is '' or not _text?
          _res = @regex.exec text
          break unless _res?

          res = XRegExp.exec _text, @regex
          break unless res?
          _text = _text.substr(@regex.lastIndex)

          m = Object.keys(res).filter (value) ->
            not (/[\d]+|input|index/.test(value))
          if m.length isnt 0
            groups = {}
            for name in m
              groups[name] = res[name]
            output.push(JSON.stringify {match: res.input, named_groups: groups, groups: res.slice(1).toString()}, null, 2)
          else
            output.push(JSON.stringify {match: res[0], groups: res.slice(1)}, null, 2)
          break if not @global.hasClass('selected')
        if output.length isnt 0
          @output.html(output.toString())
        else
          @output.html("<span class='error'>RegExp failed!</span>")
      else
        @output.html('')

    update: ->
      @setEditorMinis not (@xregexp.hasClass('selected') and @free_space.hasClass('selected')), not @multiline.hasClass('selected')
      try
        options = ''
        options = 'g' if @global.hasClass('selected')
        options += 'i' if @ignore_case.hasClass('selected')
        options += 'm' if @multiline.hasClass('selected')
        if @xregexp.hasClass 'selected'
          @updateXRegExp options
        else
          @updateRegExp options
      catch error
        @output.html "<span class='error'>#{error.message}</span>"
