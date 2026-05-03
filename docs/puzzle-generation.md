# Puzzle Generation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Given a random solution grid, generate a minimal set of visual clues that uniquely constrains that solution to exactly one valid arrangement.

**Architecture:** Three-phase pipeline — (1) generate a random solution, (2) enumerate all valid clue instances for that solution bounded by clue size, (3) repeatedly remove clues from that pool while uniqueness holds (top-down removal). A backtracking CSP solver is the core primitive used both for uniqueness checking during generation and for validating puzzles during play.

**Tech Stack:** Python 3.11, dataclasses, itertools. No external dependencies.

---

## Background: What We Already Have

`main.ipynb` contains `get_clue_shapes()`, which returns all 294 unique connected shapes for a 3×3 grid with their placements (379 total placements across sizes 2–9). This will be extracted into `puzzle/shapes.py` unchanged.

---

## Data Model

```python
# puzzle/model.py

from __future__ import annotations
from dataclasses import dataclass
from typing import Dict, Optional, Tuple

Color = str   # 'red' | 'blue' | 'green'
Shape = str   # 'circle' | 'square' | 'triangle'
Cell  = Tuple[int, int]   # (row, col), both in range 0–2

COLORS = ('red', 'blue', 'green')
SHAPES = ('circle', 'square', 'triangle')

@dataclass(frozen=True)
class Cookie:
    color: Color
    shape: Shape

ALL_COOKIES: Tuple[Cookie, ...] = tuple(
    Cookie(c, s) for c in COLORS for s in SHAPES
)

@dataclass
class Grid:
    """A complete solution: one cookie per cell."""
    cookies: Dict[Cell, Cookie]   # exactly 9 entries

    def __getitem__(self, cell: Cell) -> Cookie:
        return self.cookies[cell]

@dataclass(frozen=True)
class CellReveal:
    """What a clue shows about a single cell. None = not shown."""
    color: Optional[Color]
    shape: Optional[Shape]

@dataclass(frozen=True)
class Clue:
    """A constraint on the grid at fixed (absolute) cell positions."""
    reveals: Tuple[Tuple[Cell, CellReveal], ...]   # sorted by cell

    def items(self):
        return self.reveals
```

Key design decisions:
- `Cookie` and `CellReveal` are frozen dataclasses so they are hashable and usable in sets.
- `Clue.reveals` is a tuple of pairs (not a dict) to make `Clue` hashable/comparable.
- No floating clues in this plan — only fixed (absolute position) clues.

---

## Algorithm Design

### Phase 1 — Solution Generation

Trivial: shuffle `ALL_COOKIES` and assign to cells in row-major order.

```python
import random

def random_solution() -> Grid:
    cookies = list(ALL_COOKIES)
    random.shuffle(cookies)
    cells = [(r, c) for r in range(3) for c in range(3)]
    return Grid(cookies=dict(zip(cells, cookies)))
```

### Phase 2 — Clue Enumeration

For every connected shape placement on the 3×3 grid, and for every combination of reveal types across the cells in that placement, emit one `Clue` instance whose reveal values are read directly from the solution.

Each cell in a clue can reveal one of three things:
- `color only` → `CellReveal(color=X, shape=None)`
- `shape only` → `CellReveal(color=None, shape=Y)`
- `both`       → `CellReveal(color=X, shape=Y)`

For a placement covering *k* cells this gives `3^k` clue variants.

**Scale at different size caps** (using known placement counts from `get_clue_shapes()`):

| Max size | Placements | Total clue instances |
|----------|-----------|----------------------|
| 2        | 20        | 180                  |
| 3        | 68        | 1,476                |
| 4        | 153       | 8,361                |
| 5        | 255       | 33,147               |

Practical recommendation: **cap at size 4** for the initial implementation. 8,361 candidates is fast to enumerate and trivially fast for the solver to check. Raise to 5 later if needed for puzzle variety.

