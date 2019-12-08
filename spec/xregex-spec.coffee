xregex = require '../lib/xregex'

describe 'XRegExp tests', ->
  describe 'Simple regex', ->
    it 'returns the correct match', ->
      m = xregex.getMatches '(Hello|Goodbye) World', 'Hello World', {
        global: false
        multiline: false
        ignore_case: false
        free_space: false
        dot: false
        explicit: false
      }
      expect(m.length).toBe 1
      expect(m[0].match).toBe 'Hello World'
      expect(m[0].groups.length).toBe 1
      expect(m[0].groups[0]).toBe 'Hello'

  describe 'Simple regex + ignore case', ->
    it 'returns the correct match', ->
      m = xregex.getMatches '(Hello|Goodbye) World', 'hello world', {
        global: false
        multiline: false
        ignore_case: true
        free_space: false
        dot: false
        explicit: false
      }
      expect(m.length).toBe 1
      expect(m[0].match).toBe 'hello world'
      expect(m[0].groups.length).toBe 1
      expect(m[0].groups[0]).toBe 'hello'

  describe 'Simple regex + global', ->
    it 'returns the correct match', ->
      m = xregex.getMatches '(a|b)', 'abba', {
        global: true
        multiline: false
        ignore_case: false
        free_space: false
        dot: false
        explicit: false
      }
      expect(m.length).toBe 4
      expect(m).toEqual [
        {
          match: 'a'
          named_groups: { groups: undefined }
          groups: ['a']
        }
        {
          match: 'b'
          named_groups: { groups: undefined }
          groups: ['b']
        }
        {
          match: 'b'
          named_groups: { groups: undefined }
          groups: ['b']
        }
        {
          match: 'a'
          named_groups: { groups: undefined }
          groups: ['a']
        }
      ]

  describe 'Simple regex + global multiline', ->
    it 'returns the correct match', ->
      m = xregex.getMatches '^((?:a|b)+)$', 'abba\ncddc\nbaab\n', {
        global: true
        multiline: true
        ignore_case: false
        free_space: false
        dot: false
        explicit: false
      }
      expect(m.length).toBe 2
      expect(m).toEqual [
        {
          match: 'abba'
          named_groups: { groups: undefined }
          groups: ['abba']
        }
        {
          match: 'baab'
          named_groups: { groups: undefined }
          groups: ['baab']
        }
      ]

  describe 'XRegExp + explicit capture', ->
    it 'returns the correct match', ->
      m = xregex.getMatches '(?<group>(a|b)+)(c|d)', 'aabc', {
        global: false
        multiline: false
        ignore_case: false
        free_space: false
        dot: false
        explicit: true
      }
      expect(m.length).toBe 1
      expect(m).toEqual [
        {
          match: 'aabc'
          named_groups: {
            groups: undefined
            group: 'aab'
          }
          groups: ['aab']
        }
      ]

  describe 'XRegExp + dot matches all', ->
    it 'returns the correct match', ->
      m = xregex.getMatches '(.+)', 'aa\nbb', {
        global: false
        multiline: false
        ignore_case: false
        free_space: false
        dot: true
        explicit: false
      }
      expect(m.length).toBe 1
      expect(m).toEqual [
        {
          match: 'aa\nbb'
          named_groups: { groups: undefined }
          groups: ['aa\nbb']
        }
      ]

  describe 'XRegExp + free spacing and line comments', ->
    it 'returns the correct match', ->
      m = xregex.getMatches '(?<file> [\\S]+.coffee) : (?<row>[\\d]+) #Comment', 'xregex-spec.coffee:134', {
        global: false
        multiline: false
        ignore_case: false
        free_space: true
        dot: false
        explicit: false
      }
      expect(m.length).toBe 1
      expect(m).toEqual [
        {
          match: 'xregex-spec.coffee:134'
          named_groups: {
            groups: undefined
            file: 'xregex-spec.coffee'
            row: '134'
          }
          groups: ['xregex-spec.coffee', '134']
        }
      ]
