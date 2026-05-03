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
