import math
import matplotlib.pyplot as plt
import matplotlib.patches as patches

COLOR_MAP = {
    'red':   '#E74C3C',
    'blue':  '#3498DB',
    'green': '#2ECC71',
}
INACTIVE_BG   = '#F5F5F5'
INACTIVE_EDGE = '#DDDDDD'
ACTIVE_EDGE   = '#333333'
OUTLINE_COLOR = '#333333'


def show_solution(solution):
    fig, ax = plt.subplots(figsize=(3.5, 3.5))
    _setup_ax(ax, 'Solution')
    for r in range(3):
        for c in range(3):
            cookie = solution[(r, c)]
            _draw_cell(ax, r, c, bg='white', edge=ACTIVE_EDGE)
            _draw_shape(ax, c + 0.5, 2 - r + 0.5, cookie.shape,
                        fill_color=COLOR_MAP[cookie.color], filled=True)
    plt.tight_layout()
    plt.show()


def show_clues(clues):
    n = len(clues)
    ncols = min(n, 4)
    nrows = math.ceil(n / ncols)
    fig, raw_axes = plt.subplots(nrows, ncols, figsize=(ncols * 2.8, nrows * 2.8))

    # Normalise to a flat list regardless of shape
    if n == 1:
        axes = [raw_axes]
    elif nrows == 1:
        axes = list(raw_axes)
    else:
        axes = [ax for row in raw_axes for ax in row]

    for i, clue in enumerate(clues):
        ax = axes[i]
        reveal_map = dict(clue.items())
        _setup_ax(ax, f'Clue {i + 1}')

        for r in range(3):
            for c in range(3):
                cell = (r, c)
                reveal = reveal_map.get(cell)
                cx, cy = c + 0.5, 2 - r + 0.5

                if reveal is None:
                    _draw_cell(ax, r, c, bg=INACTIVE_BG, edge=INACTIVE_EDGE)
                    continue

                show_color = reveal.color is not None
                show_shape = reveal.shape is not None

                if show_color and not show_shape:
                    # Color only: flood the cell background
                    _draw_cell(ax, r, c, bg=COLOR_MAP[reveal.color], edge=ACTIVE_EDGE)

                elif not show_color and show_shape:
                    # Shape only: white cell + outline shape
                    _draw_cell(ax, r, c, bg='white', edge=ACTIVE_EDGE)
                    _draw_shape(ax, cx, cy, reveal.shape,
                                fill_color=None, filled=False)

                else:
                    # Both: white cell + filled colored shape
                    _draw_cell(ax, r, c, bg='white', edge=ACTIVE_EDGE)
                    _draw_shape(ax, cx, cy, reveal.shape,
                                fill_color=COLOR_MAP[reveal.color], filled=True)

    for i in range(n, len(axes)):
        axes[i].set_visible(False)

    plt.tight_layout()
    plt.show()


# ── helpers ──────────────────────────────────────────────────────────────────

def _setup_ax(ax, title):
    ax.set_xlim(0, 3)
    ax.set_ylim(0, 3)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title(title, fontsize=10, pad=4)


def _draw_cell(ax, r, c, bg, edge):
    ax.add_patch(patches.Rectangle(
        (c, 2 - r), 1, 1,
        facecolor=bg, edgecolor=edge, linewidth=1.5, zorder=0,
    ))


def _draw_shape(ax, cx, cy, shape, fill_color, filled, size=0.32):
    fc = fill_color if filled else 'none'
    ec = fill_color if filled else OUTLINE_COLOR
    lw = 2.0

    if shape == 'circle':
        patch = patches.Circle((cx, cy), size, facecolor=fc, edgecolor=ec, linewidth=lw, zorder=1)

    elif shape == 'square':
        patch = patches.Rectangle(
            (cx - size, cy - size), 2 * size, 2 * size,
            facecolor=fc, edgecolor=ec, linewidth=lw, zorder=1,
        )

    elif shape == 'triangle':
        pts = [
            (cx,                    cy + size),
            (cx - size * 0.866,     cy - size * 0.5),
            (cx + size * 0.866,     cy - size * 0.5),
        ]
        patch = patches.Polygon(pts, closed=True, facecolor=fc, edgecolor=ec, linewidth=lw, zorder=1)

    else:
        raise ValueError(f"Unknown shape: {shape!r}")

    ax.add_patch(patch)
