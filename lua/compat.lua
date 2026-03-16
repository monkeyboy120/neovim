local legacy_validate = vim.validate

local type_aliases = {
	b = "boolean",
	c = "callable",
	f = "function",
	n = "number",
	s = "string",
	t = "table",
}

local function is_type(value, expected)
	return type(value) == expected or (expected == "callable" and vim.is_callable(value))
end

local function is_valid(name, value, validator, message, allow_alias)
	if type(validator) == "string" then
		local expected = allow_alias and type_aliases[validator] or validator
		if not expected then
			return string.format("invalid type name: %s", validator)
		end

		if not is_type(value, expected) then
			return string.format("%s: expected %s, got %s", name, message or expected, type(value))
		end

		return
	end

	if vim.is_callable(validator) then
		local ok, extra = validator(value)
		if ok then
			return
		end

		local err = string.format("%s: expected %s, got %s", name, message or "?", tostring(value))
		if extra then
			err = string.format("%s. Info: %s", err, extra)
		end
		return err
	end

	if type(validator) == "table" then
		local expected_types = {}
		for _, candidate in ipairs(validator) do
			local expected = allow_alias and type_aliases[candidate] or candidate
			if not expected then
				return string.format("invalid type name: %s", candidate)
			end

			expected_types[#expected_types + 1] = expected
			if is_type(value, expected) then
				return
			end
		end

		return string.format("%s: expected %s, got %s", name, table.concat(expected_types, "|"), type(value))
	end

	return string.format("invalid validator: %s", tostring(validator))
end

local function validate_spec(specs)
	local report

	for name, spec in pairs(specs) do
		local err
		if type(spec) ~= "table" then
			err = string.format("opt[%s]: expected table, got %s", name, type(spec))
		else
			local value = spec[1]
			local validator = spec[2]
			local msg = type(spec[3]) == "string" and spec[3] or nil
			local optional = spec[3] == true
			if not (optional and value == nil) then
				err = is_valid(name, value, validator, msg, true)
			end
		end

		if err then
			report = report or {}
			report[name] = err
		end
	end

	if not report then
		return
	end

	for _, msg in vim.spairs(report) do
		return msg
	end
end

if vim.islist then
	vim.tbl_islist = vim.islist
end

vim.validate = function(name, value, validator, optional, message)
	if validator ~= nil then
		return legacy_validate(name, value, validator, optional, message)
	end

	if type(name) ~= "table" then
		error("invalid arguments")
	end

	local err = validate_spec(name)
	if err then
		error(err, 2)
	end
end
