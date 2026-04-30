---
name: learnty-game-flow
description: Game creation flow, milestone/slide data model, hearts/lives system, and state persistence patterns
---

# Learnty Game Flow

## Game Creation Trigger Flow

```
User enters "Topic to Game" → Chat.tsx
   ↓
AI (game_designer mode) asks: Topic → Level → Focus
   ↓
AI outputs [[PROPOSE_PATH: topic="X", depth="Y", ...]]
   ↓
UI renders ChatPathProposal (Table of Contents)
   ↓
User: "Start Adventure" → triggers generateQuiz()
   OR
User: "Edit" → enters Edit Mode (purple glow) → refines path
   ↓
generateQuiz(topic, depth, modules) → topic-quiz-generator edge function
   ↓
Response: { milestones: [...] } → ChatGameCard renders
   ↓
ActiveSession.tsx handles slide-by-slide gameplay
```

---

## Data Model

### Milestone
```typescript
interface Milestone {
    id: number;
    title: string;
    slides: QuizStepData[];  // 8 slides: 4 Content + 4 Assessment, alternating
}
```

### QuizStepData (Slide)
```typescript
interface QuizStepData {
    id: number;
    type: 'Recall' | 'Multiple Choice' | 'Code Fill' | 'Content';
    question?: string;        // For quiz slides
    content?: string;         // For content/teaching slides
    title?: string;           // For content slide headers
    codeDisplay?: string;     // For Code Fill type
    codeParts?: { id: number; text: string }[];
    options?: string[];       // For Multiple Choice
    correctId?: number;       // Index of correct option (0-based)
    answerKey?: string;       // For Recall type
    diagnosticHint?: string;  // Hint shown on wrong answer
    explanation?: string;     // Shown after answering
}
```

### AI Response Structure
```typescript
interface AIQuizResponse {
    milestones: Milestone[];
    quizSteps?: QuizStepData[];  // Legacy compatibility
}
```

---

## Lives / Hearts System

| Property | Default | Description |
|----------|---------|-------------|
| `lives` | 5 | Hearts available per session |
| `last_reset_date` | Today | When hearts were last reset |
| Reset interval | 12 hours | New hearts after cooldown |
| XP per correct | Variable | Based on difficulty |
| Streak tracking | Yes | Consecutive correct answers |

### Heart Deduction Flow
1. User answers incorrectly → deduct 1 heart immediately
2. Save to Supabase `profiles` table (`hearts`, `last_heart_reset`)
3. If hearts = 0 → show `OutOfBrainsModal` with 12-hour countdown
4. On page reload → fetch hearts from DB (NOT local state)
5. After 12 hours → reset hearts to 5

### Skip & Continue
- User can skip a question → costs 1 heart
- No duplicate deduction (guard against rapid clicks)
- Advance to next slide after skip

---

## Slide Navigation (ActiveSession.tsx)

### Forward Navigation
```
Content slide → auto advance on "Next"
Quiz slide → must answer → show explanation → "Next"
Last slide of milestone → milestone complete → advance to next milestone
Last slide of last milestone → game complete
```

### Backward Navigation
- Allowed from any slide (including across milestone boundaries)
- `handleSlideLogistics('prev')` handles boundary crossing

### Milestone Consolidation
After completing a milestone:
1. Show `VideoConsolidation` component with relevant YouTube video
2. Video fetched via `get-youtube-video` edge function
3. "Unhelpful" button allows user to skip bad videos

---

## State Persistence

### Game State (GameGenerationContext)
- Stored in React Context + localStorage
- Persists across page navigation (leave chat, come back)
- `ChatGameCard` checks context on mount to restore state

### Profile State (AuthContext)
- Hearts, XP, streak, level stored in Supabase `profiles` table
- `refreshProfile()` called after game actions
- Token rewards processed by `reward-processor` edge function

### Chat State
- Messages stored in Supabase `chat_messages` table
- Session managed via `chat_sessions` table
- `chatStorage.ts` handles CRUD operations
