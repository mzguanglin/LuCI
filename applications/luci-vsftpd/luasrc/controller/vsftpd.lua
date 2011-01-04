--[[
Copyright (c) 2011，XRouter, GROUP
All rights reserved.

Name        : controller/vsftpd.lua
Description : controller for luci-app-vsftpd

Version     : 1.0
Author      : Xu Guanglin
Created on  : Jan 3, 2011
]]--

module("luci.controller.vsftpd", package.seeall)

function index()
	local fs = luci.fs or nixio.fs
	if fs.access("/etc/init.d/vsftpd") then
		entry({"admin", "services", "vsftpd"}, cbi("vsftpd"), "Easy FTP", 30).dependent=false
	else
		entry({"admin", "services", "vsftpd"}, template("vsftpd-error-no-core"), "Easy FTP", 30).dependent=false
	end;
end