```python
# puzzle/clues.py

from itertools import product

INFO_TYPES = ('color', 'shape', 'both')

def enumerate_clues(solution: Grid, max_size: int = 4) -> List[Clue]:
    clues = []
    for shape in get_clue_shapes():
        if shape['size'] > max_size:
            continue
        for placement_matrix in shape['placements']:
            cells = [
                (r, c)
                for r in range(3) for c in range(3)
                if placement_matrix[r][c] == 1
            ]
            for info_pattern in product(INFO_TYPES, repeat=len(cells)):
                reveals = tuple(
                    (cell, _make_reveal(solution[cell], info))
                    for cell, info in zip(cells, info_pattern)
                )
                clues.append(Clue(reveals=reveals))
    return clues

def _make_reveal(cookie: Cookie, info: str) -> CellReveal:
    return CellReveal(
        color=cookie.color if info in ('color', 'both') else None,
        shape=cookie.shape if info in ('shape', 'both') else None,
    )
```

### Phase 3 — Solver (Uniqueness Checker)

The solver answers: *"Given this set of clues, how many valid arrangements of the 9 cookies exist?"* For puzzle validation we only need to know if the answer is exactly 1; for efficiency we stop counting at 2.

**Algorithm:** Backtracking CSP with:
- Domain reduction: apply all clue constraints up front to narrow each cell's candidate set.
- All-different: track which cookies are already placed.
- MRV heuristic: always branch on the most-constrained unassigned cell first.

```python
# puzzle/solver.py

def count_solutions(clues: List[Clue], limit: int = 2) -> int:
    # Build initial domains
    domains: Dict[Cell, set] = {
        (r, c): set(ALL_COOKIES) for r in range(3) for c in range(3)
    }
    for clue in clues:
        for cell, reveal in clue.reveals:
            domains[cell] = {
                k for k in domains[cell]
                if (reveal.color is None or k.color == reveal.color)
                and (reveal.shape is None or k.shape == reveal.shape)
            }

    count = 0

    def backtrack(assigned: dict, used: set) -> bool:
        nonlocal count
        if len(assigned) == 9:
            count += 1
            return count >= limit
        # MRV: most constrained cell first
        cell = min(
            (c for c in domains if c not in assigned),
            key=lambda c: len(domains[c] - used),
        )
        for cookie in list(domains[cell] - used):
            assigned[cell] = cookie
            used.add(cookie)
            if backtrack(assigned, used):
                del assigned[cell]
                used.discard(cookie)
                return True
            del assigned[cell]
            used.discard(cookie)
        return False

    backtrack({}, set())
    return count
```

With domain reduction and MRV the solver typically explores far fewer than 9! = 362,880 states. In practice it will run in microseconds for most puzzle instances.

### Phase 4 — Puzzle Assembly

Three approaches considered:

---

#### Approach A — Top-Down Removal ✅ Recommended

Start with a pool of clue candidates that collectively over-constrain the solution. Shuffle the pool. Iterate through it; remove each clue if the puzzle remains uniquely solvable without it. The result is a minimal clue set.

```
pool  ← enumerate_clues(solution, max_size=4)
       filtered to those consistent with this solution
shuffle(pool)
active ← pool
for clue in pool:
    test ← active - {clue}
    if count_solutions(test) == 1:
        active ← test
return active
```

**Pros:** Correct by construction — always produces a minimal puzzle. Simple. The shuffling step provides puzzle variety for the same solution.

**Cons:** One solver call per candidate clue (~8,361 calls at max_size=4). Each call is fast, so total generation time is acceptable.

---

#### Approach B — Bottom-Up Addition

Start with zero clues, greedily add the clue that most reduces the solution space, stop when count = 1.

**Pros:** Naturally controls difficulty (stop when solution space reaches a threshold: e.g. leave 2 solutions for the hardest tier). Direct control over number of clues in the final puzzle.

