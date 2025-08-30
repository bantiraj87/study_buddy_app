import 'package:flutter/material.dart';
import '../models/study_pack.dart';

class StudyPackCard extends StatelessWidget {
  final StudyPack studyPack;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onMenuPressed;

  const StudyPackCard({
    Key? key,
    required this.studyPack,
    this.onTap,
    this.onFavoriteToggle,
    this.onMenuPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with favorite and menu
              Row(
                children: [
                  // Difficulty indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: studyPack.difficulty.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: studyPack.difficulty.color.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      studyPack.difficulty.displayName,
                      style: TextStyle(
                        color: studyPack.difficulty.color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Favorite button
                  IconButton(
                    icon: Icon(
                      studyPack.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: studyPack.isFavorite
                          ? Colors.red
                          : Colors.grey,
                      size: 20,
                    ),
                    onPressed: onFavoriteToggle,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                  // Menu button
                  IconButton(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onPressed: onMenuPressed,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Title
              Text(
                studyPack.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              // Subject
              Text(
                studyPack.subject,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Description
              Text(
                studyPack.description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const Spacer(),
              
              // Progress bar
              if (studyPack.progress > 0) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: studyPack.progress,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(studyPack.progress * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Footer with card count and last studied
              Row(
                children: [
                  Icon(
                    Icons.style,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${studyPack.cardCount} cards',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getLastStudiedText(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getLastStudiedText() {
    final now = DateTime.now();
    final difference = now.difference(studyPack.lastStudied).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '${difference}d ago';
    } else {
      return '${(difference / 7).floor()}w ago';
    }
  }
}
