state  = {}
widget = require("widget")

renderTimeout = null
renderStarted = false
domelement    = null

renderMessage = () ->
    React.render(widget(state), domelement) if domelement?
    clearTimeout renderTimeout
    renderTimeout = setTimeout renderMessage, 1000

document.addEventListener "DOMContentLoaded", (e) ->
    domelement  = document.getElementsByClassName("container")[0]
    bullet = $.bullet("ws://" + location.hostname + ":8999/bullet")
    bullet.onopen = () -> console.log("bullet: connected")
    bullet.ondisconnect = () -> 
      if renderStarted is false
        renderStarted = true
        do renderMessage
      console.log("bullet: disconnected")
    bullet.onclose = () -> console.log("bullet: closed")
    bullet.onmessage = (e) -> 
      console.log "going to render... "
      mess = $.parseJSON(e.data)
      subject = mess.subject
      content = mess.content
      console.log("subject : "+subject+" | content : "+content)
      state.subject = subject
      state.content = content
      if renderStarted is false
        renderStarted = true
        do renderMessage