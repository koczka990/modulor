from itertools import product
from typing import List, Tuple

from puzzle.model import Cell, CellReveal, Clue, Cookie, Grid
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
