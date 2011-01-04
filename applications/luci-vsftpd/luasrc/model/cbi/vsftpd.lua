--[[
Copyright (c) 2011，XRouter, GROUP
All rights reserved.

Name        : model/cbi/vsftpd.lua
Description : cbi model for luci-app-vsftpd

Version     : 1.0
Author      : Xu Guanglin
Created on  : Jan 3, 2011
]]--

require("luci.tools.webadmin")
local VsftpdSettingAdapter = require("luci.model.VsftpdSettingAdapter")

m = Map("vsftpd", "Easy-FTP",
	translate("Easy FTP is a easy controller of <b>vsfptd</b> which is a famous ftp server. <p>You should be aware that there are two kinds of users:</p><p>1. root</p><p>2. anonymous</p><p><b>root</b> is the super user but you should care <b>anonymous</b> priority settings.</p>"))

m.on_after_commit = function(self)
	local adapter = VsftpdSettingAdapter("/etc/vsftpd.conf");
	adapter:writeToVsftpdConfig()
end

s = m:section(NamedSection, "config", "vsftpd", "")
s.addremove = true
e = s:option(Flag, "enabled", translate("Automatic Run"), "you must reboot to activate")
e.rmempty = false

function e.write(self, section, value)
        local cmd = (value == "1") and "enable" or "disable"
        if value ~= "1" then                                                    
                os.execute("rm /etc/rc.d/S90vsftpd")                            
        else                                                                    
                os.execute("ln -s /etc/init.d/vsftpd /etc/rc.d/S90vsftpd")      
        end    
end

function e.cfgvalue(self, section)
	local fs = luci.fs or nixio.fs
	if fs.access("/etc/rc.d/S90vsftpd") then
		return "1"
	else
		return "0"	
	end
end

e = s:option(Value, "homedir", translate("Home Directory"), "The root directory of ftp server")
e.rmempty = false
e = s:option(Value, "welcomeword", translate("Welcome Word"))
e.rmempty = false

s = m:section(NamedSection, "security", "vsftpd", "Anonymous Securiy Options")
s.addremove = true
e = s:option(Flag, "downloadable", translate("Permit Anonymous Downloading"))
e.rmempty = false
e = s:option(Flag, "uploadable", translate("Permit Anonymous Uploading"))
e.rmempty = false

s = m:section(NamedSection, "performance", "vsftpd", "Performance Options")
s.addremove = true
e = s:option(Value, "maxspeed", translate("Max Upload/Download Speed"), "Byte/S")
e.rmempty = false
e = s:option(Value, "maxclient", translate("Max Client Number"))
e.rmempty = false

return m
