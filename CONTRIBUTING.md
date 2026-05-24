# Contributing to Loot & Rarity

## Origin

This mod was **built entirely by AI** (Claude, made by Anthropic) in a collaborative session with a human directing the design. The codebase — architecture, affix system, research tree, GUI, API research, bug fixes, and icon — was generated and revised iteratively through that conversation.

Contributions from **both humans and AI agents** are welcome. There is no distinction made in how contributions are evaluated — quality and correctness are what matter.

---

## Versioning

This project follows **Semantic Versioning** (`MAJOR.MINOR.PATCH`), consistent with the Factorio mod portal convention.

| Increment | When |
|-----------|------|
| `PATCH` (0.1.**x**) | Bug fixes, affix value tweaks, locale additions, doc-only changes |
| `MINOR` (0.**x**.0) | New affixes, new orbs, new entity type support, new research nodes |
| `MAJOR` (**x**.0.0) | Breaking save-game compatibility, major rework of core systems |

### Releasing a new version

1. Update `version` in `info.json`
2. Add a section to `changelog.txt` (Factorio standard format — see existing entries)
3. Commit: `git commit -m "chore: bump to X.Y.Z"`
4. Tag: `git tag -a vX.Y.Z -m "Release X.Y.Z"`
5. Push: `git push origin main --tags`

The git tag is the canonical version record. The `info.json` version must match.

---

## Development Setup

```bash
# Clone into Factorio's mods directory
cd ~/.factorio/mods
git clone https://github.com/lintabai/factorio-loot-mod.git factorio-loot-mod_0.1.0

# Factorio loads mods from folders named <name>_<version>
# Update the folder name or use a symlink when bumping versions:
ln -sfn factorio-loot-mod factorio-loot-mod_0.2.0
```

Factorio 2.0 + Space Age expansion required. No external Lua dependencies.

### Recommended tooling

- **[Factorio Modding Toolkit (FMTK)](https://github.com/justarandomgeek/vscode-factoriomod-debug)** — VS Code extension with debugger, type annotations, and live reload
- **`luac5.2 -p <file>`** — syntax check (matches Factorio's embedded Lua 5.2.1)
- **[flib](https://github.com/factoriolib/flib)** — standard library for GUIs and events (not a dependency yet, but worth considering for the GUI rewrite)

### Testing checklist before a PR

- [ ] `luac5.2 -p` passes on all `.lua` files
- [ ] Mod loads in a fresh Factorio 2.0 save without errors in `factorio-current.log`
- [ ] Crafting an assembler → item gets a colored name in inventory
- [ ] Placing that item → entity gets the matching colored `custom_name`
- [ ] Mining and re-placing preserves affixes
- [ ] Tinkerer's Forge: both GUI panels visible (container inventory + side panel)
- [ ] Orb of Scouring strips affixes; Orb of Transmutation upgrades Normal → Magic
- [ ] Destruction on high rarity rerolls can be triggered and destroys the item
- [ ] Multiplayer: two players can each use a Forge simultaneously

---

## Project Structure

See the [README](README.md#project-structure) for the full annotated tree. Key areas:

- **`src/affixes/`** — add new affix pools here; `init.lua` resolves pools dynamically
- **`src/constants.lua`** — rarity tiers, weights, effect IDs, tag keys
- **`src/applicator.lua`** — maps effect IDs to `LuaEntity` property mutations
- **`src/tick_handlers.lua`** — on-tick processing (resource corrections, stall, output)
- **`prototypes/technologies.lua`** — research tree

---

## How to Add a New Affix

1. Pick the right affix file (`src/affixes/generic.lua` for all types, or the type-specific file)
2. Add a definition table following the schema:

```lua
{
  id          = "my_affix",         -- unique, snake_case
  name        = "My Affix",         -- display prefix/suffix name
  type        = "prefix",           -- "prefix" or "suffix"
  effect      = C.EFFECT.SPEED_BONUS,
  description = "+{value}% thing",  -- {value} is replaced with formatted value
  tiers = {
    { min = 0.10, max = 0.20, weight = 80 },
    { min = 0.25, max = 0.40, weight = 30 },
  },
  requires_research = "loot-affixes-1",  -- nil = always available
  -- Optional: entity_name_filter = {"lab", "biolab"}  (lab-specific only)
}
```

3. If the effect ID is new, add it to `src/constants.lua` `EFFECT` table and handle it in `src/applicator.lua`
4. Add locale keys in `locale/en.cfg` if the affix name needs translation
5. Bump the `PATCH` version

---

## How to Add a New Orb

1. Add the orb name constant to `src/constants.lua` `ORB` table and `ALL_ORBS` list
2. Add prototype in `prototypes/items.lua` (icon, stack_size, subgroup)
3. Add recipe in `prototypes/recipes.lua`
4. Add `unlock-recipe` effect to the appropriate technology in `prototypes/technologies.lua`
5. Add the orb logic branch in `src/forge.lua` `Forge.apply_orb()`
6. Add locale strings in `locale/en.cfg`
7. Add a row to the orb table in `README.md`

---

## Code Style

- Lua 5.2 only — no `goto` except via `::label::` pattern (already used), no Lua 5.3+ integer division `//`
- Always check `entity.valid` before using a LuaEntity that may have been stored
- Prefer `pcall` when calling properties that might not exist on all entity types
- No global state outside `storage.loot.*` — everything is namespaced
- Comments for non-obvious API choices (e.g., why `consumed_items` instead of `stack`)

---

## Filing Issues

Please include:
- Factorio version and installed mod list
- The relevant section of `factorio-current.log`
- Reproducible steps (ideally a `/c` console command that triggers it)

AI-generated bug reports are fine — paste the log and describe what you were doing.

---

## Pull Requests

PRs are merged if they:
- Pass the Lua syntax check
- Don't break the testing checklist above
- Update `changelog.txt` appropriately
- Don't reduce the affix pool without a strong reason (this mod is about variety)

No CLA required. Contributions become MIT-licensed by submitting a PR.
