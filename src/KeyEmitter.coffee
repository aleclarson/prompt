
{EventEmitter} = require "events"

assertType = require "assertType"
keypress = require "keypress"
Event = require "Event"
Type = require "Type"

keyModifiers = "ctrl meta shift".split " "

type = Type "KeyEmitter"

type.defineValues ->

  _didPressKey: Event()

  _emitter: null

type.initInstance ->
  stream = process.stdin
  if stream and stream.isTTY
    stream.setRawMode yes
    @_emitter = new EventEmitter
    @_emitter.on "keypress", @_keypress.bind this
    @_emitter.write = (chunk) -> stream.write chunk
    keypress @_emitter
  return

type.defineGetters

  didPressKey: -> @_didPressKey.listenable

type.defineMethods

  send: (data) ->
    assertType data, String
    @_emitter.emit "data", data

  _keypress: (char, key) ->

    command = if key then key.name else char

    if modifier = @_getModifier key
      command += "+" + modifier

    @_didPressKey.emit {char, key, command, modifier}
    return

  _getModifier: (key) ->
    for modifier in keyModifiers
      return modifier if key[modifier]
    return null

module.exports = type.construct()