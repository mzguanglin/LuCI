--[[
Copyright (c) 2010，XRouter, GROUP
All rights reserved.

Name        : controller/lightmultiwan.lua
Description : controller for lightmultiwan

Version     : 1.0
Author      : Xu Guanglin
Created on  : Dec 31, 2010
]]--

module("luci.controller.lightmultiwan", package.seeall)

function index()
	local fs = luci.fs or nixio.fs
	if fs.access("/usr/bin/lightmultiwan.sh") then
		entry({"admin", "network", "lightmultiwan"}, cbi("lightmultiwan"), "Light-Multi-WAN", 30).dependent=false
	else
		entry({"admin", "network", "lightmultiwan"}, template("lightmultiwan-error-no-core"), "Light-Multi-WAN", 30).dependent=false
	end;
end

