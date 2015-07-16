module.exports =
  getMatches: (_regex, text, _options) ->
    options = ''
    options += 'g' if _options.global
    options += 'm' if _options.multiline
    options += 'i' if _options.ignore_case

    regex = new RegExp(_regex, options)

    output = []
    if regex? and _regex isnt '' and text isnt ''
      while (res = regex.exec text)?
        output.push
          match: res[0]
          groups: res.slice(1)
        break if not _options.global
    output
