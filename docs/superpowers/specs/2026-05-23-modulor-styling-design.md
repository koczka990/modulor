# Modulor App Styling Design

**Date:** 2026-05-23  
**Scope:** Visual restyling of the Flutter app to match the provided design reference. No game logic or mechanics changes.

---

## Color Palette

| Role | Hex | Usage |
|------|-----|-------|
| Background | `#f8f9fa` | App/cell background |
| Surface Container | `#edeeef` | Tray background |
| Primary (red) | `#b7102a` | App title, active buttons, piece color |
| Secondary Container (yellow) | `#ffd167` | Piece color, Clue B header |
| Tertiary Container (teal) | `#007ea4` | Piece color, Clue C header |
| Ink / Border | `#191c1d` | All borders, text |

**Piece color remapping** (model unchanged):
- `PieceColor.red` → `#b7102a`
- `PieceColor.blue` → `#007ea4`
- `PieceColor.green` → `#ffd167`

All shapes get a 2px `#191c1d` outline stroke in addition to fill.

---

## Typography

Add `google_fonts` package to `pubspec.yaml`.

- **Headlines / body:** Archivo Narrow (bold, uppercase where applicable)
- **Labels / clue names:** JetBrains Mono

---

## Top App Bar

- Height: 64px, 2px bottom border (`#191c1d`)
- Left: lightbulb `Icon` button — HINT (no-op stub)
- Center: "MODULOR" in Archivo Narrow, bold, uppercase, primary color (`#b7102a`)
- Right: settings `PopupMenuButton` with:
  - **Restart** — calls existing `_reset()` (functional)
  - **Back to Menu** — visual stub (no-op)
  - **Settings** — visual stub (no-op)

---

## Clue Strip & Clue Cards

**ClueStrip:** horizontal `SingleChildScrollView`, no scrollbar.

**ClueCard (compact grid):**
- Compute bounding box of `reveals` (min row, max row, min col, max col)
- Render only that bounding box as a grid — empty cells within it show as blank white
- This naturally handles diagonal, L-shape, zigzag, and other patterns
- Colored label banner at top of card, cycling by index:
  - 0 → primary red (`#b7102a`), white text
  - 1 → secondary container yellow (`#ffd167`), dark text
  - 2 → tertiary container teal (`#007ea4`), white text
  - (repeats for more clues)
- Label text: "CLUE A", "CLUE B", etc. in JetBrains Mono, uppercase, small
- Card outer border: 2px `#191c1d`
- Cell borders: 1px `#191c1d`

---

## Board Grid

- Constrained to full width, square (aspect ratio 1:1), max ~400px
- Outer border: 4px `#191c1d`
- Inner cell borders: 2px `#191c1d`
- Cell background: `#f8f9fa` (background)
- Drag-over highlight: yellow tint (`#ffd167` at 30% opacity)

---

## Tray

- Background: `#edeeef` (surface container)
- Outer border: 4px `#191c1d`
- Each piece wrapped in a white box with 2px `#191c1d` border
- Pieces arranged in the existing `Wrap` (drag-and-drop mechanics unchanged)
- Spacing: 8px between pieces, 12px padding

---

## Piece Widget

`PieceWidget` / `_PiecePainter` changes:
- Updated fill colors per remapping above
- Add stroke outline: 2px `#191c1d` on all shapes (circle, square, triangle)
- Padding kept at 10% of cell size

---

## Files to Change

| File | Change |
|------|--------|
| `pubspec.yaml` | Add `google_fonts` dependency |
| `lib/main.dart` | Update `MaterialApp` theme to use new color scheme |
| `lib/widgets/game_screen.dart` | Replace header row with styled `AppBar`; add `PopupMenuButton` |
| `lib/widgets/clue_card.dart` | Compact bounding-box grid, colored label header |
| `lib/widgets/board_grid.dart` | Thicker borders, updated colors, full-width square layout |
| `lib/widgets/tray.dart` | New background, bordered piece boxes |
| `lib/widgets/piece_widget.dart` | New colors, add outline stroke |
