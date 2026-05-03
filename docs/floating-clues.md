# Floating Clues — Design & Implementation Notes

## The Problem with Fixed Clues

Every clue currently generated is **fixed**: its cells are absolute grid positions. A 2-cell clue that covers `(0,0)` and `(0,1)` tells the player exactly which two spots to reason about. The puzzle reduces entirely to constraint satisfaction — there is no deduction involved in *reading* the clues themselves.

This makes the game too easy. A small number of fixed clues is enough to uniquely determine the solution, and the player can solve it by straightforward elimination.

---

## Floating Clues

A **floating clue** shows a connected shape of cells with partial cookie information, but **without revealing its position in the grid**. The player sees the shape's internal layout (which cell is adjacent to which, what each cell shows) but must deduce where it sits.

**Example:** a 1×3 horizontal bar where the left cell shows `color=red`, the middle shows `shape=circle`, and the right shows `red/square`. The player knows this bar exists *somewhere* in the grid — in one of the three possible horizontal rows — and must figure out which row from the other constraints.

This adds a second layer of deduction on top of the cookie-identity reasoning that fixed clues provide.

---

## Clue Taxonomy (revised)

| Type | Position known? | Difficulty contribution |
|------|----------------|------------------------|
| Fixed | Yes — absolute `(row, col)` for each cell | Low — directly constrains cells |
| Floating | No — only relative positions within the shape | High — requires placement deduction |

Both types share the same internal reveal model (`CellReveal` with `color`/`shape`/`both`). The only difference is whether the player (and the solver) knows where the shape sits.

---

## Impact on the Solver

The current solver applies clue constraints by directly narrowing each cell's domain. That works only because positions are known.

For a floating clue the solver must instead:

1. Enumerate all valid placements of the clue's shape on the 3×3 grid (already available from `get_clue_shapes()`).
2. For each placement, check whether the assignment of cookies to those cells is consistent with the reveal.
3. Accept the clue as satisfied if **at least one** placement is consistent with the current (partial) assignment.

This turns each floating clue into a **disjunctive constraint** — any one of its placements may be the true one. The solver must branch over placements when it cannot immediately rule any out.

Concretely: when the solver assigns a cookie to a cell and wants to apply forward checking, it must prune any floating clue placement that has become impossible. A placement is impossible if any of its cells has been assigned a cookie that contradicts the reveal for that cell.

### Propagation sketch

```
active_placements[clue] = set of all valid placements for clue

on assignment cell → cookie:
    for each floating clue:
        remove from active_placements[clue] any placement P
            where P covers `cell` and P's reveal for `cell` contradicts `cookie`
        if active_placements[clue] is empty:
            backtrack  (clue can no longer be satisfied)
        if active_placements[clue] has exactly one placement left:
            treat that placement as a fixed clue and propagate its remaining cells
```

This is arc-consistency extended to disjunctive constraints, sometimes called **GAC (Generalised Arc Consistency)**.

---

## Impact on the Generator

The generator currently builds a candidate pool of fixed-clue instances and removes redundant ones. With floating clues the pool changes:

- A floating clue instance is identified by its **canonical shape + reveal pattern**, without a specific placement.
- Multiple placements of the same shape with the same reveal pattern collapse into one floating clue (the player sees it once; the solver considers all placements).
- The candidate pool shrinks significantly: 379 placement-specific fixed clues become 294 shape-specific floating clues (before info-pattern expansion).

The top-down removal loop stays the same in structure; only the solver call changes.

### Mixed puzzles

Fixed and floating clues can coexist in the same puzzle. A reasonable difficulty ladder:

| Difficulty | Clue mix |
|------------|----------|
| Easy | Fixed only, `both` reveals |
| Medium | Fixed + floating, mixed reveals |
| Hard | Floating only, partial reveals |

---

## Impact on Visualization

A floating clue cannot be shown overlaid on the 3×3 grid (its position is unknown). Instead it is rendered in its **tight bounding box** — just the cells that make up the shape, with empty/inactive cells cropped out.

The existing `show_clues()` function renders each clue inside a full 3×3 frame with inactive cells greyed out. For floating clues this must change to a compact frame sized to the shape's bounding box (e.g. a 1×3 horizontal bar renders in a 1×3 frame, an L-shape in a 2×2 frame).

Fixed and floating clues should be visually distinguishable — e.g. floating clues could have a dashed or coloured border to signal "you don't know where this goes."

---

## Data Model Changes

`Clue` needs a `floating: bool` field:

```python
@dataclass(frozen=True)
class Clue:
    reveals: Tuple[Tuple[Cell, CellReveal], ...]   # relative positions if floating
    floating: bool = False
```

For floating clues, `reveals` stores **relative** `(row, col)` positions (bounding box anchored at `(0,0)`), not absolute grid positions. The solver maps these to absolute positions when testing each placement.

---

## Implementation Order

1. **Data model** — add `floating` field; clarify relative vs absolute positions.
2. **Solver** — extend `count_solutions` to handle floating clues via active-placement propagation.
3. **Generator** — add floating clue candidates to the pool; test mixed and floating-only puzzles.
4. **Visualization** — render floating clues in their bounding box with a distinct border.
