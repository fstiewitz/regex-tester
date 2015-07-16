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
        @div class: 'body', =>
          @div class:'block flex', =>
            @div class:'editor-item flex-editor', =>
              @subview 'regex_data', new TextEditorView({mini: true, placeholderText:'Regular Expression'})
            @div =>
              @div id:'regex-type', class:'btn-group', =>
                @button outlet:'regexp', class:'btn bold selected', 'RegExp'
                @button outlet:'xregexp', class:'btn bold', 'XRegExp'
              @div id:'regex-config', =>
                @div class:'btn-group', =>
                  @button outlet:'global', class:'btn icon icon-globe'
                  @button outlet:'ignore_case', class:'btn bold', 'Aa'
                  @button outlet:'multiline', class:'btn icon icon-three-bars'
                @div class:'xregex-config hidden btn-group', =>
                  @button outlet:'explicit_capture', class:'btn icon icon-code'
                  @button outlet:'free_space', class:'btn bold', '__'
                  @button outlet:'dot_all', class:'btn bold', '.'
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
      @regexp.addClass 'selected'

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
        if not item.classList.contains 'selected'
          @find('#regex-type .btn').removeClass('selected')
          item.classList.add 'selected'
        if @xregexp.hasClass 'selected'
          @find('.xregex-config').removeClass('hidden')
        else
          @find('.xregex-config').addClass('hidden')
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

      @TestEditor.onDidChangeMini (mini) => if mini is true then @joinLines(@TestEditor) else @splitLines(@TestEditor)
      @RegexEditor.onDidChangeMini (mini) => if mini is true then @joinLines(@RegexEditor) else @splitLines(@RegexEditor)

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

    clear: ->
      @output.html('')

    joinLines: (editor) ->
      editor.setText(editor.getText().replace(/\n/g,'\\n'))

    splitLines: (editor) ->
      editor.setText(editor.getText().replace(/\\n/g,'\n'))

    createMatchItem: (match) ->
      $$ ->
        @div class:'match', =>
          @div class:'match_part', =>
            @span class:'key', 'match: '
            @span '"' + match.match + '"'
          if match.named_groups?
            for k in Object.keys(match.named_groups)
              @div class:'match_part', =>
                @span class:'key', '  ' + k + ': '
                @span '"' + match.named_groups[k] + '"'
          @div class:'match_part', =>
            @span class:'key', 'groups: '
            @span '"' + match.groups.toString() + '"'

    update: ->
      @clear()

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
            for match in m
              @output.append @createMatchItem match
          else
            @output.html "<span class='error'>RegExp failed!</span>"
        else
          @output.html ''
      catch error
        @output.html "<span class='error'>#{error.message}</span>"
