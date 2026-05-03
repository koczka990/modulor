from typing import Dict, List, Set

from puzzle.model import ALL_COOKIES, Cell, Clue, Cookie


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
