local cpath = "/www/server/btwaf/"
local json = require "cjson"
local uri = ngx.unescape_uri(ngx.var.uri)
local ngx_match = ngx.re.find

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

local config = json.decode(read_file_body(cpath .. 'config.json'))



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


function header_btwaf()
    if cc_increase_static() then return false end
    if ngx.status==200 then 
        ngx.exit(ngx.OK)
    end
    if config['static_code_config'] then 
        if  config['static_code_config'][tostring(ngx.status)] ~=nil then 
            code=config['static_code_config'][tostring(ngx.status)]
            ngx.exit(tonumber(code))
        end
    end 

   
end
header_btwaf()