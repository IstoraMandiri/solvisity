Meteor.startup ->
  repoName = prompt 'Enter github repo with solidity contracts', 'nexusdev/ENS'
  Meteor.call 'getRepo', repoName, (err, data) ->
    cytoscape
      elements: data
      container: document.getElementById('cy')
      boxSelectionEnabled: false
      autounselectify: true
      layout: name: 'dagre'
      style: [
        {
          selector: 'node'
          style:
            'content': 'data(id)'
            'text-opacity': 0.5
            'text-valign': 'center'
            'text-halign': 'right'
            'background-color': '#11479e'
        }
        {
          selector: 'edge'
          style:
            'width': 4
            'target-arrow-shape': 'triangle'
            'line-color': '#9dbaea'
            'target-arrow-color': '#9dbaea'
        }
      ]
