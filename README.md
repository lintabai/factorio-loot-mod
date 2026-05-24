# Loot & Rarity — Factorio Mod

A Diablo/Path of Exile-style item rarity and affix system for Factorio + Space Age.

## Overview

Crafted entities (assemblers, miners, furnaces, inserters, electric poles, labs, boilers, generators) and armor now roll a **rarity** when crafted, granting **prefixes** and **suffixes** that provide positive and negative modifiers.

## Rarity Tiers

| Rarity | Color | Prefixes | Suffixes | Research Required |
|--------|-------|----------|----------|-------------------|
| Normal | White | 0 | 0 | — |
| Magic | Blue | 1 | 1 | Item Rarity I |
| Rare | Yellow | 2 | 2 | Item Rarity II |
| Epic | Purple | 3 | 3 | Item Rarity III |
| Legendary | Orange | 3 | 3 | Item Rarity IV |

## How It Works

- **Hand-crafted items** roll their rarity and affixes immediately on craft completion.
- **Machine-crafted items** roll when placed.
- **Pre-placement names** show affixes in colored rich text for hand-crafted items.
- **Pick up and re-place** — affixes persist when you mine an entity back to inventory.
- **Modded entities** are included automatically — any entity whose type is in the rollable set gets affixes.

## Tinkerer's Forge

A reroll station. Place an item + a currency orb, click **Apply Orb**. The GUI shows the current affix list and **destruction chance** before you commit.

| Orb | Effect | Destruction Risk |
|-----|--------|-----------------|
| Orb of Transmutation | Normal → Magic | None |
| Orb of Alteration | Reroll all affixes (Magic) | 5% |
| Orb of Alchemy | Normal → Rare | None |
| Orb of Chaos | Reroll all affixes (Rare) | 15% |
| Orb of Augmentation | Add 1 affix (open slot) | Same as item |
| Orb of Annulment | Remove 1 random affix | Same as item |
| Orb of Scouring | Strip to Normal | None |
| Orb of Exaltation | Add 1 affix (Rare+) | Same as item |
| Blessed Orb | Reroll values only | Same as item |

## Lucky / Cursed

Armor can roll **Lucky** (reroll rarity, take best) or **Cursed** (take worst) affixes. The **of the Artificer** suffix on armor gives +1 rarity tier to items you hand-craft.

## Research Tree

```
Automation
└── Item Rarity I (Magic)
    ├── Item Rarity II (Rare)
    │   ├── Item Rarity III (Epic)
    │   │   └── Item Rarity IV (Legendary)
    │   └── Affix Mastery I (resource-specific affixes)
    │       └── Affix Mastery II (entity-specific affixes)
    │           ├── Affix Mastery III (legendary affixes)
    │           ├── Lab Affixes
    │           └── Armor Affixes
    └── Tinkerer's Forge
        ├── Orb Crafting I (basic orbs)
        │   └── Orb Crafting II (advanced orbs)
        │       └── Orb Crafting III (rare orbs, needs Rarity III)
```

## Known Limitations / TODO

- **Speed bonus for inserters**: `speed_bonus` applied via entity API; actual rotation speed may behave differently than crafting machines — needs in-game verification.
- **Wire distance / supply area** for poles: not runtime-writable; affixes are informational in v0.1. Needs prototype subclass approach.
- **Armor effect application**: movement speed and reach bonuses tracked but not yet fully wired to `character_running_speed_modifier`. In progress.
- **Machine-crafted item roll timing**: rolls at placement, not when the assembler outputs the item. No Factorio event exists for assembler output; on-tick polling was considered but deferred.
- **Crafter rarity bonus** (Assembler with "of the Artificer"): affects items inside *that* assembler — not yet implemented, requires output inventory polling.
- **Multi-tech processing** (Overloaded lab affix): speed penalty applied; dual-tech processing deferred.

## Multiplayer

All state is in `storage` (per-save global table) keyed by `unit_number`. No `LuaEntity` references stored persistently. GUI state is per-player-index. Safe for concurrent players.
