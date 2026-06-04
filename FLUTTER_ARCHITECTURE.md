# Modulor — Flutter Architecture Diagrams

Eight diagrams covering the app from the highest level down to individual runtime mechanics.

---

## 1. App Layer Overview

How the four source layers relate to each other. Arrows mean "depends on / uses".

```mermaid
flowchart TD
    subgraph SCREENS["Screens  (lib/screens/)"]
        WS["WelcomeScreen"]
        PSS["PuzzleSetScreen"]
        LSS["LevelSelectScreen"]
    end

    subgraph WIDGETS["Widgets  (lib/widgets/)"]
        GS["GameScreen"]
        BG["BoardGrid"]
        CS["ClueStrip"]
        CC["ClueCard"]
        TR["Tray"]
        CO["CompletionOverlay"]
        PW["PieceWidget"]
    end

    subgraph MODELS["Models  (lib/models/)"]
        PUZ["Puzzle"]
        CLU["Clue / CellReveal"]
        PCE["Piece / PieceColor / PieceShape"]
        DD["DragData"]
    end

    subgraph DATA["Data  (lib/data/)"]
        AS["AppServices\n(singleton)"]
        PUZZR["PuzzleRepository"]
        PROGR["ProgressRepository"]
        DB[("AppDatabase\nSQLite / Drift")]
        JSON[["assets/puzzles/\nbeginner.json\nintermediate.json\nexpert.json"]]
    end

    subgraph NAV["Navigation  (lib/router.dart)"]
        RT["GoRouter"]
    end

    RT --> SCREENS
    RT --> GS

    GS --> BG & CS & TR & CO
    CS --> CC
    BG --> PW
    TR --> PW
    CC --> PW

    LSS --> AS
    GS --> AS
    AS --> PUZZR & PROGR
    PUZZR --> JSON
    PROGR --> DB
    PUZZR --> PUZ
    PUZ --> CLU & PCE
    DD --> PCE
    BG --> DD
    TR --> DD
```

---

## 2. Navigation Route Graph

Every screen and every navigation action. Labels show what triggers each transition.

```mermaid
flowchart TD
    WS["/\nWelcomeScreen\n─────────────\nSplash animation"]
    PSS["/sets\nPuzzleSetScreen\n─────────────\nDifficulty cards"]
    LSS["/sets/:setId/levels\nLevelSelectScreen\n─────────────\nLevel grid\nlocked · current · completed"]
    GS["/sets/:setId/levels/:levelIndex/play\nGameScreen\n─────────────\nThe puzzle"]

    WS -->|"auto-redirect after 1 s"| PSS
    PSS -->|"tap difficulty card"| LSS
    LSS -->|"tap arrow back"| PSS
    LSS -->|"tap unlocked level"| GS
    GS -->|"PopupMenu → Back to Menu"| PSS
    GS -->|"CompletionOverlay → Next Level\n(new ValueKey forces full rebuild)"| GS
    GS -->|"PopupMenu → Restart\n(setState, no navigation)"| GS
```

---

## 3. GameScreen Widget Tree

The full widget hierarchy inside `GameScreen.build()`. Dashed borders mark widgets defined in separate files.

```mermaid
flowchart TD
    GS["GameScreen\n(StatefulWidget)"]
    SC["Scaffold"]
    SA["SafeArea"]
    STK["Stack"]

    COL["Column"]
    HDR["_buildHeader — Row"]
    IB["IconButton (hint)"]
    TXT["Text — MODULOR"]
    PMB["PopupMenuButton"]

    CS["ClueStrip"]
    SCS["SingleChildScrollView (horizontal)"]
    CROW["Row"]
    CC["ClueCard × N"]

    EXP["Expanded"]
    PAD1["Padding"]
    CTR["Center"]
    BG["BoardGrid"]
    LB1["LayoutBuilder"]
    OUTER["Container (border)"]
    GRID["Column × 3 rows"]
    ROW["Row × 3 cols"]
    DT["DragTarget × 9 cells"]
    CELL["Container (cell)"]
    DRG["Draggable (if piece present)"]
    PW["PieceWidget → CustomPaint"]

    PAD2["Padding"]
    TR["Tray"]
    TRDRG["DragTarget (whole tray)"]
    TRROW["_TrayRow × 2"]
    PBOX["_PieceBox → PieceWidget"]
    BTN["ElevatedButton CHECK\n(if board full)"]

    OVL["CompletionOverlay\n(if _showOverlay)"]

    GS --> SC --> SA --> STK
    STK --> COL
    STK -.->|"Positioned.fill"| OVL

    COL --> HDR
    HDR --> IB & TXT & PMB

    COL --> CS --> SCS --> CROW --> CC

    COL --> EXP --> PAD1 --> CTR --> BG
    BG --> LB1 --> OUTER --> GRID --> ROW --> DT --> CELL --> DRG --> PW

    COL --> PAD2 --> TR
    TR --> TRDRG --> TRROW --> PBOX
    TR -.->|"Stack overlay"| BTN
```

