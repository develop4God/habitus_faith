# SOLID Review Principles — habitus_faith

> **Copilot must read this file and self-apply every principle before delivering
> any code change.** This is the standing quality gate for this project.

---

## Why SOLID matters here

This project uses **BLoC + Provider (Riverpod)** — an architecture that depends
on strict separation of concerns. Violating SOLID in Flutter typically means:

- Business logic leaking into widgets → untestable UI
- Tight coupling to Firebase/services → hard to mock in tests
- God-classes in BLoC → impossible to maintain state transitions

---

## 🔴 Non-negotiable Rules (auto-block delivery)

| # | Rule | Dart/Flutter expression |
|---|------|------------------------|
| 1 | **SRP** — One class, one job | BLoC = logic only. Widget = UI only. Service = one domain. |
| 2 | **DIP** — Depend on abstractions | Inject via `Ref` / constructor. No `Singleton.instance` in BLoC. |
| 3 | **No logic in `build()`** | Move to BLoC event or `StateNotifier` method |
| 4 | **No swallowed exceptions** | `catch (e) {}` with no logging/state update is forbidden |
| 5 | **Dispose all resources** | `StreamSubscription`, `TextEditingController`, `AnimationController` |

---

## 🟡 Strong recommendations (fix if in scope)

| # | Rule | Dart/Flutter expression |
|---|------|------------------------|
| 6 | **OCP** | Prefer strategy pattern / abstract class for growing switch/if chains |
| 7 | **ISP** | Split large repository interfaces by read/write or domain |
| 8 | **LSP** | BLoC state subclasses must not change the contract of the base state |
| 9 | **`const` everywhere** | Every widget with no runtime-variable constructor should be `const` |
| 10 | **Late safety** | Prefer nullable + null-check over `late` unless lifecycle guarantees init |

---

## 📐 Architectural Rules for habitus_faith

```
Presentation (Widget)
    ↓ reads state from
BLoC / StateNotifier
    ↓ calls
Repository interface (abstract class)
    ↓ implemented by
Firebase / SQLite / HTTP concrete class
```

- Widgets **never** import `firebase_firestore` directly
- BLoCs **never** import `flutter/material.dart`
- Repositories return **domain models**, not raw Firestore `DocumentSnapshot`

---

## 🤖 Automated Review Gate

Before every delivery, Copilot must:

1. Run `bash errors.sh` (background mode) and verify `EXIT=0`
2. Invoke the **solid-reviewer** agent via `run_subagent` on changed files
3. Wait for `DELIVERY: ✅ APPROVED` in the report
4. Only then present code to the user

If the reviewer returns `DELIVERY: ❌ BLOCKED`, fix all 🔴 issues and re-run.

---

## 📎 Agent files

| Agent | Path | Purpose |
|-------|------|---------|
| `solid-reviewer` | `.github/agents/solid-reviewer.agent.md` | Full SOLID + Flutter review |

---

*Last updated: 2026-03-05*

