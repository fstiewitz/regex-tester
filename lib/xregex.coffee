XRegExp = require('xregexp').XRegExp

module.exports =
  getMatches: (_regex, text, _options) ->
    options = ''
    options += 'g' if _options.global
    options += 'm' if _options.multiline
    options += 'i' if _options.ignore_case
    options += 'n' if _options.explicit
    options += 's' if _options.dot
    options += 'x' if _options.free_space

    regex = new XRegExp(_regex, options)
    _regex = new RegExp(regex.source, options.replace(/n|s|x/g, ''))
    output = []
    if regex? and _regex isnt '' and text isnt ''
      _text = text
      while true
        break if _text is '' or not _text? # Break at End Of Text
        _res = _regex.exec text
        break unless _res? # Avoid endless loop because of XRegExp's global flag

        res = regex.xexec _text
        break unless res?
        _text = _text.substr(regex.lastIndex) # Advance _text because XRegExp doesn't

        m = Object.keys(res).filter (value) ->
          not (/[\d]+|input|index/.test(value)) # Get group names

        if m.length isnt 0
          groups = {}
          for name in m
            groups[name] = res[name]
        output.push
          match: _res[0]
          named_groups: groups
          groups: res.slice(1)

        break if not _options.global
    output