**Cons:** Evaluating all remaining candidates at each step is O(n²) solver calls. Greedy does not guarantee minimality. Harder to implement a good scoring function.

---

#### Approach C — SAT / Z3

Encode as a MaxSAT problem: find a minimum-size subset of clues that uniquely determines the solution.

**Pros:** Provably optimal subset size.

**Cons:** Significant dependency, encoding complexity, and overkill for a 3×3 grid. Not chosen.

---

### Difficulty Scaling

Difficulty is controlled at the **candidate pool filtering** step (before removal), by restricting which clue variants are allowed into the pool:

| Difficulty | Max size | Allowed info types  |
|------------|----------|---------------------|
| Easy       | 3        | `both` only         |
| Medium     | 4        | `both`, `color`, `shape` |
| Hard       | 4        | `color`, `shape` only |

An easy puzzle will only ever contain clues that show full identity, so deduction is straightforward. A hard puzzle forces the player to reason from partial information only.

---

## Future Extensions (out of scope for this plan)

- **Floating / slice clues:** A clue whose cells are relative positions; it matches anywhere on the grid where that pattern occurs. Requires the solver to iterate over all placements of the floating shape and check each one.
- **Negative clues:** `CellReveal` with a `not_color` or `not_shape` field.
- **Relationship clues:** "Cookie A is adjacent to cookie B" — a different constraint type altogether.

---

## File Structure

```
puzzle/
  __init__.py           empty
  model.py              Cookie, Grid, Cell, CellReveal, Clue, ALL_COOKIES, COLORS, SHAPES
  shapes.py             get_clue_shapes() extracted from main.ipynb (no changes to logic)
  clues.py              enumerate_clues(solution, max_size, allowed_info) -> List[Clue]
  solver.py             count_solutions(clues, limit) -> int
  generator.py          random_solution(), generate_puzzle(difficulty) -> (Grid, List[Clue])
tests/
  __init__.py           empty
  test_model.py         Cookie, Grid, CellReveal, Clue construction and equality
  test_shapes.py        shape count, connectivity, placement bounds
  test_clues.py         clue count, reveal correctness, solution consistency
  test_solver.py        empty input, fully-constrained input, contradictory input
  test_generator.py     uniqueness, minimality, difficulty filter
docs/
  puzzle-generation.md  this file
```

---

## Implementation Tasks

---

### Task 1: Data Model

**Files:**
- Create: `puzzle/__init__.py`
- Create: `puzzle/model.py`
- Create: `tests/__init__.py`
- Create: `tests/test_model.py`

- [ ] **Step 1: Write failing tests**

```python
# tests/test_model.py
from puzzle.model import Cookie, Grid, CellReveal, Clue, ALL_COOKIES, COLORS, SHAPES

def test_cookie_equality():
    assert Cookie('red', 'circle') == Cookie('red', 'circle')
    assert Cookie('red', 'circle') != Cookie('blue', 'circle')

def test_cookie_is_hashable():
    s = {Cookie('red', 'circle'), Cookie('red', 'circle')}
    assert len(s) == 1

def test_all_cookies_has_nine_unique():
    assert len(ALL_COOKIES) == 9
    assert len(set(ALL_COOKIES)) == 9

def test_all_cookies_covers_all_combinations():
    from itertools import product
    expected = {Cookie(c, s) for c, s in product(COLORS, SHAPES)}
    assert set(ALL_COOKIES) == expected

def test_grid_getitem():
    cookies = {(r, c): ALL_COOKIES[r * 3 + c] for r in range(3) for c in range(3)}
    grid = Grid(cookies=cookies)
    assert grid[(0, 0)] == ALL_COOKIES[0]
    assert grid[(2, 2)] == ALL_COOKIES[8]

def test_cell_reveal_both():
    r = CellReveal(color='red', shape='circle')
    assert r.color == 'red'
    assert r.shape == 'circle'

def test_cell_reveal_color_only():
    r = CellReveal(color='red', shape=None)
    assert r.color == 'red'
    assert r.shape is None

def test_cell_reveal_shape_only():
    r = CellReveal(color=None, shape='circle')
    assert r.color is None
    assert r.shape == 'circle'

def test_clue_is_hashable():
    reveals = (((0, 0), CellReveal(color='red', shape=None)),)
    c = Clue(reveals=reveals)
    s = {c, c}
    assert len(s) == 1

def test_clue_items_iteration():
    reveals = (
        ((0, 0), CellReveal(color='red', shape=None)),
        ((0, 1), CellReveal(color=None, shape='circle')),
    )
    clue = Clue(reveals=reveals)
    cells = [cell for cell, _ in clue.items()]
    assert (0, 0) in cells
    assert (0, 1) in cells
```

