local function setupGenericDictEntry(guid)
  return {
    ID = guid,
    SubTypes = {}
  }
end

--- Insert Class Description entry into Globals.ClassDescriptions
--- @param name string
--- @param guid string
--- @param parent? table
---@return table
function DictUtils.ClassDescription(name, guid, parent)
  local targetArr = Globals.ClassDescriptions
  if parent then
    targetArr = parent.SubTypes
  end

  targetArr[name] = setupGenericDictEntry(guid)

  return targetArr[name]
end

--- Insert Species (Race) entry into Globals.Species
---@param name string
---@param guid string
---@param parent? table
---@return table
function DictUtils.Species(name, guid, parent)
  local targetArr = Globals.Species
  if parent then
    targetArr = parent.SubTypes
  end

  targetArr[name] = setupGenericDictEntry(guid)

  return targetArr[name]
end

--- Initial set-up for a Spell List Dictionary Entry
---@return table
local function setupSpellListDict()
  local result = {
    Features = {},
    Spells = {}
  }

  return result
end

--- Generator for Spell List Dictionary Data
--- @param name string
--- @param subType? table typically table of Level
---@return table
function DictUtils.SpellList(name, subType)
  subType = subType or {}

  Globals.SpellLists[name] = {
    Base = setupSpellListDict()
  }

  if subType then
    for _, val in pairs(subType) do
      Globals.SpellLists[name][val] = setupSpellListDict()
    end
  end

  return Globals.SpellLists[name]
end

-- TODO: Add table handling so we can safely merge things
--- Add field to Dictionary Object
--- @param obj table
--- @param fieldObj table
function DictUtils.InsertField(obj, fieldObj)
  obj = obj or {}
  for key, value in pairs(fieldObj) do
    obj[key] = value
  end
end

--- Initial Setup for Progression Dictionary Entry
--- @param progression string
--- @param mcProgression? string
--- @return table
function DictUtils.setupClassLevelEntry(progression, mcProgression)
  local result = {}
  result.Progression = progression
  result.MulticlassProgression = mcProgression or nil

  return result
end

--- Basic Generation for Progression Dictionary Entry
---@return table
local function setupProgressionDict()
  return {
    Levels = {}
  }
end

--- Generation for Progression Dictionary Entry
--- @param name string
--- @param subType? table typically table of Subclasses
---@return table
function DictUtils.Progression(name, subType)
  subType = subType or {}

  Globals.Progressions[name] = {
    Base = setupProgressionDict()
  }

  if subType then
    for _, val in pairs(subType) do
      Globals.Progressions[name][val] = setupProgressionDict()
    end
  end

  return Globals.Progressions[name]
end

--- Retrieves a Class' name from its Progression
--- @param guid string
---@return string|nil
function DictUtils.RetrieveClassNameFromProgression(guid)
  for className, classProgressions in pairs(Globals.Progressions) do
    for _, level in pairs(classProgressions.Base) do
      if level then
        for _, entry in pairs(level) do
          if Utils.IsInTable(entry, guid) then
            return className
          end
        end
      end
    end
  end
end

--- Registers a Mod Name & UUID Pair to Globals.ModsDict
--- @param modName string
--- @param modId string
function DictUtils.RegisterModToDictionary(modName, modId)
  local modKey = modName
  if Utils.IsInTable(Globals.ModsDict, modId) then
    Utils.Info(modKey .. Strings.FRAG_MOD_ID .. modId .. Strings.FRAG_ALREADY_REGISTERED)
  elseif Utils.IsKeyInTable(Globals.ModsDict, modKey) then
    Utils.Info(modKey .. Strings.FRAG_ALREADY_REGISTERED)
  else
    Globals.ModsDict[modKey] = modId
  end
end

-- Populate ModsDict with loaded mods
function DictUtils.InscribeLoadedMods()
  for _, uuid in pairs(Ext.Mod.GetLoadOrder()) do
    local modData = Ext.Mod.GetMod(uuid)
    Utils.RegisterModToDictionary(modData.Info.Name, modData.Info.ModuleUUID)
  end
end
