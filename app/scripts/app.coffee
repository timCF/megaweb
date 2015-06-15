#
#	constants, defaults as callbacks arity 0
#
constants = 
	default_opts: () -> {
		visibility: {
			main_tab: "visible"
			extra_tabs: "hidden"
			opts: "hidden"
		}
		extra_buttons: {
			"-> 3": {
				name: "-> 3"
				copy_to: 3
				small_letter_all: false
				big_letter_all: false
				small_letter: false
				big_letter: true
				str_modifiers: [
					str: "!"
					add_to_all_begin: false
					add_to_all_end: false
					add_to_begin: false
					add_to_end: true
					remove: false
					replacement: ""
					replace: false
				]
				str_modifier_fields: {
					str: ""
					add_to_all_begin: false
					add_to_all_end: false
					add_to_begin: false
					add_to_end: false
					remove: false
					replacement: ""
					replace: false
				}
			}
			"-> 4": {
				name: "-> 4"
				copy_to: 4
				small_letter_all: false
				big_letter_all: false
				small_letter: false
				big_letter: true
				str_modifiers: [
					str: "!"
					add_to_all_begin: false
					add_to_all_end: false
					add_to_begin: false
					add_to_end: false
					remove: true
					replacement: ""
					replace: false
				]
				str_modifier_fields: {
					str: ""
					add_to_all_begin: false
					add_to_all_end: false
					add_to_begin: false
					add_to_end: false
					remove: false
					replacement: ""
					replace: false
				}
			}
		}
	}
	main_tab_cells: (row, col, prop) ->
		cellProperties = {}
		if row == 0
			cellProperties.readOnly = true
		if col in [1,2,3,6]
			"todo"
		cellProperties
	temp_example: () -> [['', 'Kia', 'Nissan', 'Toyota', 'Honda', 'Mazda', 'Ford']].concat([1..5000].map((_) -> ["2015", "hi there", "how are you?", "user", "have", "nice", "day"] ))
	main_tab_config: () -> {
			data: constants.temp_example()
			minSpareRows: 1
			rowHeaders: true
			colHeaders: true
			contextMenu: true
			fixedRowsTop: 1,
			cells: constants.main_tab_cells
			stretchH: 'all'
			currentRowClassName: 'currentRow'
			currentColClassName: 'currentCol'
			height: $(window).height()-70
			width: $(window).width()
			afterSelectionEndByProp: (a,b,c,d) -> state.data.selected_area = [a,b,c,d]
	}
#
#	state for jade
#
state =
	data: {
		current_tab: "main_tab"
		selected_area: [0,0,0,0]
		find: ""
		replace: ""
		tabs: {}
		extra_buttons_editor: {
			name: undefined
			copy_to: undefined
			small_letter_all: false
			big_letter_all: false
			small_letter: false
			big_letter: false
			str_modifiers: []
			str_modifier_fields: {
				str: ""
				add_to_all_begin: false
				add_to_all_end: false
				add_to_begin: false
				add_to_end: false
				remove: false
				replacement: ""
				replace: false
			}
		}
	}
	handlers: {
		#
		#	app local handlers
		#
		extra_button_action: (button_config) -> 
			[y1, x1, y2, x2] = state.data.selected_area
			if x1 != x2
				error("для применения выделите область в одном и только в одном столбце")
			else
				rows = state.data.tabs[state.data.current_tab].getData().map((el, this_y) -> state.handlers.extra_button_action_row_proc(el, this_y, button_config, [y1, x1, y2, x2]))
				state.data.tabs[state.data.current_tab].populateFromArray(0,0,rows)
		extra_button_action_row_proc: (row, this_y, button_config, [y1, x1, y2, x2]) ->
			if (this_y > 0) and (y1 <= this_y) and (y2 >= this_y)
				row.map (el, this_x) ->	
					if (x1 == x2) and (this_x == x1)
						if typeof(el) == "string"
							row[button_config.copy_to-1] = inner_handlers.apply_extra_handlers(inner_handlers.strings.split_n_filter(el), button_config)
						else
							error("значение в ячейке "+this_x+", "+this_y+" не является строкой")
			row
		#
		#	some main-purpose handlers
		#
		put_in: (obj, path, value) ->
			if path.length == 1
				obj[path[0]] = value
				obj
			else
				[head, tail...] = path
				obj[head] = state.handlers.put_in(obj[head], tail, value)
				obj
		change_from_view: (path, ev) ->
			if ev? and ev.target? and ev.target.value?
				state.handlers.put_in(state, path, ev.target.value)
		change_from_view_checkbox: (path, ev) ->
			if ev? and ev.target?
				state.handlers.put_in(state, path, ev.target.checked)
		show_block: (some) -> Object.keys(state.opts.visibility).map (key) -> if some == key then state.opts.visibility[key] = "visible" else state.opts.visibility[key] = "hidden"
		switch_sidebar: () -> if state.opts.sidebar == "hidden" then state.opts.sidebar = "visible" else state.opts.sidebar = "hidden"
		add_button: () -> 
			new_button = inner_handlers.obj_value(state.data.extra_buttons_editor)
			new_button.copy_to = parseInt(new_button.copy_to)
			if (typeof(new_button.name) != "string") or (new_button.name == "")
				error("имя кнопки не задано")
			else if not(Number.isInteger(new_button.copy_to)) or (new_button.copy_to <= 0)
				error("номер столбца для вставки должен быть целым числом > 0")
			else
				state.opts.extra_buttons[new_button.name] = new_button
				notice("кнопка \""+new_button.name+"\" добавлена")
		delete_button: () -> 
			btn_name = state.data.extra_buttons_editor.name
			delete state.opts.extra_buttons[btn_name]
			notice("кнопка \""+btn_name+"\" удалена")
		add_button_modifier: () -> 
			state.data.extra_buttons_editor.str_modifiers.push(inner_handlers.obj_value(state.data.extra_buttons_editor.str_modifier_fields))
			notice("модификатор \""+state.data.extra_buttons_editor.str_modifier_fields.str+"\" добавлен к кнопке")
		delete_button_modifier: () -> 
			state.data.extra_buttons_editor.str_modifiers.pop()
			warn("модификатор удалён")
		#
		#	local storage
		#
		reset_opts: () ->
			state.opts = constants.default_opts()
			store.remove("opts")
			warn("Опции сброшены до значений по умолчанию")
		save_opts: () -> 
			store.set("opts", state.opts)
			notice("Опции сохранены")
		load_opts: () -> 
			from_storage = store.get("opts")
			if from_storage
				state.opts = from_storage
			else
				state.handlers.reset_opts()
			state.opts.sidebar = "hidden"
			state.opts.visibility = constants.default_opts().visibility
		#
		#	text local processor
		#
		undo: () -> if (typeof(state.data.current_tab) == "string") then state.data.tabs[state.data.current_tab].undo()
		redo: () -> if (typeof(state.data.current_tab) == "string") then state.data.tabs[state.data.current_tab].redo()
		findreplace: () -> 
			regexp = new RegExp(state.data.find, 'g');
			data = state.data.tabs[state.data.current_tab].getData().map (el, index) -> inner_handlers.findreplace_proc(el, index, state.data.selected_area, regexp, state.data.replace)
			state.data.tabs[state.data.current_tab].populateFromArray(0,0,data)
	}
