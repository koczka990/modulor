import random
from typing import List, Tuple

from puzzle.clues import enumerate_clues
from puzzle.model import ALL_COOKIES, Cell, Clue, Grid
from puzzle.solver import count_solutions

_DIFFICULTY_SETTINGS = {
    'easy':   {'max_size': 3, 'allowed_info': ('both',)},
    'medium': {'max_size': 4, 'allowed_info': ('color', 'shape', 'both')},
    'hard':   {'max_size': 4, 'allowed_info': ('color', 'shape')},
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

    # Phase 1: greedily add clues until the puzzle is uniquely solvable.
    # This produces a small sufficient set (~10–30 clues) rather than working
    # with the full candidate pool of thousands.
    sufficient: List[Clue] = []
    for clue in candidates:
        sufficient.append(clue)
        if count_solutions(sufficient) == 1:
            break

    # Phase 2: top-down removal on the small sufficient set only.
    active = list(sufficient)
    for clue in sufficient:
        without = [c for c in active if c is not clue]
        if count_solutions(without) == 1:
            active = without

    return solution, active
