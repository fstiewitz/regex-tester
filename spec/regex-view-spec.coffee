View = require '../lib/regex-view'

describe 'Regex View', ->
  view = null

  beforeEach ->
    view = new View

  afterEach ->
    view.destroy()

  describe 'On create', ->
    it 'has the default flags and values', ->
      expect(view.RegexEditor.getText()).toBe ''
      expect(view.TestEditor.getText()).toBe ''
      expect(view.output.html()).toBe ''
      expect(view.find('#regex-config .selected').length).toBe 0
      expect(view.regexp.hasClass('selected')).toBe true
      expect(view.xregexp.hasClass('selected')).toBe false

  describe 'When switching regex type', ->
    describe 'to XRegExp', ->
      it 'displays XRegExp specific flags', ->
        expect(view.find('.xregex-config').hasClass('hidden')).toBe true
        view.xregexp.click()
        expect(view.find('.xregex-config').hasClass('hidden')).toBe false
        expect(view.xregexp.hasClass('selected')).toBe true
        expect(view.regexp.hasClass('selected')).toBe false

    describe 'to RegExp', ->
      it 'hides XRegExp specific flags', ->
        expect(view.find('.xregex-config').hasClass('hidden')).toBe true
        view.xregexp.click()
        view.regexp.click()
        expect(view.find('.xregex-config').hasClass('hidden')).toBe true
        expect(view.xregexp.hasClass('selected')).toBe false
        expect(view.regexp.hasClass('selected')).toBe true

  describe 'When setting multi-line flag', ->

    beforeEach ->
      expect(view.TestEditor.isMini()).toBe false
      view.TestEditor.setText('abc\\ndef')
      view.multiline.click()

    it 'shows a multi-line input editor', ->
      expect(view.multiline.hasClass('selected')).toBe true
      expect(view.TestEditor.isMini()).toBe false

    it 'splits the input line', ->
      expect(view.TestEditor.getText()).toBe 'abc\\ndef'

    describe 'When unchecking the flag', ->
      beforeEach ->
        view.multiline.click()

      it 'shows a mini editor', ->
        expect(view.TestEditor.isMini()).toBe false

      it 'merges all input lines', ->
        expect(view.TestEditor.getText()).toBe 'abc\\ndef'

  describe 'When setting free-space flag', ->

    beforeEach ->
      expect(view.RegexEditor.isMini()).toBe false
      view.RegexEditor.setText('abc\\ndef')
      view.xregexp.click()
      view.free_space.click()

    it 'shows a multi-line input editor', ->
      expect(view.free_space.hasClass('selected')).toBe true
      expect(view.RegexEditor.isMini()).toBe false

    it 'splits the input line', ->
      expect(view.RegexEditor.getText()).toBe 'abc\\ndef'

    describe 'When unchecking the flag', ->
      beforeEach ->
        view.free_space.click()

      it 'shows a mini editor', ->
        expect(view.RegexEditor.isMini()).toBe false

      it 'merges all input lines', ->
        expect(view.RegexEditor.getText()).toBe 'abc\\ndef'
