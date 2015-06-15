#
#	constants, defaults as callbacks arity 0
#
constants = 
	default_opts: () -> {
		visibility: {
			foo: "visible"
			bar: "hidden"
		}
	}
#
#	state for jade
#
state =
	data: {
		foo: 1
		foo_stack: []
		bar: "HELLO, WORLD!"
	}
	handlers: {
		#
		#	app local handlers
		#
		send_button: (key) -> to_server(key, state.data[key])
		#
		#	some main-purpose handlers
		#
		change_from_view: (key, ev) ->
			if ev? and ev.target? and ev.target.value?
				state.data[key] = ev.target.value
		show_block: (some) -> Object.keys(state.opts.visibility).map (key) -> if some == key then state.opts.visibility[key] = "visible" else state.opts.visibility[key] = "hidden"
		switch_sidebar: () -> if state.opts.sidebar == "hidden" then state.opts.sidebar = "visible" else state.opts.sidebar = "hidden"
		#
		#	local storage
		#
		reset_opts: () ->
			state.opts = constants.default_opts()
			store.remove("opts")
			warn("Reset options to defaults")
		save_opts: () -> 
			store.set("opts", state.opts)
			notice("Options saved")
		load_opts: () -> 
			from_storage = store.get("opts")
			if from_storage
				state.opts = from_storage
			else
				state.handlers.reset_opts()
			state.opts.sidebar = "hidden"
	}
#
#	messages
#
to_server = (subject, content) ->
	bullet.send(JSON.stringify({"subject": subject,"content": content}))
#
#	view renderers
#
widget = require("widget")
renderTimeout = null
renderStarted = false
domelement    = null
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
bullet = $.bullet("ws://" + location.hostname + ":8081/bullet")
document.addEventListener "DOMContentLoaded", (e) ->
	domelement  = document.getElementsByClassName("container-fluid")[0]
	state.handlers.load_opts()
	render()
	console.log("DOMContentLoaded")
	bullet.onopen = () -> notice("bullet websocket: connected")
	bullet.ondisconnect = () -> error("bullet websocket: disconnected")
	bullet.onclose = () -> warn("bullet websocket: closed")
	bullet.onheartbeat = () -> to_server("ping","nil")
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