---

## 4. State Fields & Data Flow in GameScreen

The five state fields in `_GameScreenState`, what initialises them, and what mutates them.

```mermaid
flowchart LR
    subgraph STATE["_GameScreenState — mutable fields"]
        F1["_puzzle: Puzzle?"]
        F2["board: List&lt;Piece?&gt;  (9 cells)"]
        F3["tray: List&lt;Piece?&gt;  (9 slots)"]
        F4["_showOverlay: bool"]
        F5["_showNextButton: bool"]
    end

    IS["initState()"] -->|"calls"| LP["_loadPuzzle()"]
    LP -->|"await loadSet()\nsetState"| F1 & F2 & F3

    DROP_B["DragTarget.onAcceptWithDetails\n(board cell)"] -->|"_onDropToBoard()\nsetState — swap pieces"| F2 & F3

    DROP_T["DragTarget.onAcceptWithDetails\n(tray)"] -->|"_onDropToTray()\nsetState — move piece back"| F2 & F3

    CHECK["Tray.onCheck\n(CHECK button)"] -->|"_checkSolution()"| WRONG["showSnackBar\n'Not quite'"]
    CHECK -->|"await markSolved()\nsetState"| F4 & F5

    RESET["PopupMenu → Restart"] -->|"_reset()\nsetState"| F2 & F3 & F4

    STATE -->|"build()"| UI["Widget tree\nre-rendered"]
```

---

## 5. Drag & Drop — Event Sequence

What happens from the moment a finger touches a piece to the moment `setState` is called.

```mermaid
sequenceDiagram
    actor User
    participant Draggable
    participant DragLayer as Flutter Drag Layer
    participant DragTarget
    participant GameScreen

    User->>Draggable: finger down on piece
    Draggable->>DragLayer: mount feedback widget<br/>(follows finger)
    Draggable-->>Draggable: show childWhenDragging<br/>(empty placeholder)

    User->>DragLayer: move finger over DragTarget
    DragLayer->>DragTarget: builder(candidateData=[DragData])
    DragTarget-->>DragTarget: highlight cell<br/>(candidateData.isNotEmpty)

    User->>DragLayer: release finger
    DragLayer->>DragTarget: onAcceptWithDetails(DragData)
    DragTarget->>GameScreen: onDrop(data, targetIndex)

    alt data.fromTray == true
        GameScreen->>GameScreen: tray[data.sourceIndex] = displaced piece
    else data.fromTray == false
        GameScreen->>GameScreen: board[data.sourceIndex] = displaced piece
    end
    GameScreen->>GameScreen: board[targetIndex] = data.piece
    GameScreen->>GameScreen: setState()
    GameScreen-->>User: UI rebuilt with new board/tray state
```

---

## 6. Data Layer — Loading & Persistence

How puzzle data and progress data move through the app.

```mermaid
flowchart TD
    subgraph BOOT["App startup  (main.dart)"]
        MAIN["main()\nWidgetsFlutterBinding.ensureInitialized()"]
    end

    subgraph SVC["AppServices  (singleton)"]
        AS["AppServices.instance"]
    end

    subgraph PUZZR_BOX["PuzzleRepository"]
        PUZZR["loadSet(setId)"]
        CACHE["Map cache\nString → List&lt;Puzzle&gt;"]
        BUNDLE["rootBundle.loadString()\nassets/puzzles/beginner.json\n...intermediate.json\n...expert.json"]
        PARSE["Puzzle.fromJson()\nClue.fromJson()\nCellReveal.fromJson()\nPiece.fromJson()"]
    end

    subgraph PROGR_BOX["ProgressRepository"]
        PROGR["markSolved()\nisSolved()\ncompletedIds()"]
        DRIFT["Drift query builder\ntype-safe, no raw SQL"]
        DB[("SQLite file\nAppDatabase\n─────────────\nPuzzleAttempts\n id · puzzleSet · puzzleId\n levelIndex · attempts · solvedAt")]
    end

    MAIN -->|"await init()"| AS
    AS --> PUZZR & PROGR

    PUZZR -->|"cache miss"| BUNDLE
    BUNDLE --> PARSE --> CACHE
    CACHE -->|"cache hit / freshly loaded"| GS_USE["GameScreen\nLevelSelectScreen"]

    PROGR --> DRIFT --> DB
    DB -->|"read completedIds"| LSS_USE["LevelSelectScreen\n(lock/unlock/done state)"]
    DB -->|"read isSolved"| GS_USE2["GameScreen\n(_showNextButton logic)"]
```

