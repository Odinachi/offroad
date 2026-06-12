import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SwipeableChatItem extends StatelessWidget {
  final Widget child;
  final VoidCallback onDelete;
  final double bottomMargin;

  const SwipeableChatItem({
    super.key,
    required this.child,
    required this.onDelete,
    this.bottomMargin = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Slidable(
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.22,
        children: [
          CustomSlidableAction(
            onPressed: (context) => onDelete(),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            padding: EdgeInsets.zero,
            child: Container(
              margin: EdgeInsets.only(bottom: bottomMargin, left: 8.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
      child: child,
    );
  }
}
