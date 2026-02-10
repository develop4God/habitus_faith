# Gamification UI - Visual Design Reference

## New Gamification Section on Home Page

```
┌─────────────────────────────────────────────────────────────┐
│  🏆 Your Faith Journey                                      │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────────────────┐  ┌──────────────────────────┐ │
│  │  ╔═══════════════════╗   │  │  ╔═══════════════════╗   │ │
│  │  ║   PURPLE GRADIENT ║   │  │  ║  ORANGE GRADIENT  ║   │ │
│  │  ║   (Deep Purple)   ║   │  │  ║  (Deep Orange)    ║   │ │
│  │  ╠═══════════════════╣   │  │  ╠═══════════════════╣   │ │
│  │  ║                   ║   │  │  ║                   ║   │ │
│  │  ║  ┌─────────────┐  ║   │  │  ║  ┌─────────────┐  ║   │ │
│  │  ║  │ ✨ Icon     │  ║   │  │  ║  │ 🧠 Icon     │  ║   │ │
│  │  ║  └─────────────┘  ║   │  │  ║  └─────────────┘  ║   │ │
│  │  ║                   ║   │  │  ║                   ║   │ │
│  │  ║                   ║   │  │  ║                   ║   │ │
│  │  ║                   ║   │  │  ║                   ║   │ │
│  │  ║                   ║   │  │  ║                   ║   │ │
│  │  ║  Faith            ║   │  │  ║  Task             ║   │ │
│  │  ║  Journey          ║   │  │  ║  Spinner          ║   │ │
│  │  ║                   ║   │  │  ║                   ║   │ │
│  │  ║  Track progress → ║   │  │  ║  Spin for task →  ║   │ │
│  │  ╚═══════════════════╝   │  │  ╚═══════════════════╝   │ │
│  └──────────────────────────┘  └──────────────────────────┘ │
│         Tap to navigate             Tap to navigate         │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## Color Scheme

### Faith Journey Card (Left)
```
Background Gradient:
  ┌─ Colors.purple.shade400 (#AB47BC)
  │
  │  Diagonal gradient
  │  from top-left
  │  to bottom-right
  │
  └─ Colors.purple.shade600 (#8E24AA)

Icon Container:
  - Background: White 20% opacity (frosted glass effect)
  - Icon: auto_awesome (✨)
  - Color: White
  - Size: 28px

Text:
  - Title: "Faith\nJourney" (Bold, 18px, White)
  - Subtitle: "Track progress →" (Medium, 12px, White 80%)

Shadow:
  - Color: Purple 200 with 50% alpha
  - Blur: 12px
  - Offset: (0, 6)
```

### Task Spinner Card (Right)
```
Background Gradient:
  ┌─ Colors.orange.shade400 (#FFA726)
  │
  │  Diagonal gradient
  │  from top-left
  │  to bottom-right
  │
  └─ Colors.deepOrange.shade500 (#FF6E40)

Icon Container:
  - Background: White 20% opacity (frosted glass effect)
  - Icon: psychology (🧠)
  - Color: White
  - Size: 28px

Text:
  - Title: "Task\nSpinner" (Bold, 18px, White)
  - Subtitle: "Spin for task →" (Medium, 12px, White 80%)

Shadow:
  - Color: Orange 200 with 50% alpha
  - Blur: 12px
  - Offset: (0, 6)
```

## Layout Specifications

```
Gamification Section:
├─ Padding: 20px horizontal
├─ Spacing: 20px vertical margins
│
├─ Header Row:
│  ├─ Icon: emoji_events (🏆) - Purple 600
│  ├─ Spacing: 8px
│  └─ Text: "Your Faith Journey" (Bold, 20px, Grey 800)
│
├─ Spacing: 12px
│
└─ Cards Row:
   ├─ Faith Journey Card
   │  ├─ Width: 50% (Expanded)
   │  ├─ Height: 160px
   │  ├─ Border Radius: 20px
   │  ├─ Padding: 16px
   │  └─ Content:
   │     ├─ Icon Container (top)
   │     │  ├─ Padding: 10px
   │     │  └─ Radius: 12px
   │     └─ Text Block (bottom)
   │        ├─ Title (2 lines)
   │        ├─ Spacing: 6px
   │        └─ Subtitle with arrow
   │
   ├─ Spacing: 12px
   │
   └─ Task Spinner Card
      └─ (Same structure as Faith Journey)
```

## Interaction States

### Normal State
- Full color gradient
- Full shadow
- Normal text opacity

### Hover/Pressed State (Material Ripple)
- Material ripple effect
- Slight scale animation (optional)
- Navigation on tap release

## Responsive Behavior

### Phone (Portrait)
```
┌─────────────────┐
│ Card │ Card     │  ← Equal width, side by side
└─────────────────┘
```

### Tablet (Landscape)
```
┌───────────────────────────────────────┐
│  Card  │  Card  │  (More spacing)    │
└───────────────────────────────────────┘
```

## Accessibility

- ✅ High contrast white text on colored backgrounds
- ✅ Large tap targets (entire card)
- ✅ Clear visual hierarchy
- ✅ Semantic navigation with arrows
- ✅ Screen reader friendly labels

## Design Rationale

1. **Gradient Backgrounds**: Modern, engaging, draws attention
2. **Different Colors**: Purple vs Orange helps differentiate features
3. **Frosted Icons**: Adds depth, modern glass-morphism trend
4. **Side-by-side**: Shows both features equally, saves vertical space
5. **Arrows**: Clear call-to-action, indicates navigation
6. **Shadows**: Creates depth, cards appear to "float"
7. **Section Header**: Groups related features, adds trophy for gamification context

## Code Location

File: `/lib/pages/home_page.dart`
Lines: ~445-635 (new gamification section)

---

**Designer Notes**: This design follows modern Material Design 3 principles with gradients, depth, and clear hierarchy. The purple/orange color scheme creates visual interest while maintaining accessibility.

