class Parser
  constructor: () ->

  parse: (tokenizedInput) ->
    actions = @splitIntoActions(tokenizedInput)
    actors = @parseActors(actions)

    actors: actors
    actions: ({tokens: a} for a in actions)


  splitIntoActions: (tokens) ->
    actions = []
    currentAction = []

    for a in tokens
      currentAction.push a unless a is "\n"

      if a is "\n"
        actions.push currentAction
        currentAction = []

    actions.push currentAction
    actions

  parseActors: (actions) ->
    actors = {}

    for action in actions
      actionString = action.join("")

      parts = actionString.split("->")
      debugger;
      for a in parts
        [b] = a.split(":")

        if b != ""
          actors[b] = true

    (a for a of actors)

window.Parser = new Parser
module?.exports = new Parser
