// test/unit/core/models/encounter_models_test.dart
//
// Tests for EncounterIndexEntry, EncounterStudy, and EncounterCard JSON parsing.

import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/models/encounter_card_model.dart';
import 'package:habitus_faith/core/models/encounter_index_entry.dart';
import 'package:habitus_faith/core/models/encounter_study.dart';

void main() {
  // ---------------------------------------------------------------------------
  // EncounterIndexEntry
  // ---------------------------------------------------------------------------

  group('EncounterIndexEntry', () {
    final Map<String, dynamic> fullJson = {
      'id': 'peter_water_001',
      'version': '1.0',
      'emoji': '🌊',
      'status': 'published',
      'mood_primary': 'tense',
      'accent_color': '#0f1828',
      'has_interactive': false,
      'testament': 'new',
      'character': 'Peter',
      'intro_image': 'peter_bg.jpg',
      'files': {'en': 'peter_water_001_en.json', 'es': 'peter_water_001_es.json'},
      'titles': {'en': 'Peter Walks on Water', 'es': 'Pedro Camina sobre el Agua'},
      'subtitles': {'en': 'Faith Beyond the Storm', 'es': 'Fe Más Allá de la Tormenta'},
      'scripture_reference': {'en': 'Matthew 14:22-33', 'es': 'Mateo 14:22-33'},
      'estimated_reading_minutes': {'en': 10, 'es': 10},
    };

    test('fromJson parses all fields correctly', () {
      final entry = EncounterIndexEntry.fromJson(fullJson);

      expect(entry.id, 'peter_water_001');
      expect(entry.version, '1.0');
      expect(entry.emoji, '🌊');
      expect(entry.status, 'published');
      expect(entry.moodPrimary, 'tense');
      expect(entry.accentColor, '#0f1828');
      expect(entry.hasInteractive, false);
      expect(entry.testament, 'new');
      expect(entry.character, 'Peter');
      expect(entry.introImage, 'peter_bg.jpg');
      expect(entry.files['en'], 'peter_water_001_en.json');
      expect(entry.titles['en'], 'Peter Walks on Water');
    });

    test('isPublished returns true for published status', () {
      final entry = EncounterIndexEntry.fromJson(fullJson);
      expect(entry.isPublished, true);
    });

    test('isPublished returns false for coming_soon status', () {
      final json = Map<String, dynamic>.from(fullJson)
        ..['status'] = 'coming_soon';
      final entry = EncounterIndexEntry.fromJson(json);
      expect(entry.isPublished, false);
    });

    test('titleFor returns correct title for language', () {
      final entry = EncounterIndexEntry.fromJson(fullJson);
      expect(entry.titleFor('en'), 'Peter Walks on Water');
      expect(entry.titleFor('es'), 'Pedro Camina sobre el Agua');
    });

    test('titleFor falls back to en when language not found', () {
      final entry = EncounterIndexEntry.fromJson(fullJson);
      expect(entry.titleFor('fr'), 'Peter Walks on Water');
    });

    test('subtitleFor returns correct subtitle', () {
      final entry = EncounterIndexEntry.fromJson(fullJson);
      expect(entry.subtitleFor('en'), 'Faith Beyond the Storm');
    });

    test('scriptureFor returns correct scripture', () {
      final entry = EncounterIndexEntry.fromJson(fullJson);
      expect(entry.scriptureFor('en'), 'Matthew 14:22-33');
      expect(entry.scriptureFor('es'), 'Mateo 14:22-33');
    });

    test('readingMinutesFor returns correct duration', () {
      final entry = EncounterIndexEntry.fromJson(fullJson);
      expect(entry.readingMinutesFor('en'), 10);
    });

    test('readingMinutesFor returns 5 as default when not found', () {
      final entry = EncounterIndexEntry.fromJson(fullJson);
      expect(entry.readingMinutesFor('ja'), 10); // falls back to en
    });

    test('fileFor returns correct filename', () {
      final entry = EncounterIndexEntry.fromJson(fullJson);
      expect(entry.fileFor('en'), 'peter_water_001_en.json');
      expect(entry.fileFor('es'), 'peter_water_001_es.json');
    });

    test('fileFor falls back to en when language missing', () {
      final entry = EncounterIndexEntry.fromJson(fullJson);
      expect(entry.fileFor('fr'), 'peter_water_001_en.json');
    });

    test('toJson round-trip preserves all fields', () {
      final entry = EncounterIndexEntry.fromJson(fullJson);
      final json = entry.toJson();

      expect(json['id'], 'peter_water_001');
      expect(json['version'], '1.0');
      expect(json['status'], 'published');
      expect(json['files'], isA<Map>());
      expect(json['titles']['en'], 'Peter Walks on Water');
    });

    test('fromJson handles minimal JSON gracefully', () {
      final minimal = {
        'id': 'test_001',
        'files': <String, dynamic>{},
        'titles': <String, dynamic>{},
        'subtitles': <String, dynamic>{},
        'scripture_reference': <String, dynamic>{},
        'estimated_reading_minutes': <String, dynamic>{},
      };
      final entry = EncounterIndexEntry.fromJson(minimal);

      expect(entry.id, 'test_001');
      expect(entry.version, '1.0'); // default
      expect(entry.status, 'coming_soon'); // default
      expect(entry.isPublished, false);
    });

    test('fromJson handles missing fields with defaults', () {
      final entry = EncounterIndexEntry.fromJson({});

      expect(entry.id, '');
      expect(entry.version, '1.0');
      expect(entry.status, 'coming_soon');
      expect(entry.files, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // EncounterCard
  // ---------------------------------------------------------------------------

  group('EncounterCard', () {
    test('fromJson parses cinematic_scene type correctly', () {
      final card = EncounterCard.fromJson({
        'order': 1,
        'type': 'cinematic_scene',
        'mood': 'tense',
        'title': 'The Storm',
        'narrative': 'The disciples were terrified...',
      });

      expect(card.order, 1);
      expect(card.type, 'cinematic_scene');
      expect(card.mood, 'tense');
      expect(card.title, 'The Storm');
      expect(card.narrative, 'The disciples were terrified...');
    });

    test('fromJson maps unknown type to unknown', () {
      final card = EncounterCard.fromJson({
        'order': 1,
        'type': 'some_future_type',
      });
      expect(card.type, 'unknown');
    });

    test('fromJson resolves bare image filename to full URL', () {
      final card = EncounterCard.fromJson({
        'order': 1,
        'type': 'cinematic_scene',
        'image_url': 'storm_scene.jpg',
      });
      expect(
        card.imageUrl,
        contains(
            'https://raw.githubusercontent.com/develop4God/Devocionales-assets'),
      );
      expect(card.imageUrl, contains('storm_scene.jpg'));
    });

    test('fromJson keeps absolute https URL as-is', () {
      const absoluteUrl = 'https://example.com/image.jpg';
      final card = EncounterCard.fromJson({
        'order': 1,
        'type': 'cinematic_scene',
        'image_url': absoluteUrl,
      });
      expect(card.imageUrl, absoluteUrl);
    });

    test('fromJson parses verse overlay', () {
      final card = EncounterCard.fromJson({
        'order': 1,
        'type': 'scripture_moment',
        'verse_overlay': {
          'reference': 'Matthew 14:29',
          'text': 'Come, said Jesus.',
        },
      });
      expect(card.verseOverlay, isNotNull);
      expect(card.verseOverlay!.reference, 'Matthew 14:29');
      expect(card.verseOverlay!.text, 'Come, said Jesus.');
    });

    test('fromJson parses discovery questions', () {
      final card = EncounterCard.fromJson({
        'order': 1,
        'type': 'discovery_activation',
        'discovery_questions': [
          {'category': 'personal', 'question': 'When have you doubted?'},
          {'category': 'reflection', 'question': 'What does faith look like?'},
        ],
      });
      expect(card.discoveryQuestions?.length, 2);
      expect(card.discoveryQuestions!.first.category, 'personal');
      expect(card.discoveryQuestions!.first.question, 'When have you doubted?');
    });

    test('fromJson parses prayer', () {
      final card = EncounterCard.fromJson({
        'order': 1,
        'type': 'completion',
        'prayer': {
          'title': 'A Prayer of Faith',
          'content': 'Lord, strengthen my faith...',
        },
      });
      expect(card.prayer, isNotNull);
      expect(card.prayer!.title, 'A Prayer of Faith');
      expect(card.prayer!.content, 'Lord, strengthen my faith...');
    });

    test('fromJson parses completion verse', () {
      final card = EncounterCard.fromJson({
        'order': 5,
        'type': 'completion',
        'completion_verse': {
          'reference': 'Hebrews 11:1',
          'text': 'Now faith is the substance of things hoped for...',
          'bible_version': 'KJV',
        },
      });
      expect(card.completionVerse, isNotNull);
      expect(card.completionVerse!.reference, 'Hebrews 11:1');
      expect(card.completionVerse!.bibleVersion, 'KJV');
    });

    test('toJson round-trip preserves fields', () {
      final card = EncounterCard.fromJson({
        'order': 2,
        'type': 'scripture_moment',
        'title': 'Water Walking',
        'verse_reference': 'Matthew 14:28',
        'verse_text': 'Lord, if it is you, tell me to come to you on the water.',
      });

      final json = card.toJson();
      expect(json['order'], 2);
      expect(json['type'], 'scripture_moment');
      expect(json['title'], 'Water Walking');
      expect(json['verse_reference'], 'Matthew 14:28');
    });

    test('known card types are accepted', () {
      const knownTypes = [
        'cinematic_scene',
        'scripture_moment',
        'character_moment',
        'theological_depth',
        'discovery_activation',
        'completion',
        'interactive_moment',
      ];

      for (final type in knownTypes) {
        final card =
            EncounterCard.fromJson({'order': 1, 'type': type});
        expect(card.type, type,
            reason: 'Type $type should be accepted as-is');
      }
    });
  });

  // ---------------------------------------------------------------------------
  // EncounterStudy
  // ---------------------------------------------------------------------------

  group('EncounterStudy', () {
    final Map<String, dynamic> studyJson = {
      'id': 'peter_water_001',
      'type': 'encounter',
      'schema_version': '1.0',
      'language': 'en',
      'bible_version': 'NIV',
      'version': '1.2',
      'estimated_reading_minutes': 10,
      'key_verse': {
        'reference': 'Matthew 14:30',
        'text': 'Lord, save me!',
      },
      'cards': [
        {
          'order': 1,
          'type': 'cinematic_scene',
          'title': 'The Sea of Galilee',
          'narrative': 'The wind howled across the dark waters...',
        },
        {
          'order': 2,
          'type': 'scripture_moment',
          'verse_reference': 'Matthew 14:25',
          'verse_text': 'Shortly before dawn Jesus went out to them.',
        },
        {
          'order': 3,
          'type': 'completion',
          'title': 'Encounter Complete',
          'completion_verse': {
            'reference': 'Hebrews 11:1',
            'text': 'Now faith is confidence in what we hope for...',
          },
        },
      ],
    };

    test('fromJson parses all top-level fields', () {
      final study = EncounterStudy.fromJson(studyJson);

      expect(study.id, 'peter_water_001');
      expect(study.type, 'encounter');
      expect(study.schemaVersion, '1.0');
      expect(study.language, 'en');
      expect(study.bibleVersion, 'NIV');
      expect(study.version, '1.2');
      expect(study.estimatedReadingMinutes, 10);
    });

    test('fromJson parses key verse', () {
      final study = EncounterStudy.fromJson(studyJson);

      expect(study.keyVerse, isNotNull);
      expect(study.keyVerse!.reference, 'Matthew 14:30');
      expect(study.keyVerse!.text, 'Lord, save me!');
    });

    test('fromJson parses cards list', () {
      final study = EncounterStudy.fromJson(studyJson);

      expect(study.cards.length, 3);
      expect(study.cardCount, 3);
      expect(study.cards.first.type, 'cinematic_scene');
      expect(study.cards.last.type, 'completion');
    });

    test('fromJson returns empty cards list when missing', () {
      final study = EncounterStudy.fromJson({'id': 'test'});
      expect(study.cards, isEmpty);
      expect(study.cardCount, 0);
    });

    test('toJson round-trip preserves id and cards', () {
      final study = EncounterStudy.fromJson(studyJson);
      final json = study.toJson();

      expect(json['id'], 'peter_water_001');
      expect(json['cards'], isA<List>());
      expect((json['cards'] as List).length, 3);
    });
  });

  // ---------------------------------------------------------------------------
  // Sub-models
  // ---------------------------------------------------------------------------

  group('EncounterVerseOverlay', () {
    test('fromJson and toJson round-trip', () {
      final overlay = EncounterVerseOverlay.fromJson({
        'reference': 'John 3:16',
        'text': 'For God so loved the world...',
      });
      expect(overlay.reference, 'John 3:16');
      final json = overlay.toJson();
      expect(json['reference'], 'John 3:16');
    });
  });

  group('EncounterPrayer', () {
    test('fromJson with optional title', () {
      final prayer = EncounterPrayer.fromJson({'content': 'Lord, hear us.'});
      expect(prayer.title, isNull);
      expect(prayer.content, 'Lord, hear us.');
    });

    test('fromJson with title', () {
      final prayer = EncounterPrayer.fromJson(
          {'title': 'Evening Prayer', 'content': 'Guide us.'});
      expect(prayer.title, 'Evening Prayer');
    });
  });

  group('EncounterKeyVerse', () {
    test('fromJson parses correctly', () {
      final verse =
          EncounterKeyVerse.fromJson({'reference': 'Ps 46:1', 'text': 'God is our refuge.'});
      expect(verse.reference, 'Ps 46:1');
      expect(verse.text, 'God is our refuge.');
    });
  });

  group('EncounterDiscoveryQuestion', () {
    test('fromJson parses category and question', () {
      final q = EncounterDiscoveryQuestion.fromJson(
          {'category': 'personal', 'question': 'How does this apply to you?'});
      expect(q.category, 'personal');
      expect(q.question, 'How does this apply to you?');
    });
  });

  group('EncounterScriptureConnection', () {
    test('fromJson round-trip', () {
      final s = EncounterScriptureConnection.fromJson(
          {'reference': 'Isaiah 43:2', 'text': 'When you walk through fire...'});
      expect(s.reference, 'Isaiah 43:2');
      final json = s.toJson();
      expect(json['text'], 'When you walk through fire...');
    });
  });

  group('EncounterCompletionVerse', () {
    test('fromJson with bible_version', () {
      final v = EncounterCompletionVerse.fromJson({
        'reference': 'Heb 11:1',
        'text': 'Faith is the substance...',
        'bible_version': 'KJV',
      });
      expect(v.bibleVersion, 'KJV');
    });

    test('fromJson without bible_version', () {
      final v = EncounterCompletionVerse.fromJson(
          {'reference': 'Heb 11:1', 'text': 'Faith is...'});
      expect(v.bibleVersion, isNull);
    });
  });
}
