--[[
#-------------------------------------------------------------------
# 宝塔Linux面板
#-------------------------------------------------------------------
# Copyright (c) 2015-2099 宝塔软件(http://bt.cn) All rights reserved.
#-------------------------------------------------------------------
# Author: 梁凯强 <1249648969@qq.com>
#-------------------------------------------------------------------

#----------------------
# WAF防火墙 for nginx  body 过滤
#----------------------
]]--
local cpath = "/www/server/btwaf/"
local json = require "cjson"
local jpath = cpath .. "rule/"
local headers = ngx.header
local ngx_match = ngx.re.find
local uri = ngx.unescape_uri(ngx.var.uri)
local error_rule = nil
function read_file(name)
    fbody = read_file_body(jpath .. name .. '.json')
    if fbody == nil then
        return {}
    end
    return json.decode(fbody)
end


local function read_file_body(filename)
   fp = io.open(filename,'r')
   if fp == nil then
        return nil
    end
   fbody = fp:read("*a")
    fp:close()
    if fbody == '' then
        return nil
    end
   return fbody
end

local function write_file(filename,body)
   fp = io.open(filename,'w')
   if fp == nil then
        return nil
    end
   fp:write(body)
   fp:flush()
   fp:close()
   return true
end

local config = json.decode(read_file_body(cpath .. 'config.json'))
local site_config = json.decode(read_file_body(cpath .. 'site.json'))

local function get_server_name()
   local c_name = ngx.var.server_name
   local my_name = ngx.shared.btwaf:get(c_name)
   if my_name then return my_name end
   local tmp = read_file_body(cpath .. '/domains.json')
   if not tmp then return c_name end
   local domains = json.decode(tmp)
   for _,v in ipairs(domains)
   do
      for _,d_name in ipairs(v['domains'])
      do
         if c_name == d_name then
            ngx.shared.btwaf:set(c_name,v['name'],3600)
            ngx.shared.btwaf:set(c_name..'_path',v['path'],3600)
            return v['name']
         end
      end
   end
   return c_name
end


local function get_server_path()
  local c_name = ngx.var.server_name
  local my_name = ngx.shared.btwaf:get(c_name..'_path')
  if my_name then return my_name end
  local tmp = read_file_body(cpath .. '/domains.json')
  if not tmp then return false end
  local domains = json.decode(tmp)
  for _,v in ipairs(domains)
  do
     for _,d_name in ipairs(v['domains'])
     do
        if c_name == d_name then
           ngx.shared.btwaf:set(c_name..'_path',v['path'],3600)
           return v['path']
        end
     end
  end
  return false
end


local function arrlen(arr)
   if not arr then return 0 end
   count = 0
   for _,v in ipairs(arr)
   do
      count = count + 1
   end
   return count
end

local function get_zhizu_json(name)
	data = read_file_body(cpath .. name ..'.json')
	if not data then 
		data={}
	end 
	return data
end

local function zhizu_chekc(data,path)
	for _,k in ipairs(json.decode(data))
	do
		if tostring(k) == tostring(path) then 
			return true
		end
	end
end

local function save_data_on(name,data)
	local extime=18000
	data=json.encode(data)
	ngx.shared.btwaf:set(cpath .. name,data,extime)
	if not ngx.shared.btwaf:get(cpath .. name .. '_lock') then
		ngx.shared.btwaf:set(cpath .. name .. '_lock',1,1) 
		write_file(cpath .. name .. '.json',data)
	end
end


local function  host_pachong(path)
  if not path then return 33 end
  pachong=get_zhizu_json('webshell')
  if zhizu_chekc(pachong,path) then return 22 end
  pachong=json.decode(pachong)
  table.insert(pachong,path)
  save_data_on('webshell',pachong)
end

local function  host_pachong2(path)
   if not path then return 33 end
   pachong=get_zhizu_json('webshell_url')
   if zhizu_chekc(pachong,path) then return 22 end
   pachong=json.decode(pachong)
   table.insert(pachong,path)
   save_data_on('webshell_url',pachong)
 end


