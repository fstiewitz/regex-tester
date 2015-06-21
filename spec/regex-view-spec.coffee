RegexView = require '../lib/regex-view'

describe 'Regex View', ->
  view = null

  beforeEach ->
    view = new RegexView
    jasmine.attachToDOM(view.element)
    view.show()
    expect(atom.workspace.getBottomPanels()[0].visible).toBeTruthy()

  afterEach ->
    view.destroy()

  describe 'When regex and test data is empty', ->

    beforeEach ->
      view.RegexEditor.setText ''
      view.TestEditor.setText ''

    it 'does not display any output', ->
      expect(view.output.html()).toBe ''

  describe 'When regex is wrong and test data is empty', ->

    beforeEach ->
      view.RegexEditor.setText '(Hello'
      view.TestEditor.setText ''
      view.update()

    it 'displays an error message', ->
      try
        reg = new RegExp('(Hello')
      catch error
        expect(view.output.html()).toBe "<span class=\"error\">#{error.message}</span>"

  describe 'When regex is right and test data is empty', ->

    beforeEach ->
      view.RegexEditor.setText '(Hello|Goodbye) (World)'
      view.TestEditor.setText ''
      view.update()

    it 'displays nothing', ->
      expect(view.output.html()).toBe ''

  describe 'When regex is right and test data is wrong', ->

    beforeEach ->
      view.RegexEditor.setText '(Hello|Goodbye) (World)'
      view.TestEditor.setText 'hello world'
      view.update()

    it 'displays an error message', ->
      expect(view.output.html()).toBe "<span class=\"error\">RegExp failed!</span>"

  describe 'When regex is right and test data is right', ->

    beforeEach ->
      view.RegexEditor.setText '(Hello|Goodbye) (World)'
      view.TestEditor.setText 'Hello World'
      view.update()

    it 'displays the match', ->
      expect(view.output.html()).toBe JSON.stringify {
        match: 'Hello World'
        groups: [
          'Hello'
          'World'
        ]
      }, null, 2

  describe 'When regex is right and ignore case is enabled', ->

    beforeEach ->
      view.RegexEditor.setText '(Hello|Goodbye) (World)'
      view.TestEditor.setText 'hello world'
      view.ignore_case.click()
      view.update()

    it 'displays the match', ->
      expect(view.output.html()).toBe JSON.stringify {
        match: 'hello world'
        groups: [
          'hello'
          'world'
        ]
      }, null, 2

  describe 'When regex is right and global match is enabled', ->

    beforeEach ->
      view.RegexEditor.setText '(Hello|Goodbye) (World)'
      view.TestEditor.setText 'Hello World, Goodbye World'
      view.global.click()
      view.update()

    it 'displays the match', ->
      expect(view.output.html()).toBe JSON.stringify({
        match: 'Hello World'
        groups: [
          'Hello'
          'World'
        ]
      }, null, 2) + ',' + JSON.stringify({
        match: 'Goodbye World'
        groups: [
          'Goodbye'
          'World'
        ]
        }, null, 2)

  describe 'When regex is right and both options are enabled', ->

    beforeEach ->
      view.RegexEditor.setText '(Hello|Goodbye) (World)'
      view.TestEditor.setText 'Hello World, goodbye world'
      view.global.click()
      view.ignore_case.click()
      view.update()

    it 'displays the match', ->
      expect(view.output.html()).toBe JSON.stringify({
        match: 'Hello World'
        groups: [
          'Hello'
          'World'
        ]
      }, null, 2) + ',' + JSON.stringify({
        match: 'goodbye world'
        groups: [
          'goodbye'
          'world'
        ]
        }, null, 2)
