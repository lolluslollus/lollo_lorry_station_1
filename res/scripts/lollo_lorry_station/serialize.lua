local function serializeRec(o, prefix, writeFn, indentSym)
	if indentSym == nil then indentSym = "\t" end
	local function writeKey(k)
		if type(k) == "string" and string.find(k, "^[_%a][_%w]*$") then
			writeFn(k, " = ")
		else
			writeFn("[")
			serializeRec(k, "", writeFn, indentSym)
			writeFn("] = ")
		end
	end

	if type(o) == "nil" then
		writeFn("nil")
	elseif type(o) == "boolean" then
		writeFn(tostring(o))
	elseif type(o) == "number" then
		writeFn(o)
	elseif type(o) == "string" then
		writeFn(string.format("%q", o))
	elseif type(o) == "table" then
		local metatag = o["__metatag__"]
		if metatag then
			if metatag == 0 then
				writeFn("_(")
				serializeRec(o.val, prefix, writeFn, indentSym)
				writeFn(")")
			else
				error("invalid metatag: " .. metatag)
			end
			return
		end
		
		local oneLine = true
		local listKeys = {}
		local tableKeys = {}
		for k,v in ipairs(o) do
			listKeys[k] = true
		end
		for k,v in pairs(o) do
			if type(v) == "table" then oneLine = false end
			if not listKeys[k] then
				table.insert(tableKeys, k)
				oneLine = false
			end
		end
		table.sort(tableKeys)
		
		if oneLine then
			writeFn("{ ")
			for k,v in ipairs(o) do
				serializeRec(v, "", writeFn, indentSym)
				writeFn(", ")
			end
			for i,k in ipairs(tableKeys) do
				local v = o[k]
				writeKey(k)
				serializeRec(v, "", writeFn, indentSym)
				writeFn(", ")	
			end
			writeFn("}")
		else
			local prefix2 = prefix .. indentSym
			writeFn("{\n")
			for k,v in ipairs(o) do
				writeFn(prefix2)
				serializeRec(v, prefix2, writeFn, indentSym)
				writeFn(",\n")
			end
			for i,k in ipairs(tableKeys) do
				local v = o[k]
				writeFn(prefix2)
				writeKey(k)
				serializeRec(v, prefix2, writeFn, indentSym)
				writeFn(",\n")	
			end
			writeFn(prefix, "}")
		end
	elseif type(o) == "userdata" then
		local mt = getmetatable(o)
		local pr, v = pcall(function() return mt.pairs end)
		local pr2, members = pcall(function() return mt.__members end)
		if mt and pr and v then 
			local prefix2 = prefix .. indentSym
			writeFn("{\n")
			for k,v in pairs(o) do
				writeFn(prefix2)
				writeKey(k)
				serializeRec(v, prefix2, writeFn, indentSym)
				writeFn(",\n")
			end
			writeFn(prefix, "}")
		elseif mt and pr2 and members then
			local prefix2 = prefix .. indentSym
			writeFn("{\n")
			for i = 1, #members do
				local k = members[i]
				local l, v = pcall(function() return o[k] end)
				if l then
					writeFn(prefix2)
					writeKey(k)
					serializeRec(v, prefix2, writeFn, indentSym)
					writeFn(",\n")
				end
			end
			writeFn(prefix, "}")
		else
			writeFn(tostring(o))
		end
	elseif type(o) == "function" then
		writeFn("<function>")
	end
end

local function serialize2(o, writeFn)
	writeFn("function data()", "\n")
	writeFn("return ")
	serializeRec(o, "", writeFn)
	writeFn("\n", "end", "\n")
end

local results = {}

function results.serialize(o)
	serialize2(o, io.write)
	io.flush()
end

function results.serializeStr(o)
	local s = ""

	-- TODO not efficient

	local function write(...)
		local arg = {...}
		for i, v in ipairs(arg) do
			s = s .. v
		end
	end

	serialize2(o, write)

	return s
end

function results.toString(o, sep)
	local s = ""

	local function write(...)
		local arg = {...}
		for i, v in ipairs(arg) do
			s = s .. v
		end
	end
	serializeRec(o, "", write, "  ")

	return s
end

function results.debugPrint(x)
	print(results.toString(x))
end

return results