- [ ] **Step 2: Run tests to confirm they fail**

```
pytest tests/test_model.py -v
```
Expected: `ModuleNotFoundError: No module named 'puzzle'`

- [ ] **Step 3: Implement the data model**

```python
# puzzle/__init__.py
# (empty)
```

```python
# puzzle/model.py
from __future__ import annotations
from dataclasses import dataclass
from typing import Dict, Optional, Tuple

Color = str
Shape = str
Cell  = Tuple[int, int]

COLORS = ('red', 'blue', 'green')
SHAPES = ('circle', 'square', 'triangle')

@dataclass(frozen=True)
class Cookie:
    color: Color
    shape: Shape

ALL_COOKIES: Tuple[Cookie, ...] = tuple(
    Cookie(c, s) for c in COLORS for s in SHAPES
)

@dataclass
class Grid:
    cookies: Dict[Cell, Cookie]

    def __getitem__(self, cell: Cell) -> Cookie:
        return self.cookies[cell]

@dataclass(frozen=True)
class CellReveal:
    color: Optional[Color]
    shape: Optional[Shape]

@dataclass(frozen=True)
class Clue:
    reveals: Tuple[Tuple[Cell, CellReveal], ...]

    def items(self):
        return self.reveals
```

```python
# tests/__init__.py
# (empty)
```

- [ ] **Step 4: Run tests and confirm they pass**

```
pytest tests/test_model.py -v
```
Expected: all 10 tests pass.

---

### Task 2: Shape Generation (extract from notebook)

**Files:**
- Create: `puzzle/shapes.py`
- Create: `tests/test_shapes.py`

- [ ] **Step 1: Write failing tests**

```python
# tests/test_shapes.py
from puzzle.shapes import get_clue_shapes

def test_total_unique_shape_count():
    shapes = get_clue_shapes()
    assert len(shapes) == 294

def test_shapes_by_size():
    from collections import Counter
    shapes = get_clue_shapes()
    counts = Counter(s['size'] for s in shapes)
    assert counts[2] == 4
    assert counts[3] == 20
    assert counts[4] == 58
    assert counts[5] == 90
    assert counts[9] == 1

def test_total_placements_by_size():
    shapes = get_clue_shapes()
    placements_by_size = {}
    for s in shapes:
        placements_by_size.setdefault(s['size'], 0)
        placements_by_size[s['size']] += len(s['placements'])
    assert placements_by_size[2] == 20
    assert placements_by_size[3] == 48

def test_canonical_anchored_at_origin():
    shapes = get_clue_shapes()
    for s in shapes:
        rows = [r for r, c in s['canonical']]
        cols = [c for r, c in s['canonical']]
        assert min(rows) == 0
        assert min(cols) == 0

def test_placements_are_valid_3x3_binary_matrices():
    shapes = get_clue_shapes()
    for s in shapes:
        for matrix in s['placements']:
            assert len(matrix) == 3
            assert all(len(row) == 3 for row in matrix)
            for row in matrix:
                assert all(v in (0, 1) for v in row)

def test_placements_have_correct_cell_count():
    shapes = get_clue_shapes()
    for s in shapes:
        expected_ones = s['size']
        for matrix in s['placements']:
            ones = sum(v for row in matrix for v in row)
            assert ones == expected_ones
```

