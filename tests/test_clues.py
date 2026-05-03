from puzzle.model import ALL_COOKIES, Grid
from puzzle.clues import enumerate_clues


def _fixed_solution() -> Grid:
    return Grid(cookies={(r, c): ALL_COOKIES[r * 3 + c] for r in range(3) for c in range(3)})


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