---

## 7. Domain Model — Class Diagram

The complete data model and how the types relate to each other.

```mermaid
classDiagram
    class Puzzle {
        +String id
        +List~Piece~ solution
        +List~Clue~ clues
        +fromJson(json)$ Puzzle
    }

    class Clue {
        +List~CellReveal~ reveals
        +fromJson(json)$ Clue
    }

    class CellReveal {
        +int row
        +int col
        +PieceColor? color
        +PieceShape? shape
        +fromJson(json)$ CellReveal
    }

    class Piece {
        +PieceColor color
        +PieceShape shape
        +fromJson(json)$ Piece
        +operator==(other) bool
        +hashCode int
    }

    class PieceColor {
        <<enumeration>>
        red
        blue
        yellow
    }

    class PieceShape {
        <<enumeration>>
        circle
        square
        triangle
    }

    class DragData {
        +Piece piece
        +bool fromTray
        +int sourceIndex
    }

    Puzzle "1" *-- "9" Piece : solution
    Puzzle "1" *-- "1..*" Clue : clues
    Clue "1" *-- "1..*" CellReveal : reveals
    CellReveal --> PieceColor : optional
    CellReveal --> PieceShape : optional
    Piece --> PieceColor
    Piece --> PieceShape
    DragData --> Piece : carries
```

---

## 8. Flutter's Three Trees

Flutter maintains three parallel trees at runtime. You write the **Widget tree**; Flutter manages the other two. Understanding this explains why `setState` is cheap and why `Key` matters.

```mermaid
flowchart LR
    subgraph WT["Widget Tree  —  YOUR CODE\nimmutable · rebuilt freely"]
        W1["GameScreen"] --> W2["Scaffold"] --> W3["Stack"]
        W3 --> W4["Column"] --> W5["BoardGrid"]
        W5 --> W6["DragTarget"] --> W7["PieceWidget"]
        W7 --> W8["CustomPaint"]
    end

    subgraph ET["Element Tree  —  FLUTTER INTERNAL\npersists across rebuilds · tracks identity"]
        E1["GameScreen\nElement"] --> E2["Scaffold\nElement"] --> E3["Stack\nElement"]
        E3 --> E4["Column\nElement"] --> E5["BoardGrid\nElement"]
        E5 --> E6["DragTarget\nElement"] --> E7["PieceWidget\nElement"]
        E7 --> E8["CustomPaint\nElement"]
    end

    subgraph RT["Render Object Tree  —  FLUTTER INTERNAL\nhandles layout and paint"]
        R1["RenderFlex\n(Column)"] --> R2["RenderFlex\n(Row × 3)"] --> R3["RenderCustomPaint\n(PieceWidget)"]
    end

    WT -->|"setState() triggers\ndiff against"| ET
    ET -->|"only changed nodes\nupdate"| RT
    RT -->|"paint(Canvas)"| SCREEN["Screen pixels"]

    NOTE["Key rule:\nValueKey forces the Element\nto be destroyed + recreated,\nresetting all State.\nWithout a Key, Flutter reuses\nthe existing Element and calls\ndidUpdateWidget() instead."]
```

---

## How the Diagrams Relate

```mermaid
flowchart LR
    D1["① App Layer Overview\nhigh-level module map"]
    D2["② Navigation Graph\nwhich screens exist\nand how you move between them"]
    D3["③ Widget Tree\nwhat GameScreen renders\nand how widgets compose"]
    D4["④ State & Data Flow\nhow user actions mutate state"]
    D5["⑤ Drag & Drop Sequence\none interaction in detail"]
    D6["⑥ Data Layer\nhow puzzles and progress are stored"]
    D7["⑦ Domain Model\nthe data types and their relationships"]
    D8["⑧ Three Trees\nwhy setState works the way it does"]

    D1 --> D2
    D1 --> D6
    D2 --> D3
    D3 --> D4
    D4 --> D5
    D6 --> D7
    D3 --> D8
```
