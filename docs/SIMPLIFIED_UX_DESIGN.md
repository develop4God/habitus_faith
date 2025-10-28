# Simplified UX Design - Visual Mockup

This document shows the new simplified design based on user feedback.

## New Simplified Design

```
┌─────────────────────────────────────────┐
│  Mis Hábitos                           │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────┐   │
│  │▓│ □  Morning Prayer              │   │  ← Checkbox + colored border
│  │▓│    Start each day with prayer  │   │
│  │▓│    🔥 5 días                   │   │  ← Simple streak indicator
│  │▓│                                │   │
│  │▓│  M  T  W  T  F  S  S           │   │  ← Mini calendar
│  │▓│  ●  ●  ○  ●  ●  ○  ○           │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │▓│ ☑  Daily Bible Reading  ⭐⭐⭐│   │  ← Checked + difficulty
│  │▓│    Read one chapter            │   │
│  │▓│    🔥 3 días                   │   │
│  │▓│                                │   │
│  │▓│  M  T  W  T  F  S  S           │   │
│  │▓│  ●  ●  ○  ●  ○  ○  ○           │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │▓│ □  Gratitude Journal      ⭐  │   │  ← Easy difficulty
│  │▓│    Write 3 things I'm grateful│   │
│  │▓│    🔥 2 días                   │   │
│  │▓│                                │   │
│  │▓│  M  T  W  T  F  S  S           │   │
│  │▓│  ●  ○  ○  ●  ○  ○  ○           │   │
│  └─────────────────────────────────┘   │
│                                         │
└─────────────────────────────────────────┘
                    [+]
```

## Add Habit Dialog (Simplified)

```
┌─────────────────────────────────────────┐
│  Agregar Hábito                         │
├─────────────────────────────────────────┤
│                                         │
│  Nombre                                 │
│  ┌─────────────────────────────────┐   │
│  │ Morning Meditation              │   │
│  └─────────────────────────────────┘   │
│                                         │
│  Descripción                            │
│  ┌─────────────────────────────────┐   │
│  │ 10 minutes of quiet meditation  │   │
│  │                                 │   │
│  └─────────────────────────────────┘   │
│                                         │
│  Categoría                              │
│  ┌─────────────────────────────────┐   │
│  │ ❤️  Espiritual              ▼  │   │
│  └─────────────────────────────────┘   │
│                                         │
│  Dificultad                             │
│  ┌────────┐  ┌────────┐  ┌────────┐   │
│  │   ⭐   │  │ ⭐⭐   │  │ ⭐⭐⭐ │   │
│  │ Fácil  │  │ Medio  │  │ Difícil│   │
│  └────────┘  └────────┘  └────────┘   │
│      ✓                                 │
│                                         │
│  Color (opcional)                       │
│  ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐              │
│  │✓│ │○│ │○│ │○│ │○│ │○│              │
│  └─┘ └─┘ └─┘ └─┘ └─┘ └─┘              │
│  Por  Púr  Azul Rojo Ámbar Verde       │
│  def                                   │
│                                         │
│  ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐              │
│  │○│ │○│ │○│ │○│ │○│ │○│              │
│  └─┘ └─┘ └─┘ └─┘ └─┘ └─┘              │
│  Índigo Rosa Viol Cián Lima Naranja    │
│                                         │
│                [Cancelar]  [Agregar]   │
│                                         │
└─────────────────────────────────────────┘
```

## Key Design Changes

### Before vs After

**Before:**
- Complex category grouping with gradient headers
- Large cards with emoji containers (64x64)
- Weekly progress bars and percentages
- Two streak badges (current + best)
- Full-width "Tap to complete" button
- Complex multi-row layout

**After:**
- Simple flat list of habits
- Checkbox-based completion (28x28)
- Colored left border (4px)
- Single streak indicator when > 0
- Strike-through for completed habits
- Minimal, clean card design

### Visual Simplification

1. **Checkbox Interaction**
   - Left-aligned checkbox (28x28)
   - Empty square for incomplete
   - Filled with checkmark for completed
   - Color matches habit color

2. **Colored Border**
   - 4px left border
   - Uses habit color (category or custom)
   - Rounded corners match card

3. **Card Content**
   - Name (16px, semi-bold)
   - Description (13px, gray, 1 line)
   - Streak if > 0 (🔥 icon + days)
   - Difficulty stars on right (only if not medium)

4. **Completed State**
   - Checkbox filled with color
   - White checkmark icon
   - Name has strike-through
   - Grayed out text

5. **Calendar Heatmap**
   - Stays below each card
   - Shows last 7 days
   - Compact design

### Difficulty Selector (Dialog)

**Visual Star-Based:**
```
┌────────┐  ┌────────┐  ┌────────┐
│   ⭐   │  │ ⭐⭐   │  │ ⭐⭐⭐ │
│ Fácil  │  │ Medio  │  │ Difícil│
└────────┘  └────────┘  └────────┘
```

- Each option shows visual stars
- Selected option has colored background/border
- Uses category color for visual feedback
- More intuitive than segmented buttons

### Benefits

1. **Simpler** - Less visual clutter
2. **Familiar** - Checkbox pattern is universal
3. **Focused** - Each habit is clear and distinct
4. **Cleaner** - Removed complex progress tracking
5. **Faster** - Easier to scan and interact with

### Typography & Spacing

- Name: 16px, FontWeight.w600
- Description: 13px, gray
- Streak: 12px, gray700
- Card padding: 16px all around
- Card margin: 12px bottom
- Border radius: 12px
- Left border: 4px

### Colors

Each habit uses its category color or custom color:
- Prayer: Purple (#9333EA)
- Bible Reading: Blue (#2563EB)
- Service: Red (#EF4444)
- Gratitude: Amber (#F59E0B)
- Other: Indigo (#6366F1)
- +12 custom colors available