local function get_body_character_string()
   local char_string=config['body_character_string']
   if not char_string then return false end
   if arrlen(char_string) ==0 then return false end
   if arrlen(char_string) >=1 then return char_string end
end

local function get_site_character_string(site_config)
   if not site_config then return false end
   local char_string=site_config['body_character_string']
   if not char_string then return false end
   if arrlen(char_string) ==0 then return false end
   if arrlen(char_string) >=1 then return char_string end
end

local function return_message(status,msg)
   ngx.header.content_type = "application/json;"
   ngx.status = status
   ngx.log(ngx.ERR, "error: ", json.encode(msg))
end

local function cc_increase_static()
  local keys =  {"css","js","png","gif","ico","jpg","jpeg","bmp","flush","swf","pdf","rar","zip","doc","docx","xlsx"}
  for _,k in ipairs(keys)
  do
    local aa="/?.*\\."..k.."$"
    if ngx_match(uri,aa,"isjo") then
      return true
    end
  end
  return false
end

local function check_type()
  if headers["Content-Type"] == nil then return false end
  if string.find(headers["Content-Type"], "text/html") ~= nil or  string.find(headers["Content-Type"], "application/json") ~= nil then
    return true
  end
  return false
end

function body_btwaf()
   if not check_type() then return false end 
   if cc_increase_static() then return false end
   server_name2=get_server_name()
   server_name = string.gsub(server_name2,'_','.')
   
   if not config['open'] or not is_site_config('open') then return false end
   local chunk, eof = ngx.arg[1], ngx.arg[2]
   local buffered = ngx.ctx.buffered
   if not buffered then
        buffered = {}
        ngx.ctx.buffered = buffered
   end
   if chunk ~= "" then
       buffered[#buffered + 1] = chunk
       ngx.arg[1] = nil
   end
  if eof then
      local whole = table.concat(buffered)
      ngx.ctx.buffered = nil
     --  path_data=get_server_path()
     --  if path_data and config['webshell_open'] then
     --    if string.find(ngx.unescape_uri(whole),path_data) then
     --    	if uri=='/index.php' or uri=='/index.html' or uri=='/' then
     --    		print(1)
     --    	else
     --    		if ngx.re.match(uri,'php$') then
		   --          if string.find(ngx.unescape_uri(whole),path_data..'/.user.ini') or string.find(ngx.unescape_uri(whole),path_data..'/.htaccess')  or string.find(ngx.unescape_uri(whole),path_data..'/.well%-known') then
		   --          		host_pachong(path_data..uri)
		   --          end
		   --      end
     --    	end
     --    end
     --    if uri=='/index.php' or uri=='/index.html' or uri=='/' then
     --    		print(1)
     --    else
     --    	if ngx.re.match(uri,'php$') then
		   --      if string.find(ngx.unescape_uri(whole),'^(.+%s+%d%d%d%d?-%d%d?-%d%d?%s+%d%d?:%d%d?:%d%d?%s+%d+%s+%d%d%d%d?)') then
		   --        host_pachong(path_data..uri)
		   --      end
		   --  end
	    -- end
     --  end
      local get_body=get_body_character_string()
      if get_body then
          for __,v in pairs(get_body)
          do 
              for k2,v2 in pairs(v)
                  do
                      if type(k2)=='string' then
                              whole,c1 = string.gsub(whole,k2,v2)
                              if c1 > 0 then ngx.header.content_length = nil end
                      end
                 end
           end
      end
      if site_config then 
        local site_body=get_site_character_string(site_config[server_name])
        if site_body then
            for __,v in pairs(site_body)
            do 
                   for k2,v2 in pairs(v)
                    do
                        if type(k2)=='string' then
                            ngx.header.content_length = nil
                            whole,c2 = string.gsub(whole,k2,v2)
                            if c2 > 0 then ngx.header.content_length = nil end
                        end
                    end
            end
        end
    end
      ngx.arg[1] = whole
  end

end

body_btwaf()