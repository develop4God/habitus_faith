# Developer Agent Instructions UX related

This document defines the development standards and operational protocols for this project. The agent must read and adhere to these principles at the start of every session.

## 1. Discovery & Navigation Protocol
- **Grep-First**: Always use `grep` or `code_search` to locate symbols, variables, and logic patterns across the project before making changes.
- **Context Awareness**: Do not assume file locations; verify them using `find_files` or `list_files` to ensure work is performed in the correct architectural layer.

## 2. Modern UI/UX Design Standards
All UI developments must prioritize a "modern, premium, and user-friendly" aesthetic. Reference the following implementations as the project's visual and UX North Star:

### Reference A: Pet Selection Page
- **Fixed/Pinned Elements**: Use fixed headers for previews and interaction controls (like the color picker) while the main content scrolls.
- **Dynamic Feedback**: Implement real-time previews (e.g., viewing locked content in the header).
- **Interactive Layers**: Use `AnimatedContainer`, `Hero` animations, and `Lottie` for smooth transitions and state changes.

### Reference B: Faith Journey "In Construction" Container
- **Vibrant Gradients**: Use deep, high-contrast gradients (e.g., Purple to Indigo) for high-impact sections.
- **Translucent UI (Glassmorphism)**: Use `withValues(alpha: ...)` for backgrounds and borders of sub-elements to create depth.
- **Visual FOMO & Badges**: Use elegant, high-contrast badges (like "PRÓXIMAMENTE") and icons to communicate state and future features.
- **Typography**: Utilize bold weights and subtle shadows for readability over complex backgrounds.

## 3. Pre-Completion Safety Protocol
- **Fatal Info Analysis**: Never consider a task "complete" without running `analyze_current_file`. 
- **Logical Validation**: Check for "fatal" breaking changes, ensuring that refactors do not break existing Riverpod providers or navigation flows.
- **Clean Code**: Resolve all linter warnings and performance suggestions (e.g., proper `const` usage) before submitting.

## 4. Interaction Tone
- **Concise & Expert**: Maintain professional, expert-level communication while being brief and helpful.
- **Respectful**: Acknowledge the developer's vision and "God Bless" signature.
