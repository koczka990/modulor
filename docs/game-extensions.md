# Game Extensions

This document captures planned and potential extensions to the core Modulor puzzle format. These form the basis for future content packs and difficulty tiers.

---

## Grid Variations

### Difficulty tiers (3×3)

The base 3×3 grid supports multiple difficulty levels through clue quantity and type, without changing the grid itself. Easy, medium, and hard tiers are the foundation of the initial puzzle set.

### Larger grids

Extending the grid to 4×4 or 5×5 increases the solution space and clue complexity significantly. Requires expanding the piece set (more colors and/or shapes). Natural fit for "Expert" or "Extreme" packs.

### Irregular grid shapes

Instead of a rectangle, the grid could take an L-shape, T-shape, or other connected region. Same deduction mechanics, but the spatial layout adds a different feel. Good candidate for a late-stage "Special" pack.

---

## Clue Type Extensions

New clue types change how the player reasons, making puzzles feel like a different game even on the same 3×3 grid. Each type is a candidate for its own pack or difficulty tier.

### Relational clues

A clue states a spatial relationship between two pieces without fixing either to a specific cell. Example: "the red piece is directly above the triangle." The player must deduce both positions from the relationship.

This is the highest-value extension — it fundamentally changes the reasoning style and creates strong content hooks ("how does that even tell you anything?").

### Exclusion clues

A clue states what is NOT in a cell. Example: "this cell does not contain a circle." Requires the player to reason by elimination rather than confirmation. Combines naturally with other clue types.

### Row / column clues

A clue constrains a piece to a row or column without specifying the exact cell. Example: "the square appears somewhere in the top row." Looser than a fixed-cell clue, tighter than a relational clue — a good middle ground for medium difficulty.

### Floating clues

Clues whose cell positions are relative rather than absolute — a shape covers some region of the grid, but that region can shift. Already planned and documented in `floating-clues.md`. Natural "Advanced Pack" content.

---

## Gameplay Mode Extensions

### Minimal clues ("Deduction" mode)

Puzzles constructed with the absolute fewest clues that still yield a unique solution. Same grid and clue types, but pushed to the logical limit. Extremely hard. Strong TikTok format: "can you solve this with only 2 clues?"

### Meta-chain puzzles

A set of 5–6 puzzles where the solution to one feeds a clue into the next. Designed as a narrative sequence ("solve the mystery"). Feels distinct from standalone puzzles and justifies a premium "Story Pack" framing.

### Speed mode

Players race against a timer. Separate mechanic from the core deduction experience — better suited as a standalone mode than a content pack. Creates natural competitive and shareable content.

---

## Future Considerations

### Visual themes

Alternate color palettes and piece aesthetics (e.g. "Midnight Edition"). No mechanical change. Deferred — worth revisiting once the core pack structure is established.
