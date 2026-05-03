from itertools import combinations
from typing import Any, Dict, List


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
