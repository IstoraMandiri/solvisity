async = Meteor.npmRequire('async')
GithubApi = Meteor.npmRequire('github')
github = new GithubApi version: "3.0.0"

Meteor.methods
  getRepo: (repoName) ->
    response = Async.runSync (done) ->
      github.search.code
        q: ['import ','in:file','extension:sol', "repo:#{repoName}"].join '+'
      , (err, data) ->
        done null, data

    files = {}
    for item in response.result.items
      files[item.path] = item

    Async.runSync (done) ->
      async.forEachOfLimit files, 6, (value, key, callback) ->
        url = value.html_url.replace('/blob/', '/').replace('https://github.com/', 'https://raw.githubusercontent.com/')
        Meteor.http.call "GET", url, (err,res) ->
          lines = []
          for line in res.content.split('\n')
            if line.indexOf('import ') is 0
              match = line.match(/(["'])(?:(?=(\\?))\2.)*?\1/)
              if match
                lines.push match[0].replace(/\\\//g, "/").replace(/["']/g, "")
          files[key].imports = lines
          callback()
      , done

    data =
      nodes : []
      edges : []

    for key, val of files
      key = key.replace('dapple/packages/', '')
      if key[0] isnt '/'
        key = "/#{key}"

      data.nodes.push data: id: key

      for source in val.imports
        source = "/#{source}"
        # add to nodes if it doesn't exist
        unless (_.find data.nodes, (node) -> node.data.id is source)
          data.nodes.push data: id: source
        # create the edge
        data.edges.push
          data:
            source: source
            target: key

    return data