#
#	static clean inner handlers
#
inner_handlers = {
	findreplace_proc: (el, index, [y1, x1, y2, x2], find, replace) ->
		el.map (elem, elem_index) ->
			if (typeof(elem) == "string") and (index != 0) and (x1 <= elem_index) and (x2 >= elem_index) and (y1 <= index) and (y2 >= index)
				elem.replace(find, replace)
			else
				elem
	obj_value: (obj) -> JSON.parse(JSON.stringify(obj))
	strings: {
		get_upper: (str) ->
			switch str.length
				when 0 then str
				when 1 then str.charAt(0).toUpperCase()
				else str.charAt(0).toUpperCase() + str.substring(1)
		get_low: (str) ->
			switch str.length
				when 0 then str
				when 1 then str.charAt(0).toLowerCase()
				else str.charAt(0).toLowerCase() + str.substring(1)
		split_n_filter: (str) -> str.split(" ").filter((el) -> el != "")
	}
	apply_extra_handlers: (str_lst, button_config) -> 
		if button_config.small_letter_all
			str_lst = str_lst.map((el) -> inner_handlers.strings.get_low(el))
		if button_config.big_letter_all
			str_lst = str_lst.map((el) -> inner_handlers.strings.get_upper(el))
		half_applied = button_config.str_modifiers.reduce(((acc, mod_conf) -> inner_handlers.apply_mod_conf_all(acc, mod_conf)), str_lst ).join(" ")
		if button_config.small_letter
			half_applied = inner_handlers.strings.get_low(half_applied)
		if button_config.big_letter
			half_applied = inner_handlers.strings.get_upper(half_applied)
		button_config.str_modifiers.reduce(((acc, mod_conf) -> inner_handlers.apply_mod_conf_all_str(acc, mod_conf)), half_applied )
	apply_mod_conf_all: (acc, mod_conf) ->
		if mod_conf.add_to_all_begin
			acc = acc.map((el) -> mod_conf.str+el)
		if mod_conf.add_to_all_end
			acc = acc.map((el) -> el+mod_conf.str)
		acc
	apply_mod_conf_all_str: (acc, mod_conf) ->
		if mod_conf.add_to_begin
			acc = mod_conf.str+acc
		if mod_conf.add_to_end
			acc = acc+mod_conf.str
		if mod_conf.remove
			regexp = new RegExp(mod_conf.str, 'g')
			acc = acc.replace(regexp, "")
		if mod_conf.replace
			regexp = new RegExp(mod_conf.str, 'g')
			acc = acc.replace(regexp, mod_conf.replacement)
		acc
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
		render_process("build_main_tab")
render_process = (arg) ->
	React.render(widget(state), domelement) if domelement?
	clearTimeout renderTimeout
	renderTimeout = setTimeout render_process, 500
	if arg == "build_main_tab"
		state.data.tabs.main_tab = new Handsontable(document.getElementById("main_tab"), constants.main_tab_config())
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
bullet = $.bullet("ws://" + location.hostname + ":8083/bullet")
document.addEventListener "DOMContentLoaded", (e) ->
	domelement  = document.getElementsByClassName("container-fluid")[0]
	state.handlers.load_opts()
	render()
	console.log("DOMContentLoaded")
	bullet.onopen = () -> notice("bullet websocket: соединение с сервером установлено")
	bullet.ondisconnect = () -> error("bullet websocket: соединение с сервером потеряно")
	bullet.onclose = () -> warn("bullet websocket: соединение с сервером закрыто")
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
