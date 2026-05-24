# Loot & Rarity

<p align="center">
  <img src="thumbnail-large.png" width="256" alt="Loot & Rarity icon"/>
</p>

A Diablo / Path of Exile-style item rarity and affix system for **Factorio 2.0 + Space Age**. Crafted entities and armor roll a random **rarity** which grants **prefixes** and **suffixes** providing positive and negative modifiers. Reroll items using a Tinkerer's Forge with currency orbs — at the risk of destroying them.

---

## Table of Contents

- [Concept](#concept)
- [Rarity Tiers](#rarity-tiers)
- [How Rolling Works](#how-rolling-works)
- [Affix Catalog](#affix-catalog)
- [Tinkerer's Forge & Currency Orbs](#tinkerers-forge--currency-orbs)
- [Research Tree](#research-tree)
- [Armor & Lucky/Cursed](#armor--luckycursed)
- [Multiplayer Safety](#multiplayer-safety)
- [Installation](#installation)
- [Project Structure](#project-structure)
- [Technical Notes / Known Limitations](#technical-notes--known-limitations)
- [License](#license)

---

## Concept

Every craftable entity (assemblers, miners, furnaces, inserters, electric poles, labs, boilers, generators) and every armor item rolls a rarity when crafted. Higher rarity grants more affix slots. Affixes can be positive (more speed, less power use, bonus output) or negative (random stalls, lost outputs, wasted ingredients) — even a Legendary item can roll all bad affixes. The Tinkerer's Forge lets you reroll with currency orbs, paying for the upside in destruction risk.

Modded entities are included automatically: detection is by entity **type**, not by hardcoded prototype name. Any modded `assembling-machine`, `mining-drill`, `lab`, etc. gets affixes for free.

---

## Rarity Tiers

| Rarity | Color | Prefixes | Suffixes | Base weight | Research gate |
|--------|-------|---------:|---------:|------------:|---------------|
| Normal | White (no change) | 0 | 0 | 590 / 1000 | — |
| Magic | Cornflower blue | 1 | 1 | 250 / 1000 | Item Rarity I |
| Rare | Gold | 2 | 2 | 120 / 1000 | Item Rarity II |
| Epic | Purple | 3 | 3 | 35 / 1000 | Item Rarity III |
| Legendary | Orange | 3 | 3 | 5 / 1000 | Item Rarity IV |

Item display name is recolored via Factorio rich-text codes: e.g. `[color=#ffd700]Swift Assembling Machine 3 of Abundance[/color]`.

---

## How Rolling Works

- **Hand-crafted items** roll their rarity and affixes the moment crafting finishes (`on_player_crafted_item`). Affixes are stored in the item stack's `tags` (JSON-serialized) and the colored name appears immediately in the inventory.
- **Machine-crafted items** roll on placement (`on_built_entity` / `on_robot_built_entity`), because Factorio has no event for "assembler produced an item". This is documented as a limitation; affix consistency is maintained: mining a placed entity puts an affix-tagged item back in your inventory.
- **Modifiers stack** with what a force has researched. Items can only roll up to the highest rarity the player's force has unlocked.

### Lucky / Cursed shift

- **Lucky N** (armor prefix): rolls rarity (1+N) times, keeps the best result.
- **Cursed N** (armor prefix): rolls rarity (1+N) times, keeps the worst result.
- **of Misfortune** (armor suffix): shifts the rolled rarity down by 1.
- **of the Artificer** (armor suffix): treats every hand-craft as if Lucky+1.

Bonuses sum: Lucky II + of the Artificer = roll 4 times, take best.

---

## Affix Catalog

### Generic (all rollable entities)

| Affix | Type | Effect |
|-------|------|--------|
| Swift / Sluggish | Prefix | ± operating speed |
| Efficient / Wasteful | Prefix | ± energy consumption |
| Clean / Polluting | Prefix | ± pollution output |
| Overclocked | Prefix | +speed AND +100% energy (linked) |
| Haunted | Prefix | Random stalls of N seconds at random intervals |
| Prolific | Prefix | + productivity (Affix Mastery I required) |
| of Abundance | Suffix | Chance to duplicate output |
| of the Void | Suffix | Chance to silently delete output |
| of Silence | Suffix | Zero pollution, -10% speed |
| of the Ancients | Suffix | Speed x1.5, energy x3 |
| of Ruin | Suffix | Chance to lose full input batch |

### Assembler-specific (requires Affix Mastery I / II)

| Affix | Effect |
|-------|--------|
| Iron-Efficient / Iron-Hungry | ± iron-plate consumption (post-craft inventory correction) |
| Copper-Efficient / Copper-Hungry | ± copper-plate consumption |
| Steel-Substituting | Replaces 50% of iron requirement with steel |
| Fluid-Efficient / Fluid-Wasteful | ± any fluid ingredient |
| Plate-Hungry | +plate consumption, +10% speed (linked) |
| Circuit-Scavenging | 15% chance to refund one circuit component |
| Ingredient-Scrambled | Randomly swaps ingredient types (chaos affix) |
| of Experimentation | Output may be a random quality tier |
| of Echoes | Chance to spawn an extra output to adjacent belt |
| of Decay | Chance to downgrade output quality |
| of the Prototype | +2 effective module slots |
| of Hunger | Never stalls for energy, +40% drain |

### Miner-specific

| Affix | Effect |
|-------|--------|
| Deep-Driller | +speed, +50% energy (linked) |
| Vein-Reader | + mining yield (productivity bonus) |
| Ore-Blind | Chance to output wrong ore type |
| of Rich Veins | Chance to output double ore |
| of Dust | Chance to lose ore entirely |

### Furnace-specific

| Affix | Effect |
|-------|--------|
| Blazing / Cold | ± smelting speed |
| Fuel-Sipping / Fuel-Hungry | ± fuel consumption |
| of Pure Metal | Chance for bonus ingot |
| of Slag | Chance to produce stone as byproduct |

### Inserter-specific

| Affix | Effect |
|-------|--------|
| Nimble / Clumsy | ± rotation speed |
| Stack-Gifted | + stack-size override |
| Fumbling | Chance to drop item on ground |
| of Reach | + tile reach (cosmetic in v0.1) |
| of Misplacement | Chance to misplace item |

### Electric Pole-specific

| Affix | Effect |
|-------|--------|
| Long-Range / Short-Range | ± wire connection distance (informational v0.1) |
| Wide-Area / Narrow-Area | ± supply area (informational v0.1) |
| Superconducting | -50% energy transmission loss |
| Corroded | + energy transmission loss |

### Lab-specific (requires Lab Affixes)

| Affix | Effect |
|-------|--------|
| Power-Sipping / Power-Hungry | ± energy consumption |
| Accelerated / Sluggish | ± research speed |
| Biter-Attracting | Chance to spawn biters on research finish |
| Enlightened | Chance for bonus research progress tick |
| Overloaded | -20% speed, processes 2 queued techs (TODO: dual processing) |
| Automation-Attuned / Logistic-Focused / Military-Drilled / Chemical-Calibrated | Reduced consumption of specific science type |
| Bioengineered | +speed (Biolab only, Space Age) |
| of Overflow | Chance to consume science without progress |
| of the Academy | +30% speed, x2 energy |
| of Instability | Random pauses mid-research |

### Armor-specific (requires Armor Affixes)

| Affix | Effect |
|-------|--------|
| Swift / Lumbering | ± character movement speed |
| Lucky / Cursed | Rarity roll modifier (see above) |
| Warded | + equipment recharge rate |
| of the Artificer | + 1 rarity tier for hand-crafted items |
| of Reach | + character reach |
| of Misfortune | -1 rarity tier rolled |
| of the Engineer | + module efficiency in equipment grid |

---

## Tinkerer's Forge & Currency Orbs

The Forge is a 2-slot container building. Slot 1: item to reroll. Slot 2: currency orb. A side panel GUI shows the current item's affixes and **destruction chance** before you confirm.

| Orb | Effect | Operates on |
|-----|--------|-------------|
| Orb of Transmutation | Normal → Magic | Normal |
| Orb of Alteration | Reroll all affixes | Magic |
| Orb of Alchemy | Normal → Rare | Normal |
| Orb of Chaos | Reroll all affixes | Rare |
| Orb of Augmentation | Add 1 affix to an open slot | Any with open slot |
| Orb of Annulment | Remove 1 random affix | Any with affixes |
| Orb of Scouring | Strip all affixes back to Normal | Any non-Normal |
| Orb of Exaltation | Add 1 affix | Rare+ with open slot |
| Blessed Orb | Reroll affix values (keep which affixes) | Any non-Normal |

### Destruction risk per reroll

| Rarity | Destruction chance |
|--------|------------------:|
| Magic | 5% |
| Rare | 15% |
| Epic | 35% |
| Legendary | 60% |

Destruction is permanent. The orb is consumed regardless.

---

## Research Tree

```
Automation
└── Item Rarity I (Magic)
    ├── Item Rarity II (Rare)
    │   ├── Item Rarity III (Epic)
    │   │   └── Item Rarity IV (Legendary)
    │   └── Affix Mastery I (resource-specific affixes)
    │       └── Affix Mastery II (entity-specific affixes)
    │           ├── Affix Mastery III (legendary-only affixes)
    │           ├── Lab Affixes
    │           └── Armor Affixes
    └── Tinkerer's Forge
        ├── Orb Crafting I (Transmutation, Alteration, Alchemy, Scouring)
        │   └── Orb Crafting II (Chaos, Augmentation, Annulment)
        │       └── Orb Crafting III (Exaltation, Blessed)
```

13 technologies total, each with proper science-pack ingredient requirements escalating from automation through space science.

---

## Multiplayer Safety

- All persistent state lives in `storage` (Factorio 2.0's renamed `global` table) keyed by `unit_number`.
- `LuaEntity` references in storage are validity-checked before use; entities that have been destroyed get their data garbage-collected.
- GUI state is scoped per `player_index`.
- Event handlers are registered at the top level of `control.lua` so joining-players get identical bindings.
- `on_load` does not touch game state.
- `on_configuration_changed` re-runs storage initialization to repair missing fields after updates.

---

## Installation

### From source (development)

```bash
# Clone into your Factorio mods folder
cd ~/.factorio/mods
git clone https://github.com/lintabai/factorio-loot-mod.git factorio-loot-mod_0.1.0
```

Or symlink for live editing:

```bash
ln -s /path/to/factorio-loot-mod ~/.factorio/mods/factorio-loot-mod_0.1.0
```

### Packaging for the mod portal

```bash
# From the parent directory of the mod folder:
zip -r factorio-loot-mod_0.1.0.zip factorio-loot-mod \
  -x "factorio-loot-mod/.git/*" \
  -x "factorio-loot-mod/.gitignore" \
  -x "factorio-loot-mod/thumbnail-large.png"
```

The mod portal expects the zip to contain a single top-level folder named `<name>_<version>` matching `info.json`.

### Dependencies

- Factorio ≥ 2.0
- `base` mod (included with game)
- `space-age` mod (Space Age expansion required)
- Quality system is used; flagged `quality_required: true` in `info.json`

---

## Project Structure

```
factorio-loot-mod/
├── info.json                  Mod manifest (name, version, deps, DLC flags)
├── thumbnail.png              144x144 mod portal icon
├── thumbnail-large.png        512x512 high-res icon
├── data.lua                   Prototype stage entry — loads all prototypes
├── data-updates.lua           Post-base prototype adjustments (currently empty)
├── control.lua                Runtime entry — registers events, init storage
├── changelog.txt              Standard Factorio changelog format
├── LICENSE                    MIT
├── README.md                  This file
├── .gitignore
│
├── prototypes/
│   ├── item_groups.lua        Subgroup definitions (loot-orbs, loot-buildings)
│   ├── entities.lua           Tinkerer's Forge entity (container, 2 slots)
│   ├── items.lua              9 orb items + Forge item
│   ├── recipes.lua            Orb crafting recipes (3 tiers) + Forge recipe
│   └── technologies.lua       13 technology nodes
│
├── src/
│   ├── constants.lua          Rarity tables, effect IDs, tag keys, orb names
│   ├── storage.lua            Persistent state management (storage namespace)
│   ├── rolling.lua            Rarity roll + affix selection (weighted)
│   ├── serializer.lua         JSON pack/unpack for item tags
│   ├── naming.lua             Rich-text colored name builder + tooltip
│   ├── applicator.lua         Apply/unapply affix effects to LuaEntity
│   ├── entity_detection.lua   Rollable type check + item→entity resolution
│   ├── forge.lua              Reroll orb logic + destruction roll
│   ├── gui.lua                Forge GUI (side panel, info, Apply button)
│   ├── research.lua           Biter-Attracting + Enlightened lab handlers
│   ├── tick_handlers.lua      on_nth_tick processing (resource/stall/output)
│   ├── events.lua             Event registration + routing
│   └── affixes/
│       ├── init.lua           Loads all affix tables, pool resolver
│       ├── generic.lua        Affixes valid on every rollable entity type
│       ├── assembler.lua      Resource-specific + assembler-only suffixes
│       ├── miner.lua
│       ├── furnace.lua
│       ├── inserter.lua
│       ├── pole.lua
│       ├── lab.lua            Generic + science-type-specific + suffixes
│       └── armor.lua          Lucky/Cursed/Artificer/etc.
│
└── locale/
    └── en.cfg                 English strings (technology, item, gui)
```

---

## Technical Notes / Known Limitations

### Works as designed

- `LuaEntity.speed_bonus`, `productivity_bonus`, `consumption_bonus`, `pollution_bonus` are read/write at runtime → most affixes apply directly. No hidden beacon hack needed.
- Item tags persist across the inventory/entity boundary: pick up an entity, the affix data survives.
- Modded entities are caught automatically via `type` detection.

### Partial implementations in v0.1

- **Wire distance / supply area** (electric pole affixes): not runtime-writable. Currently informational only — would require prototype subclasses or runtime entity swaps to truly apply.
- **Equipment grid slots** (Radiant affix on armor): `LuaEquipmentGrid.width/height` are read-only. Dropped from the design.
- **Crafter rarity bonus on assemblers** (the "of the Artificer" effect when applied to an assembler instead of armor): would require polling assembler output inventories to detect new items, then upgrading their tags. Deferred — works for hand-crafting only via armor.
- **Random quality output** (of Experimentation): scaffolded as a duplicate-output affix; full integration with the Quality system pending.
- **Echoed output to belt** (of Echoes): currently behaves as a generic duplicate-output. Spawning to a specific adjacent belt needs path-finding logic.
- **Overloaded lab dual-tech processing**: applies speed penalty only; multi-tech queue handling deferred.

### Factorio API constraints discovered during implementation

- No event fires when an assembler produces an item. Item rolls for machine-crafted entities therefore happen on placement, not on craft. (Polling output inventories was considered and rejected for performance.)
- `on_built_entity` in 2.0 passes `event.consumed_items` (a `LuaInventory`), not `event.stack`. `on_robot_built_entity` still passes `event.stack`. Both are handled.
- Mining handlers must read from `event.buffer` — items aren't yet in the player's inventory at event time.
- `script.on_nth_tick(N, ...)` allows only one handler per N — all our tick work for a given interval is combined into a single callback.
- `entity.crafting_progress` is only valid on crafting machines / furnaces / rocket silos; access is guarded by type check.
- `speed_bonus` etc. are not present on inserters, electric poles, boilers, or generators; the applicator dispatches by type and silently no-ops on unsupported types.

### Performance considerations

- `on_nth_tick(6)` (~10 Hz) scans only entities with resource-specific or output-mutating affixes — not all entities globally. The hot-loop set is small in practice.
- `on_nth_tick(60)` (1 Hz) for stall affixes; same selective set.
- Affix definition lookups are cached on first access in `affixes/init.lua`.

---

## License

MIT — see [LICENSE](LICENSE).