- [ ] **Step 2: Run tests to confirm they fail**

```
pytest tests/test_shapes.py -v
```
Expected: `ModuleNotFoundError: No module named 'puzzle.shapes'`

- [ ] **Step 3: Extract shape code from notebook into `puzzle/shapes.py`**

```python
# puzzle/shapes.py
from itertools import combinations
from typing import List, Dict, Any

def _is_connected(cells):
    cell_set = set(cells)
    start = next(iter(cell_set))
    visited = {start}
    stack = [start]
    while stack:
        r, c = stack.pop()
        for dr in (-1, 0, 1):
            for dc in (-1, 0, 1):
                if dr == 0 and dc == 0:
                    continue
                nb = (r + dr, c + dc)
                if nb in cell_set and nb not in visited:
                    visited.add(nb)
                    stack.append(nb)
    return len(visited) == len(cells)

def _normalize(cells):
    min_r = min(r for r, c in cells)
    min_c = min(c for r, c in cells)
    return frozenset((r - min_r, c - min_c) for r, c in cells)

def _get_placements(canonical):
    max_r = max(r for r, c in canonical)
    max_c = max(c for r, c in canonical)
    placements = []
    for dr in range(3 - max_r):
        for dc in range(3 - max_c):
            matrix = [[0] * 3 for _ in range(3)]
            for r, c in canonical:
                matrix[r + dr][c + dc] = 1
            placements.append(matrix)
    return placements

def get_clue_shapes() -> List[Dict[str, Any]]:
    """All unique connected clue shapes for a 3×3 grid (sizes 2–9).

    Returns list of dicts with keys:
      'size'       – number of cells
      'canonical'  – frozenset of (row, col), bounding box at (0,0)
      'placements' – list of 3×3 binary matrices
    """
    all_cells = [(r, c) for r in range(3) for c in range(3)]
    seen = set()
    shapes = []
    for size in range(2, 10):
        for combo in combinations(all_cells, size):
            cells = set(combo)
            if not _is_connected(cells):
                continue
            canonical = _normalize(cells)
            if canonical in seen:
                continue
            seen.add(canonical)
            shapes.append({
                'size': size,
                'canonical': canonical,
                'placements': _get_placements(canonical),
            })
    return shapes
```

- [ ] **Step 4: Run tests and confirm they pass**

```
pytest tests/test_shapes.py -v
```
Expected: all 6 tests pass.

---

### Task 3: Clue Enumeration

**Files:**
- Create: `puzzle/clues.py`
- Create: `tests/test_clues.py`

- [ ] **Step 1: Write failing tests**

```python
# tests/test_clues.py
import random
from puzzle.model import Cookie, Grid, ALL_COOKIES, CellReveal
from puzzle.clues import enumerate_clues

def _fixed_solution() -> Grid:
    cookies = {(r, c): ALL_COOKIES[r * 3 + c] for r in range(3) for c in range(3)}
    return Grid(cookies=cookies)

def test_enumerate_returns_clues():
    solution = _fixed_solution()
    clues = enumerate_clues(solution, max_size=2)
    assert len(clues) > 0

def test_size_2_clue_count():
    # 20 placements × 3^2 = 180
    solution = _fixed_solution()
    clues = enumerate_clues(solution, max_size=2, min_size=2)
    assert len(clues) == 180

def test_size_3_clue_count():
    # 48 placements × 3^3 = 1296
    solution = _fixed_solution()
    clues = enumerate_clues(solution, max_size=3, min_size=3)
    assert len(clues) == 1296

def test_reveals_match_solution_color():
    solution = _fixed_solution()
    clues = enumerate_clues(solution, max_size=2)
    for clue in clues:
        for cell, reveal in clue.items():
            cookie = solution[cell]
            if reveal.color is not None:
                assert reveal.color == cookie.color

def test_reveals_match_solution_shape():
    solution = _fixed_solution()
    clues = enumerate_clues(solution, max_size=2)
    for clue in clues:
        for cell, reveal in clue.items():
            cookie = solution[cell]
            if reveal.shape is not None:
                assert reveal.shape == cookie.shape

def test_allowed_info_filter_both_only():
    solution = _fixed_solution()
    clues = enumerate_clues(solution, max_size=2, allowed_info=('both',))
    # Every cell reveal must show both color and shape
    for clue in clues:
        for _, reveal in clue.items():
            assert reveal.color is not None
            assert reveal.shape is not None

def test_allowed_info_filter_partial_only():
    solution = _fixed_solution()
    clues = enumerate_clues(solution, max_size=2, allowed_info=('color', 'shape'))
    for clue in clues:
        for _, reveal in clue.items():
            assert not (reveal.color is not None and reveal.shape is not None)
```

