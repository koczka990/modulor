from itertools import product
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
