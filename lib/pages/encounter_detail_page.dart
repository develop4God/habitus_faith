// lib/pages/encounter_detail_page.dart
//
// Card-swipe reader for an encounter study.
// Uses a PageView to navigate through cards with staggered transitions.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitus_faith/core/models/encounter_card_model.dart';
import 'package:habitus_faith/core/models/encounter_index_entry.dart';
import 'package:habitus_faith/providers/encounter_provider.dart';

class EncounterDetailPage extends ConsumerStatefulWidget {
  final EncounterIndexEntry entry;
  final String lang;

  const EncounterDetailPage({
    required this.entry,
    required this.lang,
    super.key,
  });

  @override
  ConsumerState<EncounterDetailPage> createState() =>
      _EncounterDetailPageState();
}

class _EncounterDetailPageState extends ConsumerState<EncounterDetailPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final encounterState = ref.watch(encounterProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0a0e1a),
      body: Builder(
        builder: (context) {
          if (encounterState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final study = encounterState.getStudy(widget.entry.id);

          if (study == null) {
            return _buildStudyNotFound();
          }

          final cards = study.cards;
          if (cards.isEmpty) {
            return _buildNoCards();
          }

          return Stack(
            children: [
              // Card PageView
              PageView.builder(
                controller: _pageController,
                itemCount: cards.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                  // Mark completed when last card is reached
                  if (index == cards.length - 1) {
                    ref
                        .read(encounterProvider.notifier)
                        .completeEncounter(widget.entry.id);
                  }
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 100, 16, 120),
                    child: _buildCardWidget(cards[index]),
                  );
                },
              ),

              // Progress lines
              Positioned(
                top: 55,
                left: 24,
                right: 24,
                child: Row(
                  children: List.generate(cards.length, (index) {
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: index <= _currentIndex
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // Close button
              Positioned(
                top: 40,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),

              // Navigation controls
              Positioned(
                bottom: 40,
                left: 24,
                right: 24,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _NavButton(
                      icon: Icons.chevron_left,
                      visible: _currentIndex > 0,
                      onPressed: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                    ),
                    Text(
                      '${_currentIndex + 1} / ${cards.length}',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    _NavButton(
                      icon: Icons.chevron_right,
                      visible: _currentIndex < cards.length - 1,
                      onPressed: () => _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStudyNotFound() {
    return SafeArea(
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white70, size: 28),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const Spacer(),
          const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
          const SizedBox(height: 24),
          Text(
            'Study not found',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              ref
                  .read(encounterProvider.notifier)
                  .loadStudy(widget.entry.id, widget.lang);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildNoCards() {
    return Center(
      child: Text(
        'No cards available',
        style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
      ),
    );
  }

  /// Builds the appropriate card widget based on card type.
  Widget _buildCardWidget(EncounterCard card) {
    final bg = card.imageUrl != null
        ? DecorationImage(
            image: NetworkImage(card.imageUrl!),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.4),
              BlendMode.darken,
            ),
          )
        : null;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: const Color(0xFF0f1828),
        image: bg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: _CardContent(card: card),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card Content
// ---------------------------------------------------------------------------

class _CardContent extends StatelessWidget {
  final EncounterCard card;

  const _CardContent({required this.card});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (card.title != null) ...[
            Text(
              card.title!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                height: 1.2,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (card.narrative != null) ...[
            Text(
              card.narrative!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 17,
                height: 1.65,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 20),
          ],
          if (card.content != null) ...[
            Text(
              card.content!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 17,
                height: 1.65,
              ),
            ),
            const SizedBox(height: 20),
          ],
          if (card.verseReference != null || card.verseText != null) ...[
            _VerseBlock(
              reference: card.verseReference,
              text: card.verseText,
            ),
            const SizedBox(height: 20),
          ],
          if (card.verseOverlay != null) ...[
            _VerseBlock(
              reference: card.verseOverlay!.reference,
              text: card.verseOverlay!.text,
            ),
            const SizedBox(height: 20),
          ],
          if (card.reflection != null) ...[
            _ReflectionBlock(text: card.reflection!),
            const SizedBox(height: 20),
          ],
          if (card.reflectionPrompt != null) ...[
            _ReflectionBlock(text: card.reflectionPrompt!),
            const SizedBox(height: 20),
          ],
          if (card.prayer != null) ...[
            _PrayerBlock(prayer: card.prayer!),
            const SizedBox(height: 20),
          ],
          if (card.discoveryQuestions != null &&
              card.discoveryQuestions!.isNotEmpty) ...[
            _DiscoveryQuestions(questions: card.discoveryQuestions!),
          ],
          if (card.completionVerse != null) ...[
            _CompletionVerseBlock(verse: card.completionVerse!),
          ],
        ],
      ),
    );
  }
}

class _VerseBlock extends StatelessWidget {
  final String? reference;
  final String? text;

  const _VerseBlock({this.reference, this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (text != null)
            Text(
              '"${text!}"',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontStyle: FontStyle.italic,
                height: 1.6,
              ),
            ),
          if (reference != null) ...[
            if (text != null) const SizedBox(height: 8),
            Text(
              '— ${reference!}',
              style: TextStyle(
                color: Colors.amberAccent.withValues(alpha: 0.8),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReflectionBlock extends StatelessWidget {
  final String text;

  const _ReflectionBlock({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: Colors.blueAccent.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline,
              color: Colors.amberAccent.withValues(alpha: 0.8), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerBlock extends StatelessWidget {
  final EncounterPrayer prayer;

  const _PrayerBlock({required this.prayer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite_outline,
                  color: Colors.pinkAccent.withValues(alpha: 0.8), size: 18),
              const SizedBox(width: 8),
              Text(
                prayer.title ?? 'Prayer',
                style: TextStyle(
                  color: Colors.pinkAccent.withValues(alpha: 0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            prayer.content,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 15,
              height: 1.65,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscoveryQuestions extends StatelessWidget {
  final List<EncounterDiscoveryQuestion> questions;

  const _DiscoveryQuestions({required this.questions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'REFLECT & DISCOVER',
          style: TextStyle(
            color: Colors.tealAccent.withValues(alpha: 0.8),
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 12),
        ...questions.map(
          (q) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.tealAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    q.question,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CompletionVerseBlock extends StatelessWidget {
  final EncounterCompletionVerse verse;

  const _CompletionVerseBlock({required this.verse});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withValues(alpha: 0.15),
            Colors.orange.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.star_rounded, color: Colors.amber, size: 32),
          const SizedBox(height: 16),
          Text(
            '"${verse.text}"',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontStyle: FontStyle.italic,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '— ${verse.reference}',
            style: TextStyle(
              color: Colors.amberAccent.withValues(alpha: 0.9),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Navigation button
// ---------------------------------------------------------------------------

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool visible;

  const _NavButton({
    required this.icon,
    required this.onPressed,
    this.visible = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: visible ? 1.0 : 0.0,
      child: GestureDetector(
        onTap: visible ? onPressed : null,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
