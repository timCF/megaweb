state =
	const: {}
	data: {
		foo: 1
		foo_stack: []
		bar: "HELLO, WORLD!"
	}
	opts: {
		visibility: {
			foo: "visible"
			bar: "hidden"
		}
	}
	handlers: {
		change_from_view: (key, ev) ->
			if ev? and ev.target? and ev.target.value?
				state.data[key] = ev.target.value
		show_this: (some) -> Object.keys(state.opts.visibility).map (key) -> if some == key then state.opts.visibility[key] = "visible" else state.opts.visibility[key] = "hidden"
		send_button: (key) -> to_server(key, state.data[key])
	}


widget = require("widget")
renderTimeout = null
renderStarted = false
domelement    = null
bullet = $.bullet("ws://" + location.hostname + ":8081/bullet")


to_server = (subject, content) ->
	bullet.send(JSON.stringify({"subject": subject,"content": content}))
#
#	view renderers
#
render = () ->
	if renderStarted is false
		renderStarted = true
		render_process()
render_process = () ->
	React.render(widget(state), domelement) if domelement?
	clearTimeout renderTimeout
	renderTimeout = setTimeout render_process, 500
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
#	bullet handlers
#
document.addEventListener "DOMContentLoaded", (e) ->
	domelement  = document.getElementsByClassName("container-fluid")[0]
	bullet.onopen = () -> 
		notice("bullet websocket: connected")
		render()
	bullet.ondisconnect = () -> 
		error("bullet websocket: disconnected")
		render()
	bullet.onclose = () -> 
		warn("bullet websocket: closed")
		render()
	bullet.onheartbeat = () ->
		to_server("ping","nil")
		render()
	bullet.onmessage = (e) -> 
		mess = $.parseJSON(e.data)
		subject = mess.subject
		content = mess.content
		switch subject
			when "pong" then "ok"
			when "error" then error(content)
			when "warn" then warn(content)
			when "notice" then notice(content)
			when "foo" then state.data.foo_stack.push(content)
			else alert("subject : "+subject+" | content : "+content)
		render()