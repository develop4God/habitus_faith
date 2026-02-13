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
  double _dragOffset = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    // Allow dragging down from anywhere, but prioritize scroll if not at top
    if (_scrollController.hasClients && _scrollController.offset <= 0) {
      setState(() {
        _dragOffset += details.primaryDelta!;
        if (_dragOffset < 0) _dragOffset = 0;
      });
    }
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    if (_dragOffset > 150 || details.primaryVelocity! > 500) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _dragOffset = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final mediaQuery = MediaQuery.of(context);

    // Modern layout: Fixed Header (Hero) + Scrolling Content
    // Hero height is smaller (approx 32% of screen)
    final double heroHeight = size.height * 0.32;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onVerticalDragUpdate: _handleVerticalDragUpdate,
        onVerticalDragEnd: _handleVerticalDragEnd,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _dragOffset, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_dragOffset > 0 ? 32 : 0),
            child: Container(
              color: theme.scaffoldBackgroundColor,
              child: Column(
                children: [
                  // 1. FROZEN HERO SECTION (Top)
                  Stack(
                    children: [
                      Container(
                        height: heroHeight,
                        width: double.infinity,
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
                            
                            // Dark Overlay for legibility
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.1),
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                              ),
                            ),

                            // Verse Text Overlay (Centered and Auto-fitted)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(32, 60, 32, 40),
                              child: Center(
                                child: Hero(
                                  tag: 'devotional_verse_${widget.devocional.id}',
                                  child: Material(
                                    color: Colors.transparent,
                                    child: AutoSizeText(
                                      widget.devocional.versiculo,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22 * mediaQuery.textScaleFactor,
                                        fontWeight: FontWeight.w300,
                                        fontStyle: FontStyle.italic,
                                        height: 1.3,
                                        fontFamily: 'Georgia',
                                        shadows: const [
                                          Shadow(color: Colors.black45, blurRadius: 15, offset: Offset(0, 2))
                                        ],
                                      ),
                                      maxLines: 5,
                                      minFontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Floating Back Button (Integrated into Hero Stack)
                      Positioned(
                        top: mediaQuery.padding.top + 8,
                        left: 16,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 2. SCROLLING REFLECTION SECTION (Bottom)
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        // Visual cue that this is a separate sheet
                        boxShadow: [
                          if (_dragOffset == 0)
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, -5),
                            ),
                        ],
                      ),
                      child: ClipRRect(
                        // Slightly overlap rounded corners at the top of the scroll area
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          physics: _dragOffset > 0 
                              ? const NeverScrollableScrollPhysics() 
                              : const BouncingScrollPhysics(),
                          child: DevotionalDetailContent(
                            devocional: widget.devocional,
                            showVerseReference: false,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
