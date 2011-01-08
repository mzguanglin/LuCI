--[[
LuCI - Wizard for XRouter
Copyright (c) 2010，XRouter GROUP (http://www.xrouter.co.cc)        
All rights reserved.


Description : Offers a convenient way to setup XRouter 
and put it into use.
 
Author      : Lin Xuan <dinosoft@qq.com>
Created on  : Jan, 2010
--]]

module("luci.model.wizard", package.seeall)

local util = require "luci.util"

--- Wizard Class
wizard=util.class()
--- Config Class
config=util.class()
--- NoSectionNameConfig Class
noSectionNameConfig=util.class()

--- Config Constructor
-- @param config		config file name
-- @param section		section name
function config:__init__( config, section )
	self.config = config
	self.section = section
end


--- Get option value
-- @param option		option name
-- @return 				option value
function config:get( option )
    local    uci = require "luci.model.uci".cursor()
	return uci:get( self.config, self.section , tostring(option) )
end

--- Set option value
-- @param option		option name
-- @param value 		option value
function config:set( option, value )
    local uci  = require "luci.model.uci".cursor()
	uci:set( self.config, self.section, option, value)	
	uci:save( self.config )
	uci:commit( self.config )	
end


--- NoSectionNameConfig Constructor
-- @param config		config file name
-- @param typeName		section type
function noSectionNameConfig:__init__( config, typeName)
	self.config = config
	self.typeName = typeName
end

--- Get option value
-- @param option		option name
-- @return 				option value
function noSectionNameConfig:get( option )
    local    uci = require "luci.model.uci".cursor()
	local    result
    uci:foreach( self.config, self.typeName,
					function (data)
						result=data
					end
				)
	return  (result and result[option] ) or nil
end

--- Set option value
-- @param option		option name
-- @param value 		option value
function noSectionNameConfig:set( option, value )
    local uci  = require "luci.model.uci".cursor()
    uci:foreach( self.config, self.typeName,
					function (data)
						uci:set(self.config, data['.name'], option, value )
					end
				)
	uci:save( self.config )
	uci:commit( self.config )	
end

--- Load default config from config files to session
function wizard:loadDefaultConfig()
	local session = require "luci.sauth"
--------------step 1---------------------
	local wan1_config = config("network", "wan")

	session.write("proto", wan1_config:get("proto") or "8021xdhcp" )
	session.write("username", wan1_config:get("username") or "" )
	session.write("password", wan1_config:get("password") or"" )

	local wan2_config = config( "network", "wan2" )

	session.write("proto2", wan2_config:get("proto") or "8021xdhcp" )
	session.write("username2", wan2_config:get("username") or "" )
	session.write("password2", wan2_config:get("password") or"" )

	if wan2_config:get("proto") and wan2_config:get("proto") ~= "none" then
        session.write("ctype", "double")
	else
		session.write("ctype", "single")
	end

------------- step 2 ------------此部分未完成，预留设置
	session.write("offlinenotify", "true")

------------- step 3 --------------------
	local wifi_config = noSectionNameConfig( "wireless", "wifi-iface" )
	session.write("ssid", wifi_config:get("ssid") or "Wifi" )
	session.write("encryption", wifi_config:get("encryption" ) or "none" )
	session.write("wifipw",  wifi_config:get("password") or "" )

end

--- Get the config corresponding to the specified step from session,
-- @return table value
function wizard:getConfig( step )
	local param = {}
	local session = require "luci.sauth"

	if step == 1 then
		param.proto = session.read("proto") or "8021xdhcp" 
		param.username=session.read("username") or "" 
		param.pw=session.read("password") or ""

		param.proto2=session.read("proto2") or "8021xdhcp" 
		param.username2=session.read("username2") or "" 
		param.pw2=session.read("password2") or "" 
		
		param.ctype=session.read("ctype") or "double"
	elseif step == 2 then
		param.offlinenotify=session.read("offlinenotify")
	elseif step == 3 then
		param.ssid=session.read("ssid")
		param.encryption=session.read("encryption")
		param.wifipw=session.read("wifipw")
	end

	param.step=step
	return param
end

--- Save the config corresponding to the specified step from Web to session
function wizard:saveConfig( step )
		local session = require "luci.sauth"

		if step==1 then
		 session.write( "ctype", luci.http.formvalue("cbid.wizard.1.ctype") or "double")
	
		 session.write( "proto",    luci.http.formvalue("cbid.wizard.1.proto") )
		 session.write( "username", luci.http.formvalue("cbid.wizard.1.username")  )
		 session.write( "password", luci.http.formvalue("cbid.wizard.1.pw") )

		 session.write( "proto2",      luci.http.formvalue("cbid.wizard.1.proto2") )
		 session.write( "username2",   luci.http.formvalue("cbid.wizard.1.username2")  )
		 session.write( "password2",   luci.http.formvalue("cbid.wizard.1.pw2")  )
        
		elseif step==2 then
			 session.write("offlinenotify", luci.http.formvalue("cbid.abc.1.offlinenotify") or 0 )
		elseif step==3 then	
			 session.write( "ssid",      luci.http.formvalue("cbid.abc.1.SSID") )
			 session.write( "encryption",luci.http.formvalue("cbid.abc.1.encrypt")	)
			 session.write( "wifipw",    luci.http.formvalue("cbid.abc.1.pw") )
        end


end

-- Commit all the config, save into the config files
function wizard:commitConfig()
	local session = require "luci.sauth"
------------- step 1 -------------
	local wan1_config = config( "network", "wan" )
	wan1_config:set("proto",     session.read("proto") or "8021xdhcp" )
	wan1_config:set("username",  session.read("username") or "" )
	wan1_config:set("password",  session.read("password") or "" )
	if session.read("proto")=="8021xdhcp" then
		wan1_config:set("defaultroute", 0)
		wan1_config:set("peerdns", 0)
	end

	local wan2_config = config( "network", "wan2" )
	wan2_config:set("proto",  session.read("proto2") or "pppoe" )
	wan2_config:set("username",  session.read("username2") or "" )
	wan2_config:set("password",  session.read("password2") or"" )
	if session.read("proto2")=="8021xdhcp" then
		wan2_config:set("defaultroute", 0)
		wan2_config:set("peerdns", 0)
	end


------------- step 2 ------------- 此部分未完成，预留位置
---set "offlinenotify"

------------- step 3 -------------
	local wifi_config = noSectionNameConfig( "wireless", "wifi-iface" )
	wifi_config:set("ssid", session.read("ssid") or "Wifi" )
	wifi_config:set("encryption", session.read("encryption") )
	if session.read("encryption")~="none" then
      wifi_config:set("password",   session.read("wifipw") or "" ) 
	end
end


