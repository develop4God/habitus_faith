# About Us Page - Translation Guide

## Quick Reference for Adding Remaining Languages

### Strings to Translate

Copy these 23 strings to the end of each language ARB file (before the closing `}`):

```json
  "aboutUs": "[TRANSLATE: About Us]",
  "@aboutUs": {
    "description": "About Us page title"
  },
  "aboutUsTitle": "Habitus Faith",
  "@aboutUsTitle": {
    "description": "About Us page main title"
  },
  "aboutUsSubtitle": "[TRANSLATE: Building Faith Through Daily Habits]",
  "@aboutUsSubtitle": {
    "description": "About Us page subtitle"
  },
  "aboutUsDescription": "[TRANSLATE: Habitus Faith is an application designed to help you grow in your spiritual journey through the power of consistent daily habits. We believe that small, intentional actions repeated daily can transform your life and deepen your relationship with God.]",
  "@aboutUsDescription": {
    "description": "About Us main description"
  },
  "ourMission": "[TRANSLATE: Our Mission]",
  "@ourMission": {
    "description": "Our Mission section title"
  },
  "ourMissionText": "[TRANSLATE: To empower believers worldwide to build sustainable spiritual habits that strengthen their faith, one day at a time.]",
  "@ourMissionText": {
    "description": "Our Mission text"
  },
  "features": "[TRANSLATE: Features]",
  "@features": {
    "description": "Features section title"
  },
  "featureHabitTracking": "[TRANSLATE: Habit Tracking]",
  "@featureHabitTracking": {
    "description": "Feature: Habit Tracking"
  },
  "featureHabitTrackingDesc": "[TRANSLATE: Track your spiritual, physical, mental, and relational habits with ease.]",
  "@featureHabitTrackingDesc": {
    "description": "Feature description: Habit Tracking"
  },
  "featureBibleReading": "[TRANSLATE: Bible Reading]",
  "@featureBibleReading": {
    "description": "Feature: Bible Reading"
  },
  "featureBibleReadingDesc": "[TRANSLATE: Access the complete Bible with bookmarking and verse-saving capabilities.]",
  "@featureBibleReadingDesc": {
    "description": "Feature description: Bible Reading"
  },
  "featureDailyDevotionals": "[TRANSLATE: Daily Devotionals]",
  "@featureDailyDevotionals": {
    "description": "Feature: Daily Devotionals"
  },
  "featureDailyDevotionalsDesc": "[TRANSLATE: Receive daily spiritual reflections to inspire and guide you.]",
  "@featureDailyDevotionalsDesc": {
    "description": "Feature description: Daily Devotionals"
  },
  "featureAiCoach": "[TRANSLATE: AI-Powered Habit Coach]",
  "@featureAiCoach": {
    "description": "Feature: AI Coach"
  },
  "featureAiCoachDesc": "[TRANSLATE: Get personalized micro-habits generated based on your goals.]",
  "@featureAiCoachDesc": {
    "description": "Feature description: AI Coach"
  },
  "contactUs": "[TRANSLATE: Contact Us]",
  "@contactUs": {
    "description": "Contact Us section title"
  },
  "contactUsText": "[TRANSLATE: We'd love to hear from you! Your feedback helps us improve and serve you better.]",
  "@contactUsText": {
    "description": "Contact Us text"
  },
  "email": "[TRANSLATE: Email]",
  "@email": {
    "description": "Email label"
  },
  "version": "[TRANSLATE: Version]",
  "@version": {
    "description": "Version label"
  },
  "madeWithLove": "[TRANSLATE: Made with ❤️ for the glory of God]",
  "@madeWithLove": {
    "description": "Footer text"
  }
```

## Translation Steps

### For French (app_fr.arb):

1. Open `lib/l10n/app_fr.arb`
2. Find the end of the file (before the closing `}`)
3. Add a comma after the last entry
4. Paste the template above
5. Replace `[TRANSLATE: ...]` with French translations
6. Save the file

### For Portuguese (app_pt.arb):

Same steps as French, but use Portuguese translations.

### For Chinese (app_zh.arb):

Same steps as French, but use Chinese translations.

## After Adding Translations

Run this command to regenerate localization files:

```bash
cd /home/develop4god/Projects/habitus_faith
flutter gen-l10n
```

## Reference Translations

### Spanish (Already Complete)
- aboutUs: "Acerca de Nosotros"
- aboutUsSubtitle: "Construyendo Fe a Través de Hábitos Diarios"
- ourMission: "Nuestra Misión"
- features: "Características"
- contactUs: "Contáctanos"
- email: "Correo Electrónico"
- version: "Versión"
- madeWithLove: "Hecho con ❤️ para la gloria de Dios"

### Suggested French Translations
- aboutUs: "À Propos de Nous"
- aboutUsSubtitle: "Construire la Foi par les Habitudes Quotidiennes"
- ourMission: "Notre Mission"
- features: "Fonctionnalités"
- contactUs: "Contactez-Nous"
- email: "Email"
- version: "Version"
- madeWithLove: "Fait avec ❤️ pour la gloire de Dieu"

### Suggested Portuguese Translations
- aboutUs: "Sobre Nós"
- aboutUsSubtitle: "Construindo Fé Através de Hábitos Diários"
- ourMission: "Nossa Missão"
- features: "Recursos"
- contactUs: "Fale Conosco"
- email: "E-mail"
- version: "Versão"
- madeWithLove: "Feito com ❤️ para a glória de Deus"

### Suggested Chinese Translations
- aboutUs: "关于我们"
- aboutUsSubtitle: "通过每日习惯建立信仰"
- ourMission: "我们的使命"
- features: "功能特点"
- contactUs: "联系我们"
- email: "电子邮件"
- version: "版本"
- madeWithLove: "怀着❤️为神的荣耀而制作"

---
**Note**: After completing translations, test the About Us page in each language to ensure proper display and formatting.
