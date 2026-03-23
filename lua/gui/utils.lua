--
-- General GUI utility functions.
--
-- codename Naia - Project Ethea phase 1 campaigns shared library
-- Copyright (C) 2025 - 2026 by Iris Morelle <iris@irydacea.me>
--
-- See COPYING for usage terms.
--

local UI_TEXT_HIGHLIGHT_BG_COLOR = "#153550" -- Same as [text_box] selection bg in 1.18

-- Special characters that need to be escaped when used in a Pango markup
-- context (cf. font::escape_text() in the game engine).
local PANGO_SPECIAL_CHARS = {
	["&"]  = "&amp;",
	["<"]  = "lt;",
	[">"]  = "gt;",
	["'"]  = "&apos;",
	['"']  = "&quot;",
}

local function unicode_array(s)
	-- FIXME: Lua's UTF-8 support is advertised as very basic, so we aren't
	-- getting normalized strings here. This might be a problem for other
	-- languages. Waiting for the day someone files a bug report to see if I
	-- can convince the Wesnoth devs to give us more tools to manipulate
	-- Unicode strings in Lua.
	return table.pack(utf8.codepoint(s, 1, -1))
end

local function unicode_tolower(char)
	-- FIXME: Lua's Unicode support is so basic that this probably won't work
	-- correctly for anything other than ASCII characters.
	return utf8.codepoint(utf8.char(char):lower())
end

local function format_highlight(span)
	return ("<span bgcolor='%s'>%s</span>"):format(UI_TEXT_HIGHLIGHT_BG_COLOR, span)
end

local function escape_text(text)
	for original, sub in pairs(PANGO_SPECIAL_CHARS) do
		text = text:gsub(original, sub)
	end
	return text
end

--
-- Helper to make markup text fancier by converting certain tags to use color
-- formatting.
--
-- NOTE:
-- In order to preserve semantics, if the input is nil then the output should
-- be nil as well.
--
function transform_markup(markup)
	if markup then
		return tostring(markup):gsub(
			"<b>([^<]+)</b>",
			"<span color='#baac7d'>%0</span>")
	else
		return nil
	end
end

local U_HIGHLIGHT_PRE  = unicode_array("<span color='" .. UI_TEXT_HIGHLIGHT_BG_COLOR .. "'>")
local U_HIGHLIGHT_POST = unicode_array("</span>")

