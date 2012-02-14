-- assemblyinfoc (The Assembly Information Compiler)
-- arg[1] ; the assembly information source file
-- arg[2] ; the default version string
-- arg[3] ; the generate assembly information metadata c/c++ source files's output directory
-- arg[4] ; the assembly name
-- compile the assembly information source file to binary type,and generate metadata c/c++ source files

title = 
[==[
/**
 * this file is auto generate by assemblyinfoc,do not modify it
 * @file     assembly.h
 * @brief    Copyright (C) 2012  yayanyang All Rights Reserved 
 * @author   yayanyang
 * @version  1.0.0.0  
 * @date     2012/01/14
 */
]==]

-- the log function
function Log(message)
   print("[assembly info compiler] " .. message)
end

-- @description replace originVersion string's "*" to auto generate vesion number
-- function name :GetRealVersion(orginVersion)
-- @args originVersion,the origin version string
-- @return the realversion string
function GetRealVersion(originVersion)

   print("parse version string: " .. originVersion)

   local version = {}

   version[0],version[1],version[2],version[3] = originVersion:match("(%d+)%.(%d+)%.(%d+)%.(%d+)$")

   if(nil == version[0]) then
      version[0],version[1],version[2],version[3] = originVersion:match("(%d+)%.(%d+)%.(%d+)%.%*$")
      if(nil == version[0]) then
	 version[0],version[1],version[2],version[3] = originVersion:match("(%d+)%.(%d+)%.%*$")
      end
   end
   
   if(nil == version[0]) then assert(false,"invalid version string :" .. originVersion) end

   version[0] = assert(tonumber(version[0]),"invalid version string :" .. originVersion)

   version[1] = assert(tonumber(version[1]),"invalid version string :" .. originVersion)

   t = os.date("*t",os.difftime(os.time(),os.time{year=2010, month=1, day=1}))

   if(nil == version[2]) then
      version[2] = t.yday
   else
      version[2] = assert(tonumber(version[2]),"invalid version string :" .. originVersion)
   end

   if(nil == version[3]) then
      version[3] = math.floor((t.hour * 3600 + t.min * 60 + t.sec) / 2)
   else
      version[3] = assert(tonumber(version[3]),"invalid version string :" .. originVersion)
   end

   print("real version string: " .. version[0] .. "." .. version[1] .. "." .. version[2] .. "." .. version[3])

   return version

end

-- load and run the assembly information source lua file
Log("load assembly information define file :" .. arg[1])
dofile(arg[1])
Log("load assembly information define file :" .. arg[1] .. " -- success")
assert(assembly ~= nil,"assembly information is empty :" .. arg[1])
--assert(assembly.name ~= nil,"assembly name must be set :" .. arg[1])
assert(assembly.guid ~= nil,"assembly guid must be set :" .. arg[1])

-- get the prefix string
prefix = string.upper(string.gsub(arg[4],"[%-]","_"))
prefix = string.gsub(prefix , "%+","X")
-- get the version
version = GetRealVersion(arg[2])
-- get the guid string
guid = assembly.guid
-- now generate the assembly.h assembly.cpp files

assembly_h = arg[3] .. "/assembly.h"

assembly_cpp = arg[3] .. "/assembly.cpp"

errorcode_h = arg[3] .. "/errorcode.h"

headFile = assert(io.open(assembly_h,"w+"),"can't open file to write :" .. assembly_h)

sourceFile = assert(io.open(assembly_cpp,"w+"),"can't open file to write :" .. assembly_cpp)

errorFile = assert(io.open(errorcode_h,"w+"),"can't open file to write :" .. errorcode_h)

headFile:write(title)

headFile:write("#ifndef " .. prefix .. "_ASSEMBLY_H\n")
headFile:write("#define " .. prefix .. "_ASSEMBLY_H\n")
errorFile:write("#ifndef " .. prefix .. "_ERRORCODE_H\n")
errorFile:write("#define " .. prefix .. "_ERRORCODE_H\n")

headFile:write("#include \"configure.h\"\n")
headFile:write("#include <lemon/sys/abi.h>\n\n")
errorFile:write("#include \"configure.h\"\n")
errorFile:write("#include <lemon/sys/abi.h>\n\n")
sourceFile:write("#include \"assembly.h\"\n\n")
sourceFile:write("#include \"errorcode.h\"\n\n")

headFile:write(prefix .. "_API const LemonUuid " .. prefix .. "_GUID;\n\n")
headFile:write(prefix .. "_API const LemonVersion " .. prefix .. "_VERSION;\n\n")
sourceFile:write("const LemonUuid " .. prefix .. "_GUID = " .. guid .. ";\n\n")
sourceFile:write("const LemonVersion " .. prefix .. "_VERSION = {" .. version[0] .. "," .. version[1] .. "," .. version[2] .. "," .. version[3] .. "};\n\n")

index = 0

if(nil ~= assembly.errorcode) then

   for k,v in pairs(assembly.errorcode) do 
      errorFile:write(prefix .. "_API const LemonError " .. prefix .. "_" .. k .. ";\n\n")
      sourceFile:write("const LemonError " .. prefix .. "_" .. k .. " = {&" .. prefix .. "_GUID," .. index .. "};\n\n")
      index = index + 1
   end

end

headFile:write("#endif //" .. string.upper(prefix) .. "_ASSEMBLY_H\n")
errorFile:write("#endif //" .. string.upper(prefix) .. "_ERRORCODE_H\n")


headFile:close()
sourceFile:close()
errorFile:close()


