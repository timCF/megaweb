state  = {data: {}, const: {}}
widget = require("widget")

renderTimeout = null
renderStarted = false
domelement    = null
bullet = $.bullet("ws://" + location.hostname + ":8081/bullet")

send_message = (message, content) ->
	bullet.send(JSON.stringify({"subject": subject,"content": content}))
renderMessage = () ->
	if renderStarted is false
		renderStarted = true
		React.render(widget(state), domelement) if domelement?
		clearTimeout renderTimeout
		renderTimeout = setTimeout renderMessage, 1000
#
#	notifications
#
error = (mess) ->
	$.growl.error({ message: mess , duration: 20000})
warn = (mess) ->
	$.growl.warning({ message: mess , duration: 20000})
notice = (mess) ->
	$.growl.notice({ message: mess , duration: 20000})
#
#	notifications
#
document.addEventListener "DOMContentLoaded", (e) ->
	domelement  = document.getElementsByClassName("container")[0]
	bullet.onopen = () -> 
		notice("bullet websocket: connected")
		renderMessage()
	bullet.ondisconnect = () -> 
		error("bullet websocket: disconnected")
		renderMessage()
	bullet.onclose = () -> 
		warn("bullet websocket: closed")
		renderMessage()
	bullet.onheartbeat = () ->
		send_message("ping","nil")
		renderMessage()
	bullet.onmessage = (e) -> 
		mess = $.parseJSON(e.data)
		subject = mess.subject
		content = mess.content
		switch subject
			when "pong" then "ok"
			when "error" then error(content)
			when "warn" then warn(content)
			when "notice" then notice(content)
			else alert("subject : "+subject+" | content : "+content)
		renderMessage()