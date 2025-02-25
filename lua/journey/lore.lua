--
-- Wesnoth Journey Log module (back-end)
--
-- codename Naia - Project Ethea phase 1 campaigns shared library
-- Copyright (C) 2025 by Iris Morelle <iris@irydacea.me>
--
-- See COPYING for usage terms.
--

-- CURRENT TODO:
--
-- * public API for character and world entries that can be used by the
--   gui to retrieve information easily, including entry ids

-- Raw collection of world encyclopedia entries.
local world_info = {}

-- Raw collection of character profiles.
local chara_profiles = {}

-- Index of character ids in order to preserve the original definition order
-- for UI display purposes.
local chara_index = {}

-- Public UI-ready cache containing the built profiles and encyclopedia entries
-- in order to avoid unnecessary data grinding whenever the lore UI is
-- displayed. This version has been built after processing entry unlock
-- triggers such as characters seen and milestones unlocked.
local lore_cache = {
	profiles = {},
	world = {},
}

-- Character attributes that should be overridden by additional_info.
local chara_override_attributes = {
	"name",
	"additional_titles",
	"affiliation",
	"race",
	"status",
	"gender",
	"portrait",
}

-- Character attributes that should be extended by additional_info.
local chara_extend_attributes = {
	"description",
}

-- Prebaked merge to make things easier later.
-- (NOTE: id is not included here or in the others because it requires special
-- treatment to avoid shenanigans)
local chara_all_attributes = array_join(chara_extend_attributes, chara_override_attributes)

-- NOTE:
-- Currently we internally use storage that replicates the [character_profile]
-- tag's structure. This is subject to change.
local function clone_chara_attributes(source, include_milestone_info)
	local dest = {}
	local attrs = chara_all_attributes
	if include_milestone_info == nil or include_milestone_info then
		attrs = array_join(chara_all_attributes, { "requires_milestone" })
	end

	for _, attr in ipairs(attrs) do
		dest[attr] = source[attr]
	end

	return dest
end

local function merge_chara_additional_info(dest, additional_info)
	-- NOTE:
	-- * Attributes that are missing in additional_info are ignored.
	-- * Attributes missing in dest but not in additional_info come into
	--   existence in the former.
	for _, attr in ipairs(chara_override_attributes) do
		if additional_info[attr] ~= nil then
			dest[attr] = additional_info[attr]
		end
	end
	for _, attr in ipairs(chara_extend_attributes) do
		if additional_info[attr] ~= nil then
			dest[attr] = ("%s\n\n%s"):format(dest[attr], additional_info[attr])
		end
	end
end

--
-- Processes character profile information from WML.
--
-- The specified WML argument must contain an array of [character_profile]
-- tags to process.
--
function journeylog.register_character_profiles(cfg)
	jprintf(W_INFO, "registering character profiles (SPOILERS)")
	windent()

	if not cfg then
		wml.error("journeylog.register_character_profiles(): WML must not be nil")
	end

	for profile in wml.child_range(cfg, "character_profile") do
		if profile.id == nil then
			wml.error("journeylog.register_character_profiles(): Missing [character_profile] id")
		end

		if chara_profiles[profile.id] ~= nil then
			jprintf(W_WARN, "overwriting duplicate character bio: %s")
		end

		jprintf(W_INFO, "registering character bio: %s", profile.id)

		local additional_info = {}

		for extra in wml.child_range(profile, "additional_info") do
			if extra.requires_milestone == nil then
				wml.error("journeylog.register_character_profiles(): Missing [additional_info] requires_milestone")
			end

			table.insert(additional_info, clone_chara_attributes(extra))
		end

		if chara_profiles[profile.id] == nil then
			table.insert(chara_index, profile.id)
		end

		chara_profiles[profile.id] = table_merge(clone_chara_attributes(profile), {
			id = profile.id,
			additional_info = additional_info,
		})
	end

	wunindent()
	jprintf(W_INFO, "finished registering character profiles")

	journeylog.rebuild_lore()
end

--
-- Refreshes the internal lore library cache.
--
function journeylog.rebuild_lore()
	jprintf(W_INFO, "lore rebuild has begun (SPOILERS)")
	windent()

	local profile_cache = {}
	local world_cache = {}

	for _, id in ipairs(chara_index) do
		local profile = chara_profiles[id]

		if profile == nil then
			wml.error("journeylog.rebuild_lore(): character index corrupted")
		end

		jprintf(W_INFO, "rebuilding character profile for %s", id)

		if journeylog.has_milestone(profile.requires_milestone) then
			local cached_profile = clone_chara_attributes(profile, false)

			cached_profile.id = id

			-- Process additional information; everything replaces existing
			-- information except for the description, which gets extended
			-- with additional text instead.
			if profile.additional_info ~= nil and #profile.additional_info > 0 then
				for _, extra in ipairs(profile.additional_info) do
					if journeylog.has_milestone(extra.requires_milestone) then
						merge_chara_additional_info(cached_profile, extra)
					end
				end
			end

			table.insert(profile_cache, cached_profile)
		end
	end

	wunindent()
	jprintf(W_INFO, "lore rebuild finished")

	-- Update table references
	lore_cache.profiles = profile_cache
	lore_cache.world = world_cache
end

--
-- Retrieves character profiles for UI display.
--
-- Profile entries are structured thus:
--
--   id                      The character entry's internal id.
--   name                    Name of the character.
--   additional_titles       Additional titles the character has.
--   affiliation             Affiliations (to groups, orgs, etc.) the character has.
--   race                    Race/species of the character.
--   gender                  Gender of the character.
--   portrait                Portrait image.
--   status                  Character's living status - one of "dead",
--                           "missing", or nil (living).
--   description             Character's detailed bio/description.
--
function journeylog.retrieve_character_profiles()
	return lore_cache.profiles
end

--
-- Retrieves world encyclopedia entries for UI display.
--
-- Encyclopedia entries are structured thus:
--
--   id                      The entry's internal id.
--   name                    Name of the entry.
--   description             Text of the entry.
--
function journeylog.retrieve_world_lore()
	return lore_cache.world
end
