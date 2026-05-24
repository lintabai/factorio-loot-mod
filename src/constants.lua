-- src/constants.lua
local Constants = {}

Constants.RARITY = {
  NORMAL="normal", MAGIC="magic", RARE="rare", EPIC="epic", LEGENDARY="legendary"
}
Constants.RARITY_ORDER = {"normal","magic","rare","epic","legendary"}
Constants.RARITY_COLOR = {
  normal="#ffffff", magic="#5f98e8", rare="#ffd700", epic="#c87dff", legendary="#ff8c00"
}
Constants.RARITY_SLOTS = {
  normal   ={prefix=0,suffix=0},
  magic    ={prefix=1,suffix=1},
  rare     ={prefix=2,suffix=2},
  epic     ={prefix=3,suffix=3},
  legendary={prefix=3,suffix=3},
}
Constants.RARITY_WEIGHTS = {
  normal=590, magic=250, rare=120, epic=35, legendary=5
}
Constants.RARITY_RESEARCH_GATE = {
  normal=nil, magic="loot-rarity-1", rare="loot-rarity-2",
  epic="loot-rarity-3", legendary="loot-rarity-4"
}
Constants.REROLL_DESTRUCTION_CHANCE = {
  normal=0.00, magic=0.05, rare=0.15, epic=0.35, legendary=0.60
}
Constants.ROLLABLE_ENTITY_TYPES = {
  ["assembling-machine"]=true, ["mining-drill"]=true, ["furnace"]=true,
  ["inserter"]=true, ["electric-pole"]=true, ["lab"]=true,
  ["boiler"]=true, ["generator"]=true,
}
Constants.ROLLABLE_ARMOR_TYPES = { ["armor"]=true }
Constants.EFFECT = {
  SPEED_BONUS      ="speed_bonus",
  PRODUCTIVITY     ="productivity_bonus",
  CONSUMPTION      ="consumption_bonus",
  POLLUTION        ="pollution_bonus",
  RESOURCE_SPECIFIC="resource_specific",
  STALL            ="stall",
  DUPLICATE_OUTPUT ="duplicate_output",
  DELETE_OUTPUT    ="delete_output",
  SPAWN_BITERS     ="spawn_biters",
  RARITY_BONUS     ="rarity_bonus",
  LUCKY            ="lucky",
  CURSED           ="cursed",
  REACH_BONUS      ="reach_bonus",
  MOVEMENT_BONUS   ="movement_bonus",
}
Constants.TAG = {
  RARITY  ="loot_rarity",
  AFFIXES ="loot_affixes",
  ROLLED  ="loot_rolled",
  REROLLS ="loot_rerolls",
}
Constants.ORB = {
  TRANSMUTATION="loot-orb-transmutation",
  ALTERATION   ="loot-orb-alteration",
  ALCHEMY      ="loot-orb-alchemy",
  CHAOS        ="loot-orb-chaos",
  AUGMENTATION ="loot-orb-augmentation",
  ANNULMENT    ="loot-orb-annulment",
  SCOURING     ="loot-orb-scouring",
  EXALTATION   ="loot-orb-exaltation",
  BLESSED      ="loot-orb-blessed",
}
Constants.ALL_ORBS = {
  "loot-orb-transmutation","loot-orb-alteration","loot-orb-alchemy","loot-orb-chaos",
  "loot-orb-augmentation","loot-orb-annulment","loot-orb-scouring",
  "loot-orb-exaltation","loot-orb-blessed",
}
Constants.FORGE_ENTITY = "loot-tinkerers-forge"
Constants.FORGE_ITEM   = "loot-tinkerers-forge"

return Constants
