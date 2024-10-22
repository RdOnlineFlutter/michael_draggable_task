import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Draggable Dock',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DockScreen(),
    );
  }
}

class DockScreen extends StatefulWidget {
  const DockScreen({Key? key}) : super(key: key);

  @override
  _DockScreenState createState() => _DockScreenState();
}

class _DockScreenState extends State<DockScreen> {
  List<String> icons = ['A', 'B', 'C', 'D', 'E'];
  int? draggedIndex;
  Offset dragOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Draggable Dock'),
      ),
      body: Center(
        child: SizedBox(
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(icons.length, (index) {
              return DraggableIcon(
                iconLabel: icons[index],
                onReorder: (newIndex) {
                  setState(() {
                    final item = icons.removeAt(draggedIndex!);
                    icons.insert(newIndex, item);
                    draggedIndex = null; // Reset dragged index after reordering
                  });
                },
                index: index,
                draggedIndex: draggedIndex,
                onDragStart: (index, offset) {
                  setState(() {
                    draggedIndex = index;
                    dragOffset = offset;
                  });
                },
              );
            }),
          ),
        ),
      ),
    );
  }
}

class DraggableIcon extends StatefulWidget {
  final String iconLabel;
  final ValueChanged<int> onReorder;
  final int index;
  final int? draggedIndex;
  final Function(int, Offset) onDragStart;

  const DraggableIcon({
    Key? key,
    required this.iconLabel,
    required this.onReorder,
    required this.index,
    this.draggedIndex,
    required this.onDragStart,
  }) : super(key: key);

  @override
  _DraggableIconState createState() => _DraggableIconState();
}

class _DraggableIconState extends State<DraggableIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  double startDragX = 0;
  bool isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(_controller);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      isDragging = true;
      final delta = details.localPosition.dx - startDragX;
      int newIndex = (widget.index + (delta / 60).round())
          .clamp(0, 4); // Adjust slot positions based on icon width
      if (newIndex != widget.index) {
        widget.onReorder(newIndex);
      }
    });
  }

  void _onDragEnd() {
    setState(() {
      isDragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offsetAnimation,
      builder: (context, child) {
        return GestureDetector(
          onHorizontalDragStart: (details) {
            startDragX = details.localPosition.dx;
            widget.onDragStart(widget.index, details.localPosition);
          },
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: (_) => _onDragEnd(),
          child: Transform.translate(
            offset: isDragging
                ? Offset(_offsetAnimation.value.dx, 0)
                : Offset.zero,
            child: Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: widget.draggedIndex == widget.index
                    ? Colors.blueAccent
                    : Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  widget.iconLabel,
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