- [ ] **Step 2: Run tests to confirm they fail**

```
pytest tests/test_clues.py -v
```
Expected: `ModuleNotFoundError: No module named 'puzzle.clues'`

- [ ] **Step 3: Implement clue enumeration**

```python
# puzzle/clues.py
from itertools import product
from typing import List, Optional, Tuple
from puzzle.model import Grid, Cookie, CellReveal, Clue, Cell
from puzzle.shapes import get_clue_shapes

INFO_TYPES = ('color', 'shape', 'both')

def enumerate_clues(
    solution: Grid,
    max_size: int = 4,
    min_size: int = 2,
    allowed_info: Tuple[str, ...] = INFO_TYPES,
) -> List[Clue]:
    clues = []
    for shape in get_clue_shapes():
        size = shape['size']
        if size < min_size or size > max_size:
            continue
        for matrix in shape['placements']:
            cells = [
                (r, c)
                for r in range(3) for c in range(3)
                if matrix[r][c] == 1
            ]
            for info_pattern in product(allowed_info, repeat=len(cells)):
                reveals = tuple(
                    (cell, _make_reveal(solution[cell], info))
                    for cell, info in zip(cells, info_pattern)
                )
                clues.append(Clue(reveals=reveals))
    return clues

def _make_reveal(cookie: Cookie, info: str) -> CellReveal:
    return CellReveal(
        color=cookie.color if info in ('color', 'both') else None,
        shape=cookie.shape if info in ('shape', 'both') else None,
    )
```

- [ ] **Step 4: Run tests and confirm they pass**

```
pytest tests/test_clues.py -v
```
Expected: all 7 tests pass.

---

### Task 4: Solver

**Files:**
- Create: `puzzle/solver.py`
- Create: `tests/test_solver.py`

- [ ] **Step 1: Write failing tests**

