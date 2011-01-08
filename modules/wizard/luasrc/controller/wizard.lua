--[[
LuCI - Wizard for XRouter
Copyright (c) 2010，XRouter GROUP (http://www.xrouter.co.cc)        
All rights reserved.


Description : Offers a convenient way to setup XRouter 
and put it into use.
 
Author      : Lin Xuan <dinosoft@qq.com>
Created on  : Jan, 2010
--]]

module("luci.controller.wizard", package.seeall)

function index()
	entry({"wizard", "index", "index"}, call("wizard_controller"), "Wizard", 1).ignoreindex = true
end

function wizard_controller()
	local wizard       = require "luci.model.wizard".wizard;
	local session      = require "luci.sauth"
    local from         = tonumber( luci.http.formvalue("from") or 0)
	local step         = tonumber( luci.http.formvalue("step") or 1)

 
	if not session.read("wizardInit")  then 
	    wizard:loadDefaultConfig()
		session.write("wizardInit","true")
	end

	if from > 0 then
		wizard:saveConfig( from )
	end

    if  step==4   then	
		wizard:commitConfig()
		session.kill("wizardInit")
    end
		
    luci.template.render("wizard",  wizard:getConfig(step) )

end

