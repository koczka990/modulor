from puzzle.model import ALL_COOKIES, CellReveal, Clue, Grid
from puzzle.solver import count_solutions


def _fixed_solution() -> Grid:
    return Grid(cookies={(r, c): ALL_COOKIES[r * 3 + c] for r in range(3) for c in range(3)})


def _full_reveal_clue(solution: Grid) -> Clue:
    reveals = tuple(
        (cell, CellReveal(color=cookie.color, shape=cookie.shape))
        for cell, cookie in solution.cookies.items()
    )
    return Clue(reveals=reveals)


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
    clues = [
        Clue(reveals=(((0, 0), CellReveal(color='red', shape=None)),)),
        Clue(reveals=(((0, 0), CellReveal(color='blue', shape=None)),)),
    ]
    assert count_solutions(clues) == 0


def test_constraints_monotonically_narrow_solutions():
    solution = _fixed_solution()
    items = list(solution.cookies.items())
    # Pinning 7 cells leaves exactly 2 solutions (last 2 cookies can swap)
    clue_7 = Clue(reveals=tuple(
        (cell, CellReveal(color=c.color, shape=c.shape)) for cell, c in items[:7]
    ))
    assert count_solutions([clue_7]) == 2
    # Pinning the 8th cell leaves exactly 1 solution
    clue_8 = Clue(reveals=tuple(
        (cell, CellReveal(color=c.color, shape=c.shape)) for cell, c in items[:8]
    ))
    assert count_solutions([clue_8]) == 1


def test_count_stops_at_limit():
    import time
    start = time.monotonic()
    count_solutions([], limit=2)
    elapsed = time.monotonic() - start
    assert elapsed < 1.0


def test_solver_consistent_with_solution():
    solution = _fixed_solution()
    clue = _full_reveal_clue(solution)
    # Swap two cookies to create a different solution
    other_cookies = list(ALL_COOKIES)
    other_cookies[0], other_cookies[1] = other_cookies[1], other_cookies[0]
    cells = [(r, c) for r in range(3) for c in range(3)]
    other_solution = Grid(cookies=dict(zip(cells, other_cookies)))
    other_clue = _full_reveal_clue(other_solution)
    assert count_solutions([clue, other_clue]) == 0
