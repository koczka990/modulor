from puzzle.shapes import get_clue_shapes, _is_connected


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