```python
# tests/test_solver.py
from puzzle.model import Cookie, Grid, CellReveal, Clue, ALL_COOKIES
from puzzle.solver import count_solutions

def _full_reveal_clue(solution: Grid) -> Clue:
    """One clue that reveals the full identity of every cell."""
    reveals = tuple(
        (cell, CellReveal(color=cookie.color, shape=cookie.shape))
        for cell, cookie in solution.cookies.items()
    )
    return Clue(reveals=reveals)

def _fixed_solution() -> Grid:
    return Grid(cookies={(r, c): ALL_COOKIES[r * 3 + c] for r in range(3) for c in range(3)})

def test_no_clues_has_many_solutions():
    assert count_solutions([]) >= 2

def test_fully_constrained_has_one_solution():
    solution = _fixed_solution()
    clue = _full_reveal_clue(solution)
    assert count_solutions([clue]) == 1

def test_fully_constrained_limit_1():
    solution = _fixed_solution()
    clue = _full_reveal_clue(solution)
    assert count_solutions([clue], limit=1) == 1

def test_contradictory_clues_have_zero_solutions():
    # Cell (0,0) cannot be both red and blue
    clues = [
        Clue(reveals=(((0, 0), CellReveal(color='red', shape=None)),)),
        Clue(reveals=(((0, 0), CellReveal(color='blue', shape=None)),)),
    ]
    assert count_solutions(clues) == 0

def test_partial_color_constraint_narrows_solutions():
    unconstrained = count_solutions([])
    clue = Clue(reveals=(((0, 0), CellReveal(color='red', shape=None)),))
    constrained = count_solutions([clue])
    assert constrained < unconstrained

def test_count_stops_at_limit():
    # With no clues, count stops at 2 (doesn't enumerate all 9! permutations)
    import time
    start = time.monotonic()
    count_solutions([], limit=2)
    elapsed = time.monotonic() - start
    assert elapsed < 1.0   # must be fast, not brute-forcing all 362880

def test_solver_consistent_with_solution():
    solution = _fixed_solution()
    clue = _full_reveal_clue(solution)
    # Build a second, different solution to confirm solver isn't just returning 1 always
    other_cookies = list(ALL_COOKIES)
    other_cookies[0], other_cookies[1] = other_cookies[1], other_cookies[0]
    cells = [(r, c) for r in range(3) for c in range(3)]
    other_solution = Grid(cookies=dict(zip(cells, other_cookies)))
    other_clue = _full_reveal_clue(other_solution)
    assert count_solutions([clue, other_clue]) == 0
```

- [ ] **Step 2: Run tests to confirm they fail**

```
pytest tests/test_solver.py -v
```
Expected: `ModuleNotFoundError: No module named 'puzzle.solver'`

- [ ] **Step 3: Implement the solver**

```python
# puzzle/solver.py
from typing import Dict, List, Set
from puzzle.model import Cookie, Cell, Clue, ALL_COOKIES

def count_solutions(clues: List[Clue], limit: int = 2) -> int:
    domains: Dict[Cell, Set[Cookie]] = {
        (r, c): set(ALL_COOKIES) for r in range(3) for c in range(3)
    }
    for clue in clues:
        for cell, reveal in clue.items():
            domains[cell] = {
                k for k in domains[cell]
                if (reveal.color is None or k.color == reveal.color)
                and (reveal.shape is None or k.shape == reveal.shape)
            }

    count = 0

    def backtrack(assigned: Dict[Cell, Cookie], used: Set[Cookie]) -> bool:
        nonlocal count
        if len(assigned) == 9:
            count += 1
            return count >= limit
        cell = min(
            (c for c in domains if c not in assigned),
            key=lambda c: len(domains[c] - used),
        )
        for cookie in list(domains[cell] - used):
            assigned[cell] = cookie
            used.add(cookie)
            if backtrack(assigned, used):
                del assigned[cell]
                used.discard(cookie)
                return True
            del assigned[cell]
            used.discard(cookie)
        return False

    backtrack({}, set())
    return count
```

- [ ] **Step 4: Run tests and confirm they pass**

```
pytest tests/test_solver.py -v
```
Expected: all 7 tests pass.

---

### Task 5: Puzzle Generator

**Files:**
- Create: `puzzle/generator.py`
- Create: `tests/test_generator.py`

- [ ] **Step 1: Write failing tests**

