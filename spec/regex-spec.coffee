regex = require '../lib/regex'

describe 'RegExp tests', ->
  describe 'Simple regex', ->
    it 'returns the correct match', ->
      m = regex.getMatches '(Hello|Goodbye) World', 'Hello World', {
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
      m = regex.getMatches '(Hello|Goodbye) World', 'hello world', {
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
      m = regex.getMatches '(a|b)', 'abba', {
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
          groups: ['a']
        }
        {
          match: 'b'
          groups: ['b']
        }
        {
          match: 'b'
          groups: ['b']
        }
        {
          match: 'a'
          groups: ['a']
        }
      ]

  describe 'Simple regex + global multiline', ->
    it 'returns the correct match', ->
      m = regex.getMatches '^((?:a|b)+)$', 'abba\ncddc\nbaab\n', {
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
          groups: ['abba']
        }
        {
          match: 'baab'
          groups: ['baab']
        }
      ]
