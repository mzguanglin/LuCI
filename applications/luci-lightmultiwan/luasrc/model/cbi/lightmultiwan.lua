--[[
Copyright (c) 2010，XRouter, GROUP
All rights reserved.

Name        : model/cbi/lightmultiwan.lua
Description : cbi model for lightmultiwan

Version     : 1.0
Author      : Xu Guanglin
Created on  : Dec 31, 2010
]]--

require("luci.tools.webadmin")

m = Map("lightmultiwan", "Light-Multi-WAN",
	translate("Light-Multi-WAN is a <b>light version</b> of Multi-WAN application. It gets rid of daemon and iptables filters which require a lot of router resources. <p>Light-Multi-WAN allows for the use of multiple uplinks for load balancing and failover.</p>"))

s = m:section(NamedSection, "config", "lightmultiwan", "")
e = s:option(Flag, "enabled", translate("Enable"), "must reboot to switch")
e.rmempty = false

s = m:section(TypedSection, "interface", translate("Load Balancer Weight"),
	translate("Adjust WAN interfaces load balancer distribution"))
s.addremove = true

weight = s:option(ListValue, "weight", translate("Load Balancer Weight"))
weight:value("10", "10")
weight:value("9", "9")
weight:value("8", "8")
weight:value("7", "7")
weight:value("6", "6")
weight:value("5", "5")
weight:value("4", "4")
weight:value("3", "3")
weight:value("2", "2")
weight:value("1", "1")
weight:value("disable", translate("None"))
weight.default = "10"
weight.optional = false
weight.rmempty = false

s = m:section(NamedSection, "config", "", translate("Default Route"))
s.addremove = true

default_route = s:option(ListValue, "default_route", translate("Interfaces"))
luci.tools.webadmin.cbi_add_networks(default_route)
default_route:value("balancer", translate("Load Balancer"))
default_route.optional = false
default_route.rmempty = false

s = m:section(TypedSection, "mwanfw", translate("Multi-WAN Traffic Rules"),
	translate("Configure rules for directing outbound traffic through specified WAN Uplinks."))
s.template = "cbi/tblsection"
s.anonymous = true
s.addremove = true

src = s:option(Value, "src", translate("Source Address"))
src.rmempty = true
src:value("", translate("all"))
luci.tools.webadmin.cbi_add_knownips(src)

dst = s:option(Value, "dst", translate("Destination Address"))
dst.rmempty = true
dst:value("", translate("all"))
luci.tools.webadmin.cbi_add_knownips(dst)

wanrule = s:option(ListValue, "wanrule", translate("WAN Uplink"))
luci.tools.webadmin.cbi_add_networks(wanrule)
wanrule:value("balancer", translate("Load Balancer"))
wanrule.optional = false
wanrule.rmempty = false

return m
