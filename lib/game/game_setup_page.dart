import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GameConfig {
  const GameConfig({
    required this.boardSize,
    required this.targetValue,
  });

  final int boardSize;
  final int targetValue;
}

class GameSetupPage extends StatefulWidget {
  const GameSetupPage({super.key});

  @override
  State<GameSetupPage> createState() => _GameSetupPageState();
}

class _GameSetupPageState extends State<GameSetupPage>
    with SingleTickerProviderStateMixin {
  static const List<int> _boardSizes = <int>[4, 5, 6, 7, 8];
  static const List<int> _targets = <int>[
    2048,
    3072,
    4096,
    5120,
    6144,
    7168,
    8192,
    9216,
  ];

  int _boardSize = 5;
  int _targetValue = 9216;
  late final AnimationController _backgroundController;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  Future<void> _setBoardSize(int size) async {
    if (size == _boardSize) return;
    setState(() => _boardSize = size);
    await HapticFeedback.selectionClick();
  }

  Future<void> _setTarget(int value) async {
    if (value == _targetValue) return;
    setState(() => _targetValue = value);
    await HapticFeedback.selectionClick();
  }

  void _startGame() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GamePage(
          config: GameConfig(
            boardSize: _boardSize,
            targetValue: _targetValue,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (BuildContext context, Widget? child) {
        final double t = _backgroundController.value;
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Color.lerp(
                    const Color(0xFFFAF8EF),
                    const Color(0xFFF3E5D0),
                    0.25 + t * 0.10,
                  )!,
                  Color.lerp(
                    const Color(0xFFF5EBDD),
                    const Color(0xFFE7D5BF),
                    0.40 + t * 0.12,
                  )!,
                  const Color(0xFFEEDFCB),
                ],
              ),
            ),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints viewport) {
                  final double width = viewport.maxWidth;
                  final double height = viewport.maxHeight;

                  final double outerPad = max(10.0, min(width, height) * 0.018);
                  final double cardMaxWidth = min(width - outerPad * 2, 680.0);
                  final double cardMaxHeight = height - outerPad * 2;
                  final double shortSide = min(cardMaxWidth, cardMaxHeight);

                  final bool veryCompact = width < 420 || height < 760;
                  final double headerFont = shortSide * (veryCompact ? 0.060 : 0.056);
                  final double sectionFont = shortSide * (veryCompact ? 0.072 : 0.068);
                  final double boardValueFont = shortSide * (veryCompact ? 0.092 : 0.086);
                  final double contentGap = shortSide * (veryCompact ? 0.026 : 0.030);
                  final double innerPad = shortSide * (veryCompact ? 0.040 : 0.044);
                  final double startButtonHeight = shortSide * (veryCompact ? 0.090 : 0.084);
                  final double targetGridWidth = min(cardMaxWidth - innerPad * 2, 460.0);

                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: cardMaxWidth,
                        maxHeight: cardMaxHeight,
                      ),
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        padding: EdgeInsets.all(innerPad),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.32),
                          borderRadius: BorderRadius.circular(shortSide * 0.050),
                          border: Border.all(
                            color: const Color(0xFFA68C72),
                            width: 1.2,
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.10),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: <Widget>[
                            Text(
                              '204819216',
                              style: TextStyle(
                                fontSize: headerFont,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF3C3A32),
                              ),
                            ),
                            SizedBox(height: contentGap * 0.7),
                            Container(
                              height: 1.4,
                              color: const Color(0xFFA68C72),
                            ),
                            SizedBox(height: contentGap),
                            Text(
                              '關卡設定',
                              style: TextStyle(
                                fontSize: sectionFont,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF5C4B3A),
                              ),
                            ),
                            SizedBox(height: contentGap * 0.9),
                            _ResponsiveBoardSizeSelector(
                              boardSizes: _boardSizes,
                              selectedSize: _boardSize,
                              onChanged: _setBoardSize,
                              compact: veryCompact,
                            ),
                            SizedBox(height: contentGap * 0.8),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '$_boardSize X $_boardSize',
                                style: TextStyle(
                                  fontSize: boardValueFont,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF111111),
                                ),
                              ),
                            ),
                            SizedBox(height: contentGap * 0.8),
                            Expanded(
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: targetGridWidth,
                                  ),
                                  child: LayoutBuilder(
                                    builder: (BuildContext context, BoxConstraints gridBox) {
                                      const int rows = 4;
                                      const int cols = 2;
                                      final double spacing = contentGap * 0.55;
                                      final double usableWidth = gridBox.maxWidth;
                                      final double usableHeight = gridBox.maxHeight;
                                      final double buttonWidth =
                                          (usableWidth - spacing * (cols - 1)) / cols;
                                      final double buttonHeight =
                                          max(34.0, (usableHeight - spacing * (rows - 1)) / rows);
                                      final double aspectRatio = buttonWidth / buttonHeight;

                                      return GridView.builder(
                                        padding: EdgeInsets.zero,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: _targets.length,
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: cols,
                                          mainAxisSpacing: spacing,
                                          crossAxisSpacing: spacing,
                                          childAspectRatio: aspectRatio,
                                        ),
                                        itemBuilder: (BuildContext context, int index) {
                                          final int value = _targets[index];
                                          final bool selected = value == _targetValue;
                                          return _TargetButton(
                                            value: value,
                                            selected: selected,
                                            compact: veryCompact || buttonHeight < 54,
                                            fontSize: buttonHeight < 46 ? 12 : (buttonHeight < 58 ? 13 : 15),
                                            onTap: () => _setTarget(value),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: contentGap * 0.6),
                            SizedBox(
                              width: min(targetGridWidth * 0.42, 180.0),
                              height: startButtonHeight,
                              child: FilledButton(
                                onPressed: _startGame,
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF8F7A66),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(shortSide * 0.025),
                                  ),
                                  textStyle: TextStyle(
                                    fontSize: shortSide * (veryCompact ? 0.036 : 0.032),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                child: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text('開始遊戲'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ResponsiveBoardSizeSelector extends StatefulWidget {
  const _ResponsiveBoardSizeSelector({
    required this.boardSizes,
    required this.selectedSize,
    required this.onChanged,
    required this.compact,
  });

  final List<int> boardSizes;
  final int selectedSize;
  final ValueChanged<int> onChanged;
  final bool compact;

  @override
  State<_ResponsiveBoardSizeSelector> createState() => _ResponsiveBoardSizeSelectorState();
}

class _ResponsiveBoardSizeSelectorState extends State<_ResponsiveBoardSizeSelector> {
  void _updatePosition(double localX, double width) {
    final double safeWidth = max(1.0, width);
    final double clamped = localX.clamp(0.0, safeWidth);
    final double step = safeWidth / (widget.boardSizes.length - 1);
    final int index = (clamped / step).round().clamp(0, widget.boardSizes.length - 1);
    widget.onChanged(widget.boardSizes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final double step = width / (widget.boardSizes.length - 1);
        final int selectedIndex = widget.boardSizes.indexOf(widget.selectedSize);
        final double knobSize = widget.compact ? 24 : 28;
        final double labelFont = widget.compact ? 16 : 18;

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapDown: (TapDownDetails details) => _updatePosition(details.localPosition.dx, width),
          onHorizontalDragUpdate: (DragUpdateDetails details) =>
              _updatePosition(details.localPosition.dx, width),
          child: SizedBox(
            height: widget.compact ? 78 : 86,
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: widget.boardSizes.map((int value) {
                      final bool selected = value == widget.selectedSize;
                      return SizedBox(
                        width: widget.compact ? 30 : 36,
                        child: Center(
                          child: Text(
                            '$value',
                            style: TextStyle(
                              fontSize: labelFont,
                              fontWeight: FontWeight.w800,
                              color: selected
                                  ? const Color(0xFF8F7A66)
                                  : const Color(0xFF3C3A32),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: widget.compact ? 34 : 38,
                  child: Container(
                    height: widget.compact ? 8 : 10,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: <Color>[
                          Color(0xFFD9C8B4),
                          Color(0xFFCAB79F),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.07),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                for (int i = 0; i < widget.boardSizes.length; i++)
                  Positioned(
                    left: step * i - 2,
                    top: widget.compact ? 33 : 36,
                    child: Container(
                      width: 4,
                      height: widget.compact ? 10 : 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8F7A66),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.easeOut,
                  left: step * selectedIndex - knobSize / 2,
                  top: widget.compact ? 27 : 29,
                  child: Container(
                    width: knobSize,
                    height: knobSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[
                          Color(0xFFF67C5F),
                          Color(0xFFF65E3B),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.85),
                        width: 2,
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: const Color(0xFFF65E3B).withValues(alpha: 0.34),
                          blurRadius: 12,
                          spreadRadius: 1,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TargetButton extends StatelessWidget {
  const _TargetButton({
    required this.value,
    required this.selected,
    required this.compact,
    required this.fontSize,
    required this.onTap,
  });

  final int value;
  final bool selected;
  final bool compact;
  final double fontSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 8,
          vertical: compact ? 5 : 6,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFF2B179)
              : const Color(0xFFF4EEE5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? const Color(0xFFF59C43)
                : const Color(0xFFD6C6B3),
            width: 1.0,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: selected ? 0.10 : 0.05),
              blurRadius: selected ? 10 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '$value',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: selected ? Colors.white : const Color(0xFF776E65),
            ),
          ),
        ),
      ),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({
    super.key,
    required this.config,
  });

  final GameConfig config;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  final Random _random = Random();
  final FocusNode _keyboardFocusNode = FocusNode();

  late final AnimationController _moveController;
  late final AnimationController _spawnController;
  late final AnimationController _mergeFlashController;

  late List<List<int>> _board;
  int _score = 0;
  int _bestTile = 0;
  bool _gameOver = false;
  bool _gameWon = false;
  bool _isAnimating = false;
  List<_MovingTile> _movingTiles = <_MovingTile>[];
  Set<BoardPoint> _mergedCells = <BoardPoint>{};
  Set<BoardPoint> _spawnedCells = <BoardPoint>{};

  int get _boardSize => widget.config.boardSize;
  int get _targetValue => widget.config.targetValue;

  @override
  void initState() {
    super.initState();
    _moveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _spawnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _mergeFlashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _resetGame();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _keyboardFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    _moveController.dispose();
    _spawnController.dispose();
    _mergeFlashController.dispose();
    super.dispose();
  }

  List<List<int>> _createEmptyBoard() {
    return List<List<int>>.generate(
      _boardSize,
      (_) => List<int>.filled(_boardSize, 0),
      growable: false,
    );
  }

  void _resetGame() {
    _board = _createEmptyBoard();
    _score = 0;
    _bestTile = 0;
    _gameOver = false;
    _gameWon = false;
    _isAnimating = false;
    _movingTiles = <_MovingTile>[];
    _mergedCells = <BoardPoint>{};
    _spawnedCells = <BoardPoint>{};

    final BoardPoint? first = _spawnTile();
    final BoardPoint? second = _spawnTile();
    _spawnedCells = <BoardPoint>{
      if (first != null) first,
      if (second != null) second,
    };
    _bestTile = _highestTile();
    _spawnController.forward(from: 0);
    if (mounted) {
      setState(() {});
      _keyboardFocusNode.requestFocus();
    }
  }

  BoardPoint? _spawnTile() {
    final List<BoardPoint> empty = <BoardPoint>[];
    for (int row = 0; row < _boardSize; row++) {
      for (int col = 0; col < _boardSize; col++) {
        if (_board[row][col] == 0) {
          empty.add(BoardPoint(row, col));
        }
      }
    }
    if (empty.isEmpty) return null;
    final BoardPoint pick = empty[_random.nextInt(empty.length)];
    _board[pick.row][pick.col] = _random.nextInt(10) == 0 ? 4 : 2;
    return pick;
  }

  Future<void> _handleMove(MoveDirection direction) async {
    if (_gameOver || _isAnimating) return;

    final MoveComputation result = _computeMove(direction);
    if (!result.moved) return;

    _isAnimating = true;
    _movingTiles = result.movingTiles;
    _mergedCells = result.mergedCells;
    _spawnedCells = <BoardPoint>{};
    setState(() {});

    await _moveController.forward(from: 0);

    _board = result.board;
    _score += result.scoreGained;
    _bestTile = _highestTile();
    _gameWon = _containsValue(_board, _targetValue);
    _gameOver = !_canMove(_board);
    setState(() {});

    if (_mergedCells.isNotEmpty) {
      await HapticFeedback.mediumImpact();
      await _mergeFlashController.forward(from: 0);
    }

    final BoardPoint? spawned = _gameOver ? null : _spawnTile();
    _spawnedCells = <BoardPoint>{if (spawned != null) spawned};
    _movingTiles = <_MovingTile>[];
    _mergedCells = <BoardPoint>{};
    _bestTile = _highestTile();
    _isAnimating = false;
    _gameWon = _containsValue(_board, _targetValue);
    _gameOver = !_canMove(_board);

    setState(() {});
    if (_spawnedCells.isNotEmpty) {
      await _spawnController.forward(from: 0);
      if (mounted) setState(() {});
    }

    if (_gameWon && mounted) {
      await HapticFeedback.heavyImpact();
      _showResultDialog(isWin: true);
    } else if (_gameOver && mounted) {
      await HapticFeedback.vibrate();
      _showResultDialog(isWin: false);
    }
  }

  MoveComputation _computeMove(MoveDirection direction) {
    final List<List<int>> nextBoard = _createEmptyBoard();
    final List<_MovingTile> movingTiles = <_MovingTile>[];
    final Set<BoardPoint> mergedCells = <BoardPoint>{};
    int gainedScore = 0;
    bool moved = false;

    for (int fixed = 0; fixed < _boardSize; fixed++) {
      final List<BoardPoint> coords = _orderedCoords(direction, fixed);
      final List<_LineTile> cells = <_LineTile>[];

      for (final BoardPoint point in coords) {
        final int value = _board[point.row][point.col];
        if (value != 0) {
          cells.add(_LineTile(value: value, point: point));
        }
      }

      int targetIndex = 0;
      int index = 0;

      while (index < cells.length) {
        final BoardPoint target = coords[targetIndex];

        if (index + 1 < cells.length && cells[index].value == cells[index + 1].value) {
          final int mergedValue = cells[index].value * 2;
          nextBoard[target.row][target.col] = mergedValue;
          gainedScore += mergedValue;
          mergedCells.add(target);

          movingTiles.add(
            _MovingTile(value: cells[index].value, from: cells[index].point, to: target),
          );
          movingTiles.add(
            _MovingTile(value: cells[index + 1].value, from: cells[index + 1].point, to: target),
          );

          if (cells[index].point != target || cells[index + 1].point != target) {
            moved = true;
          }
          index += 2;
          targetIndex += 1;
          continue;
        }

        nextBoard[target.row][target.col] = cells[index].value;
        movingTiles.add(
          _MovingTile(value: cells[index].value, from: cells[index].point, to: target),
        );
        if (cells[index].point != target) {
          moved = true;
        }

        index += 1;
        targetIndex += 1;
      }
    }

    return MoveComputation(
      board: nextBoard,
      moved: moved,
      scoreGained: gainedScore,
      movingTiles: movingTiles,
      mergedCells: mergedCells,
    );
  }

  List<BoardPoint> _orderedCoords(MoveDirection direction, int fixed) {
    switch (direction) {
      case MoveDirection.left:
        return List<BoardPoint>.generate(_boardSize, (int i) => BoardPoint(fixed, i));
      case MoveDirection.right:
        return List<BoardPoint>.generate(
          _boardSize,
          (int i) => BoardPoint(fixed, _boardSize - 1 - i),
        );
      case MoveDirection.up:
        return List<BoardPoint>.generate(_boardSize, (int i) => BoardPoint(i, fixed));
      case MoveDirection.down:
        return List<BoardPoint>.generate(
          _boardSize,
          (int i) => BoardPoint(_boardSize - 1 - i, fixed),
        );
    }
  }

  bool _containsValue(List<List<int>> board, int target) {
    for (final List<int> row in board) {
      if (row.contains(target)) return true;
    }
    return false;
  }

  bool _canMove(List<List<int>> board) {
    for (int row = 0; row < _boardSize; row++) {
      for (int col = 0; col < _boardSize; col++) {
        final int value = board[row][col];
        if (value == 0) return true;
        if (row + 1 < _boardSize && board[row + 1][col] == value) return true;
        if (col + 1 < _boardSize && board[row][col + 1] == value) return true;
      }
    }
    return false;
  }

  int _highestTile() {
    int highest = 0;
    for (final List<int> row in _board) {
      for (final int value in row) {
        highest = max(highest, value);
      }
    }
    return highest;
  }

  Future<void> _showResultDialog({required bool isWin}) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF9F6F2),
          title: Text(isWin ? '過關完成' : '遊戲結束'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('得分：$_score'),
              const SizedBox(height: 8),
              Text('最高數字：$_bestTile'),
              const SizedBox(height: 8),
              Text('盤格：${_boardSize}X$_boardSize'),
              const SizedBox(height: 8),
              Text('目標：$_targetValue'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('返回設定'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
              child: const Text('重新開始'),
            ),
          ],
        );
      },
    );
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    final double velocity = details.primaryVelocity ?? 0;
    if (velocity < -50) {
      _handleMove(MoveDirection.up);
    } else if (velocity > 50) {
      _handleMove(MoveDirection.down);
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final double velocity = details.primaryVelocity ?? 0;
    if (velocity < -50) {
      _handleMove(MoveDirection.left);
    } else if (velocity > 50) {
      _handleMove(MoveDirection.right);
    }
  }

  KeyEventResult _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _handleMove(MoveDirection.up);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _handleMove(MoveDirection.down);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _handleMove(MoveDirection.left);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _handleMove(MoveDirection.right);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Color _tileColor(int value) {
    switch (value) {
      case 2:
        return const Color(0xFFEEE4DA);
      case 4:
        return const Color(0xFFEDE0C8);
      case 8:
        return const Color(0xFFF2B179);
      case 16:
        return const Color(0xFFF59563);
      case 32:
        return const Color(0xFFF67C5F);
      case 64:
        return const Color(0xFFF65E3B);
      case 128:
        return const Color(0xFFEDCF72);
      case 256:
        return const Color(0xFFEDCC61);
      case 512:
        return const Color(0xFFEDC850);
      case 1024:
        return const Color(0xFFEDC53F);
      case 2048:
        return const Color(0xFFEDC22E);
      default:
        if (value == 0) return const Color(0xFFCDC1B4);
        return const Color(0xFF8F7A66);
    }
  }

  Color _tileTextColor(int value) {
    if (value <= 4) return const Color(0xFF776E65);
    return Colors.white;
  }

  double _tileFontSize(int value, double tileSize) {
    final int digits = value.toString().length;
    if (digits <= 2) return tileSize * 0.34;
    if (digits == 3) return tileSize * 0.28;
    if (digits == 4) return tileSize * 0.22;
    return tileSize * 0.17;
  }

  Rect _tileRect(BoardPoint point, double tileSize, double gap) {
    final double left = gap + point.col * (tileSize + gap);
    final double top = gap + point.row * (tileSize + gap);
    return Rect.fromLTWH(left, top, tileSize, tileSize);
  }

  Widget _buildStaticTiles({
    required double boardSide,
    required double tileSize,
    required double gap,
  }) {
    final List<Widget> children = <Widget>[];

    for (int row = 0; row < _boardSize; row++) {
      for (int col = 0; col < _boardSize; col++) {
        final int value = _board[row][col];
        if (value == 0) continue;
        final BoardPoint point = BoardPoint(row, col);
        final Rect rect = _tileRect(point, tileSize, gap);
        final bool spawned = _spawnedCells.contains(point);

        children.add(
          Positioned(
            left: rect.left,
            top: rect.top,
            width: rect.width,
            height: rect.height,
            child: AnimatedBuilder(
              animation: _spawnController,
              builder: (BuildContext context, Widget? child) {
                final double spawnT = spawned
                    ? Curves.easeOutBack.transform(_spawnController.value)
                    : 1;
                final double scale = spawned ? (0.58 + 0.42 * spawnT) : 1;
                return Transform.scale(scale: scale, child: child);
              },
              child: _GameTile(
                value: value,
                color: _tileColor(value),
                textColor: _tileTextColor(value),
                fontSize: _tileFontSize(value, tileSize),
                borderRadius: max(8, tileSize * 0.12),
                highlight: false,
              ),
            ),
          ),
        );
      }
    }

    return SizedBox(
      width: boardSide,
      height: boardSide,
      child: Stack(clipBehavior: Clip.none, children: children),
    );
  }

  Widget _buildMovingTiles({
    required double boardSide,
    required double tileSize,
    required double gap,
  }) {
    return SizedBox(
      width: boardSide,
      height: boardSide,
      child: AnimatedBuilder(
        animation: _moveController,
        builder: (BuildContext context, Widget? child) {
          final double t = Curves.easeInOutCubicEmphasized.transform(_moveController.value);
          final List<Widget> children = <Widget>[];

          for (final _MovingTile tile in _movingTiles) {
            final Rect fromRect = _tileRect(tile.from, tileSize, gap);
            final Rect toRect = _tileRect(tile.to, tileSize, gap);
            final double dx = lerpDouble(fromRect.left, toRect.left, t)!;
            final double dy = lerpDouble(fromRect.top, toRect.top, t)!;
            final double lift = sin(t * pi) * (tileSize * 0.060);
            final double scale = 1 + sin(t * pi) * 0.05;
            final bool merging = _mergedCells.contains(tile.to);

            children.add(
              Positioned(
                left: dx,
                top: dy - lift,
                width: tileSize,
                height: tileSize,
                child: Transform.scale(
                  scale: scale,
                  child: _GameTile(
                    value: tile.value,
                    color: _tileColor(tile.value),
                    textColor: _tileTextColor(tile.value),
                    fontSize: _tileFontSize(tile.value, tileSize),
                    borderRadius: max(8, tileSize * 0.12),
                    highlight: merging,
                  ),
                ),
              ),
            );
          }

          return Stack(clipBehavior: Clip.none, children: children);
        },
      ),
    );
  }

  Widget _buildMergeEffects({
    required double boardSide,
    required double tileSize,
    required double gap,
  }) {
    return SizedBox(
      width: boardSide,
      height: boardSide,
      child: AnimatedBuilder(
        animation: _mergeFlashController,
        builder: (BuildContext context, Widget? child) {
          final double t = _mergeFlashController.value;
          final int phase = (t * 6).floor().clamp(0, 5);
          final bool flashOn = phase.isEven;
          final List<Widget> children = <Widget>[];

          for (final BoardPoint point in _mergedCells) {
            final Rect rect = _tileRect(point, tileSize, gap);
            final double ringScale = 1 + sin(t * pi) * 0.28;
            children.add(
              Positioned(
                left: rect.left,
                top: rect.top,
                width: rect.width,
                height: rect.height,
                child: IgnorePointer(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Positioned.fill(
                        child: Transform.scale(
                          scale: ringScale,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(max(10, tileSize * 0.14)),
                              border: Border.all(
                                color: flashOn
                                    ? Colors.white.withValues(alpha: 0.88)
                                    : Colors.transparent,
                                width: 2.8,
                              ),
                              boxShadow: flashOn
                                  ? <BoxShadow>[
                                      BoxShadow(
                                        color: Colors.white.withValues(alpha: 0.60),
                                        blurRadius: 24,
                                        spreadRadius: 4,
                                      ),
                                    ]
                                  : const <BoxShadow>[],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return Stack(clipBehavior: Clip.none, children: children);
        },
      ),
    );
  }

  Widget _buildFullscreenFlash() {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _mergeFlashController,
          builder: (BuildContext context, Widget? child) {
            final double t = _mergeFlashController.value;
            if (t == 0 || _mergedCells.isEmpty) {
              return const SizedBox.shrink();
            }
            final int phase = (t * 6).floor().clamp(0, 5);
            final bool flashOn = phase.isEven;

            return Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: flashOn ? 0.07 : 0.015),
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.05,
                  colors: <Color>[
                    Colors.white.withValues(alpha: flashOn ? 0.18 : 0.03),
                    Colors.white.withValues(alpha: flashOn ? 0.08 : 0.01),
                    Colors.white.withValues(alpha: 0),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Stack(
        children: <Widget>[
          Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Color(0xFFFAF8EF),
                    Color(0xFFF5EBDD),
                    Color(0xFFEEDBC2),
                  ],
                ),
              ),
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints viewport) {
                    final double width = viewport.maxWidth;
                    final double height = viewport.maxHeight;
                    final bool compact = width < 720;
                    final double outerPadding = compact ? 12 : 16;
                    final double contentWidth = min(width - outerPadding * 2, 960.0);
                    final double headerHeight = compact ? 88 : 76;
                    final double boardSide = min(
                      contentWidth,
                      max(260.0, height - headerHeight - outerPadding * 3),
                    );
                    final double gap = boardSide < 460 ? 8 : 10;
                    final double tileSize = (boardSide - gap * (_boardSize + 1)) / _boardSize;

                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(outerPadding),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: contentWidth),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.42),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: const Color(0xFFD8CCBB)),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.06),
                                      blurRadius: 12,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        '盤格 ${_boardSize}X$_boardSize  ·  目標 $_targetValue',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF776E65),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _InfoCard(label: '分數', value: _score),
                                    const SizedBox(width: 6),
                                    _InfoCard(label: '最高', value: _bestTile),
                                    const SizedBox(width: 8),
                                    FilledButton(
                                      onPressed: _isAnimating ? null : _resetGame,
                                      style: FilledButton.styleFrom(
                                        minimumSize: const Size(86, 34),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        backgroundColor: const Color(0xFF8F7A66),
                                        foregroundColor: Colors.white,
                                        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                                      ),
                                      child: const Text('重新開始'),
                                    ),
                                    const SizedBox(width: 6),
                                    OutlinedButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      style: OutlinedButton.styleFrom(
                                        minimumSize: const Size(86, 34),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                                      ),
                                      child: const Text('返回設定'),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                width: boardSide,
                                height: boardSide,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFBBADA0),
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.12),
                                      blurRadius: 24,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: <Widget>[
                                    for (int row = 0; row < _boardSize; row++)
                                      for (int col = 0; col < _boardSize; col++)
                                        Positioned(
                                          left: gap + col * (tileSize + gap),
                                          top: gap + row * (tileSize + gap),
                                          width: tileSize,
                                          height: tileSize,
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFCDC1B4),
                                              borderRadius: BorderRadius.circular(max(8, tileSize * 0.12)),
                                            ),
                                          ),
                                        ),
                                    if (!_isAnimating)
                                      _buildStaticTiles(
                                        boardSide: boardSide,
                                        tileSize: tileSize,
                                        gap: gap,
                                      ),
                                    if (_isAnimating)
                                      _buildMovingTiles(
                                        boardSide: boardSide,
                                        tileSize: tileSize,
                                        gap: gap,
                                      ),
                                    if (_isAnimating && _mergedCells.isNotEmpty)
                                      _buildMergeEffects(
                                        boardSide: boardSide,
                                        tileSize: tileSize,
                                        gap: gap,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          if (_mergedCells.isNotEmpty) _buildFullscreenFlash(),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.label,
    required this.value,
  });

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 74,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFBBADA0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFFEEE4DA),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$value',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GameTile extends StatelessWidget {
  const _GameTile({
    required this.value,
    required this.color,
    required this.textColor,
    required this.fontSize,
    required this.borderRadius,
    required this.highlight,
  });

  final int value;
  final Color color;
  final Color textColor;
  final double fontSize;
  final double borderRadius;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: highlight ? 0.18 : 0.10),
            blurRadius: highlight ? 18 : 10,
            spreadRadius: highlight ? 2 : 0,
            offset: Offset(0, highlight ? 2 : 6),
          ),
          if (highlight)
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.26),
              blurRadius: 18,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '$value',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

class BoardPoint {
  const BoardPoint(this.row, this.col);

  final int row;
  final int col;

  @override
  bool operator ==(Object other) {
    return other is BoardPoint && other.row == row && other.col == col;
  }

  @override
  int get hashCode => Object.hash(row, col);
}

class MoveComputation {
  const MoveComputation({
    required this.board,
    required this.moved,
    required this.scoreGained,
    required this.movingTiles,
    required this.mergedCells,
  });

  final List<List<int>> board;
  final bool moved;
  final int scoreGained;
  final List<_MovingTile> movingTiles;
  final Set<BoardPoint> mergedCells;
}

class _LineTile {
  const _LineTile({
    required this.value,
    required this.point,
  });

  final int value;
  final BoardPoint point;
}

class _MovingTile {
  const _MovingTile({
    required this.value,
    required this.from,
    required this.to,
  });

  final int value;
  final BoardPoint from;
  final BoardPoint to;
}

enum MoveDirection {
  up,
  down,
  left,
  right,
}
