--[[
Copyright (c) 2011，XRouter GROUP (http://www.xrouter.co.cc)        
All rights reserved.

Name        : VsftpdSettingAdapter.lua
Description : An adapter between uci config and vsftpd config.
 
Version     : 1.0
Author      : Xu Guanglin
Created on  : Jan 3, 2011
--]]

module("luci.model.VsftpdSettingAdapter", package.seeall)

local util = require "luci.util"
local uci = require "luci.model.uci".cursor();

--- VsftpdSettingAdapter Class
-- an adapter between uci config and vsftpd config.
-- @class table
-- @name VsftpdSettingAdapter
-- @field vsftpConfigPath 
-- @field uciConfigFile 
-- @field homedir 
-- @field welcomeword 
-- @field downloadable 
-- @field uploadable 
-- @field maxspeed 
-- @field maxclient 
VsftpdSettingAdapter = util.class();
VsftpdSettingAdapter.vsftpConfigPath = "";
VsftpdSettingAdapter.uciConfigFile = "vsftpd";
VsftpdSettingAdapter.homedir = ""
VsftpdSettingAdapter.welcomeword = ""
VsftpdSettingAdapter.downloadable = ""
VsftpdSettingAdapter.uploadable = ""
VsftpdSettingAdapter.maxspeed = ""
VsftpdSettingAdapter.maxclient = ""

--- VsftpdSettingAdapter Constructor
-- @param balance		Initial balance value
-- @return				Instance object
function VsftpdSettingAdapter:__init__(vsftpConfigPath)
	self.vsftpConfigPath = vsftpConfigPath;
end

--- Write configurations to vsftpd such as /etc/vsftpd.conf
function VsftpdSettingAdapter:writeToVsftpdConfig()
	self:loadOptionsFromUciConfigFile();
	self:filterSpecialCharacters();
	os.execute(string.format("sed -i -e '/anon_root/s/=.*/=%s/g' -e '/local_root/s/=.*/=%s/g' -e '/ftpd_banner/s/=.*/=%s/g' -e '/anonymous_enable/s/=.*/=%s/g' -e '/anon_upload_enable/s/=.*/=%s/g' -e '/anon_max_rate/s/=.*/=%s/g' -e '/local_max_rate/s/=.*/=%s/g' -e '/max_clients/s/=.*/=%s/g' %s", self.homedir, self.homedir, self.welcomeword, self.downloadable, self.uploadable, self.maxspeed, self.maxspeed, self.maxclient, self.vsftpConfigPath));
end

--- Load options from uci config file such as /etc/config/vsftpd
function VsftpdSettingAdapter:loadOptionsFromUciConfigFile()
	self.homedir = uci:get(self.uciConfigFile, "config", "homedir");
	self.welcomeword = uci:get(self.uciConfigFile, "config", "welcomeword");
	self.downloadable = uci:get(self.uciConfigFile, "security", "downloadable");
	self.uploadable = uci:get(self.uciConfigFile, "security", "uploadable");
	self.maxspeed = uci:get(self.uciConfigFile, "performance", "maxspeed");
	self.maxclient = uci:get(self.uciConfigFile, "performance", "maxclient");
end

--- Filter all special characters
function VsftpdSettingAdapter:filterSpecialCharacters()
	self.homedir = self:filterSpecialCharacter(self.homedir);
	self.welcomeword = self:filterSpecialCharacter(self.welcomeword);
	self.downloadable = self:convertBoolean(self.downloadable);
	self.uploadable = self:convertBoolean(self.uploadable);
	self.maxspeed = self:filterSpecialCharacter(self.maxspeed);
	self.maxclient = self:filterSpecialCharacter(self.maxclient);
end

--- Filter some special character which can't be operated by shell script
-- @param ins		Input value
-- @return		New value
function VsftpdSettingAdapter:filterSpecialCharacter(ins)
	return string.gsub(ins, "/", "\\/")
end

--- Convert boolean value from 0, 1 to yes, no
-- @param ins		Input value
-- @return		New value
function VsftpdSettingAdapter:convertBoolean(ins)
	return (ins == "1") and "YES" or "NO";
end

return VsftpdSettingAdapter
