module("luci.controller.wizard", package.seeall)

function index()
        entry({"admin", "system", "wizard"}, call("wizard"), "设置向导", 1 ) 
end

function wizard()
	local step         = tonumber(luci.http.formvalue("step") or 1)
    local uci          = require "luci.model.uci".cursor()
    local para         = uci:get_all("wizard","wizard") or {}
    local from         = tonumber( luci.http.formvalue("from") or 0)

   	para.step=step

	if  from == 1 then
		local val=
        { 
		 ctype        = luci.http.formvalue("cbid.wizard.1.ctype"),
	
		 proto        = luci.http.formvalue("cbid.wizard.1.proto"),
		 username     = luci.http.formvalue("cbid.wizard.1.username") ,
		 pw           = luci.http.formvalue("cbid.wizard.1.pw") ,

		 proto2       = luci.http.formvalue("cbid.wizard.1.proto2") ,
		 username2    = luci.http.formvalue("cbid.wizard.1.username2"),
		 pw2          = luci.http.formvalue("cbid.wizard.1.pw2") 
        }

		for k,v in pairs(val) do
			uci:set("wizard","wizard", k, v)
		end

		
		uci:save("wizard")
		uci:commit("wizard")

	elseif from == 2 then
		local flag=luci.http.formvalue("cbid.abc.1.offlinenotify") or 0
		uci:set("wizard","wizard", "offlinenotify", flag)
		uci:save("wizard")
		uci:commit("wizard")

	elseif from == 3 then 
		local val=
        { 
		 SSID         = luci.http.formvalue("cbid.abc.1.SSID"),
		 encrypt      = luci.http.formvalue("cbid.abc.1.encrypt") ,	
		 wifipw       = luci.http.formvalue("cbid.abc.1.pw")
        }

		for k,v in pairs(val) do
			uci:set("wizard","wizard", k, v)
		end

		
		uci:save("wizard")
		uci:commit("wizard")
	end 


    if  step  then	
		luci.template.render("wizard", para )
    end

end

