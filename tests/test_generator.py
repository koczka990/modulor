import random
from puzzle.model import ALL_COOKIES
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
    _, clues = generate_puzzle()
    assert count_solutions(clues) == 1


def test_generated_clues_are_minimal():
    _, clues = generate_puzzle()
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
