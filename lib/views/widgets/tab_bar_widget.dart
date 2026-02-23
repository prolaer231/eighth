import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/editor_controller.dart';

class TabBarWidget extends StatelessWidget {
  const TabBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final editorController = context.watch<EditorController>();
    if (editorController.openedFiles.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 40,
      color: Theme.of(context).cardColor,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: editorController.openedFiles.length,
        itemBuilder: (context, index) {
          final file = editorController.openedFiles[index];
          final isActive = editorController.activeTabIndex == index;

          return InkWell(
            onTap: () => editorController.setActiveTab(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color:
                    isActive
                        ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                        : Colors.transparent,
                border: Border(
                  bottom: BorderSide(
                    color:
                        isActive
                            ? Theme.of(context).primaryColor
                            : Colors.transparent,
                    width: 2,
                  ),
                  right: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    file.name,
                    style: TextStyle(
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive ? Theme.of(context).primaryColor : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => editorController.closeFile(index),
                    child: const Icon(Icons.close, size: 16),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