```python
# tests/test_generator.py
import random
from puzzle.model import Grid, Clue, ALL_COOKIES
from puzzle.solver import count_solutions
from puzzle.generator import random_solution, generate_puzzle

def test_random_solution_has_9_cells():
    g = random_solution()
    assert len(g.cookies) == 9

def test_random_solution_has_unique_cookies():
    g = random_solution()
    assert len(set(g.cookies.values())) == 9

def test_random_solution_covers_all_cookies():
    g = random_solution()
    assert set(g.cookies.values()) == set(ALL_COOKIES)

def test_generate_puzzle_is_uniquely_solvable():
    solution, clues = generate_puzzle()
    assert count_solutions(clues) == 1

def test_generated_clues_are_minimal():
    solution, clues = generate_puzzle()
    for i in range(len(clues)):
        remaining = clues[:i] + clues[i + 1:]
        assert count_solutions(remaining) != 1, (
            f"Clue {i} was redundant — puzzle is not minimal"
        )

def test_generate_puzzle_easy_uses_both_only():
    _, clues = generate_puzzle(difficulty='easy')
    for clue in clues:
        for _, reveal in clue.items():
            assert reveal.color is not None and reveal.shape is not None

def test_generate_puzzle_hard_uses_partial_only():
    _, clues = generate_puzzle(difficulty='hard')
    for clue in clues:
        for _, reveal in clue.items():
            assert reveal.color is None or reveal.shape is None

def test_generate_puzzle_reproducible_with_seed():
    random.seed(42)
    _, clues_a = generate_puzzle()
    random.seed(42)
    _, clues_b = generate_puzzle()
    assert clues_a == clues_b
```

- [ ] **Step 2: Run tests to confirm they fail**

```
pytest tests/test_generator.py -v
```
Expected: `ModuleNotFoundError: No module named 'puzzle.generator'`

- [ ] **Step 3: Implement the generator**

```python
# puzzle/generator.py
import random
from typing import List, Tuple
from puzzle.model import Grid, Clue, ALL_COOKIES, Cell
from puzzle.clues import enumerate_clues
from puzzle.solver import count_solutions

_DIFFICULTY_SETTINGS = {
    'easy': {'max_size': 3, 'allowed_info': ('both',)},
    'medium': {'max_size': 4, 'allowed_info': ('color', 'shape', 'both')},
    'hard': {'max_size': 4, 'allowed_info': ('color', 'shape')},
}

def random_solution() -> Grid:
    cookies = list(ALL_COOKIES)
    random.shuffle(cookies)
    cells: List[Cell] = [(r, c) for r in range(3) for c in range(3)]
    return Grid(cookies=dict(zip(cells, cookies)))

def generate_puzzle(difficulty: str = 'medium') -> Tuple[Grid, List[Clue]]:
    settings = _DIFFICULTY_SETTINGS[difficulty]
    solution = random_solution()

    candidates = enumerate_clues(
        solution,
        max_size=settings['max_size'],
        allowed_info=settings['allowed_info'],
    )
    random.shuffle(candidates)

    # Top-down removal: keep only clues that are load-bearing
    active = list(candidates)
    for clue in candidates:
        without = [c for c in active if c is not clue]
        if count_solutions(without) == 1:
            active = without

    return solution, active
```

- [ ] **Step 4: Run tests and confirm they pass**

```
pytest tests/test_generator.py -v
```
Expected: all 8 tests pass. Note: `test_generate_puzzle_easy_uses_both_only` and `test_generate_puzzle_hard_uses_partial_only` may be slow on first run; generation of a full puzzle with `max_size=4` takes a few seconds.

- [ ] **Step 5: Run the full test suite**

```
pytest -v
```
Expected: all 38 tests pass across all 5 test files.

---

## Known Limitations of This Plan

1. **Generation speed:** Top-down removal with `max_size=4` makes up to 8,361 solver calls. Each call is fast (~1 ms worst case), but total generation time could reach ~8 seconds. If this is too slow, profile and reduce `max_size` to 3 or add early-exit heuristics.

2. **Empty puzzle risk:** With `difficulty='hard'` and `allowed_info=('color', 'shape')`, it is possible (though unlikely) that no subset of partial-only clues uniquely determines the solution. Add a fallback to `difficulty='medium'` if the result has `count_solutions(active) != 1`.

3. **Minimality is local:** The top-down greedy removal finds a minimal set under the random traversal order, but a different traversal order might find a smaller minimal set. This is acceptable for a game context.