--
-- Helper to add a highlighted background to text that matches the search
-- terms. (Currently this is a full text search, albeit case-insensitive.)
--
function highlight_marked_up_text(text, search_for)
	local function err(fmt, ...)
		wprintf(W_ERR, "highlight_marked_up_text(): " .. fmt, ...)
		return text
	end

	-- Get the trivial cases out of the way first

	if type(text) ~= "string" then
		return err("text is not a string")
	end

	if type(search_for) ~= "string" then
		return err("query is not a string")
	end

	if text == "" or search_for == "" or #text < #search_for then
		return text
	end

	-- Character counts prior to sanitization; we'll redo this aft4erwards
	local u_text_len,   text_bad_pos   = utf8.len(text)
	local u_search_len, search_bad_pos = utf8.len(search_for)

	if not u_text_len then
		return err("text contains invalid utf-8 at byte %d", text_bad_pos)
	end
	if not u_search_len then
		return err("query contains invalid utf-8 at byte %d", search_bad_pos)
	end

	-- We can't apply lower() to text because we need the original case for
	-- building the output, but we can apply lower() to the query
	search_for = escape_text(search_for:lower())

	local u_text   = unicode_array(text)
	local u_search = unicode_array(search_for)

	-- If character counts are identical perhaps strings are the same?
	if u_text.n == u_search.n then
		-- FIXME: probably not Unicode-aware
		if text:lower() == search_for:lower() then
			return format_highlight(text)
		else
			return text
		end
	end

	-- Proceed with the full Unicode comparison

	local query_pos   = 1

	local tokens = {
		cur_start     = 1,
		cur_pos       = 1,
		in_element    = "none",
	}

	tokens.push = function(highlight)
		if tokens.cur_start <= 0 or
		   tokens.cur_pos <= 0 or
		   tokens.cur_pos < tokens.cur_start
		then
			return
		end
		assert(tokens.cur_start <= u_text.n)
		assert(tokens.cur_pos   <= u_text.n)
		local utf8_str = utf8.char(table.unpack(u_text, tokens.cur_start, tokens.cur_pos))
		if highlight then
			utf8_str = format_highlight(utf8_str)
		end
		table.insert(tokens, utf8_str)
		tokens._advance_start()
	end

	tokens.push_highlighted = function(highlight_start)
		local pos = tokens.cur_pos
		-- Temporary rollback
		tokens.cur_pos = highlight_start - 1
		tokens.push()
		tokens.cur_start = highlight_start
		tokens.cur_pos = pos
		tokens.push(true)
		tokens._advance_start()
	end

	tokens.in_entity = function() return tokens.in_element == "ent"  end
	tokens.in_tag    = function() return tokens.in_element == "tag"  end
	tokens.in_plain  = function() return tokens.in_element == "none" end

	tokens._advance_start = function() tokens.cur_start = math.min(tokens.cur_pos + 1, u_text.n + 1) end

	tokens._start_element = function(el_type)
		assert(tokens.in_plain())
		tokens.cur_pos = tokens.cur_pos - 1
		tokens.push() -- Push whatever precedes this element
		tokens.cur_pos = tokens.cur_pos + 1
		tokens.in_element = el_type
		tokens.cur_start = tokens.cur_pos
	end

	tokens._end_element = function(el_type)
		assert(tokens.in_element == el_type)
		assert(tokens.cur_start > 0)
		tokens.push()
		tokens.in_element = "none"
		tokens._advance_start()
	end

	tokens.start_entity = function() tokens._start_element("ent") end
	tokens.end_entity   = function() tokens._end_element("ent")   end
	tokens.start_tag    = function() tokens._start_element("tag") end
	tokens.end_tag      = function() tokens._end_element("tag")   end

	for pos = 1, u_text.n do
		local char = u_text[pos]
		tokens.cur_pos = pos

		-- Skip characters
		if tokens.in_tag() and char ~= string.byte('>') then
			goto continue
		end

		-- Tags
		if tokens.in_plain() and char == string.byte('<') then
			-- Reset match because we went past a token boundary. Technically
			-- we could just not do this so we can highlight things such as
			-- "the <b>Demon Lord</b>" (for a query like "the demon lord"), BUT
			-- we actually can't because we'd wind up with malformed Pango.
			query_pos = 1
			tokens.start_tag()
			goto continue
		elseif tokens.in_tag() and char == string.byte('>') then
			query_pos = 1
			tokens.end_tag()
			goto continue
		end

		-- NOTE: Entities may crop up in the query value, so we treat them as
		-- plain text for the purpose of tokenization

		-- Check query match
		local remaining_text_chars  = u_text.n - (pos - 1)
		local remaining_query_chars = u_search.n - (query_pos - 1)

		if remaining_query_chars <= remaining_text_chars then
			if unicode_tolower(char) == unicode_tolower(u_search[query_pos]) then
				if query_pos == u_search.n then
					tokens.push_highlighted(pos - u_search.n + 1)
				else
					-- Continue match
					query_pos = query_pos + 1
					goto continue
				end
			end
			-- No match or we just pushed one, reset match state
			query_pos = 1
		end
		::continue::
	end

	-- Trailing plain element that didn't match query
	if tokens.in_plain() and tokens.cur_start <= u_text.n then
		tokens.push()
	end

	if tokens.in_tag() then
		err("was in tag at the end, bad input or logic error?") -- continue anyway
	end

	return stringx.join(tokens, '')
end
