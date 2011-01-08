--[[
LuCI - Lua Configuration Interface

Copyright 2008 Steven Barth <steven@midlink.org>
Copyright 2008 Jo-Philipp Wich <xm@leipzig.freifunk.net>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

module("luci.controller.wizard.index", package.seeall)

function index()
	luci.i18n.loadc("base")
	local i18n = luci.i18n.translate

	local root = node()
	root.target = alias("wizard")
	root.index = true
	
	entry({"wizard", "about"}, template("wizard/about"))
	
	local page   = entry({"wizard"}, alias("wizard", "index"), i18n("Wizard"), 10)
	page.sysauth = "root"
	page.sysauth_authenticator = "htmlauth"
	page.index = true
	
	entry({"wizard", "index"}, alias("wizard", "index", "index"), i18n("Network Setting Wizard"), 10).index = true
	entry({"wizard", "index", "logout"}, call("action_logout"), i18n("Logout"))
end

function action_logout()
	local dsp = require "luci.dispatcher"
	local sauth = require "luci.sauth"
	if dsp.context.authsession then
		sauth.kill(dsp.context.authsession)
		dsp.context.urltoken.stok = nil
	end

	luci.http.header("Set-Cookie", "sysauth=; path=" .. dsp.build_url())
	luci.http.redirect(luci.dispatcher.build_url())
end
