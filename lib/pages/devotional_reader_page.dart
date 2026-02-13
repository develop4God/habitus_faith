import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../core/models/devocional_model.dart';
import '../widgets/devotional_detail_content.dart';

class DevotionalReaderPage extends ConsumerStatefulWidget {
  final Devocional devocional;
  final String? imageUrl;

  const DevotionalReaderPage({
    super.key,
    required this.devocional,
    this.imageUrl,
  });

  @override
  ConsumerState<DevotionalReaderPage> createState() => _DevotionalReaderPageState();
}

class _DevotionalReaderPageState extends ConsumerState<DevotionalReaderPage> {
  final ScrollController _scrollController = ScrollController();
  bool _canDismiss = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // Only allow dismissal if we are at the top of the scroll
    if (_scrollController.offset <= 0) {
      if (!_canDismiss) setState(() => _canDismiss = true);
    } else {
      if (_canDismiss) setState(() => _canDismiss = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black, // Dark background for the "pop" transition
      body: Dismissible(
        key: const Key('devotional_reader_dismissible'),
        direction: _canDismiss ? DismissDirection.down : DismissDirection.none,
        onDismissed: (_) => Navigator.of(context).pop(),
        child: Container(
          color: theme.scaffoldBackgroundColor, // Re-apply theme background
          child: Stack(
            children: [
              // 1. Fixed Background Hero Section
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: size.height * 0.45,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (widget.imageUrl != null)
                      Hero(
                        tag: 'devotional_image_${widget.devocional.id}',
                        child: Image.network(
                          widget.imageUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade900, Colors.indigo.shade900],
                          ),
                        ),
                      ),
                    
                    // Dark Overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.1),
                            Colors.black.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    ),

                    // Verse Overlay
                    Padding(
                      padding: const EdgeInsets.fromLTRB(32, 60, 32, 60),
                      child: Center(
                        child: Hero(
                          tag: 'devotional_verse_${widget.devocional.id}',
                          child: Material(
                            color: Colors.transparent,
                            child: AutoSizeText(
                              widget.devocional.versiculo,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w300,
                                fontStyle: FontStyle.italic,
                                height: 1.3,
                                fontFamily: 'Georgia',
                                shadows: [
                                  Shadow(color: Colors.black45, blurRadius: 15, offset: Offset(0, 2))
                                ],
                              ),
                              maxLines: 6,
                              minFontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Scrolling Content Sheet
              Positioned.fill(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Transparent spacer to allow seeing the background
                      SizedBox(height: size.height * 0.38),
                      
                      // The actual content card
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, -5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Handle bar for visual cue
                            const SizedBox(height: 12),
                            Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            
                            // Devotional Content (Optimized Reusable Widget)
                            DevotionalDetailContent(
                              devocional: widget.devocional,
                              showVerseReference: false,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Floating Back Button
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
