---
name: learnty-chat-architecture
description: Chat.tsx tag-based rendering, message types, conversation history, and component integration patterns
---

# Learnty Chat Architecture

## Overview

`Chat.tsx` (~83KB) is the primary conversational interface. It renders messages as bubbles and uses **tag-based parsing** to embed rich interactive components inline within AI responses.

---

## Message Flow

```
User types message → CinematicChatInput.tsx
   ↓
getAIChatResponse(message, signal, history, mode) → aiService.ts
   ↓
callAIFunction() routes to edge function (with test- prefix in dev)
   ↓
Response text is parsed for embedded tags
   ↓
MessageBubble renders: markdown + stickers + special components
```

### Frontend → Edge Function Routing

| User Action | `AIRequest.action` | Edge Function |
|-------------|-------------------|---------------|
| Normal chat | `chat` | `chatbot-assistant` |
| Generate quiz | `generate_quiz` | `topic-quiz-generator` |
| Generate Millionaire | `generate_millionaire_quiz` | `millionaire-quiz-generator` |
| Customer support | `customer_service` | `customer-support-iva` |
| Fix note | `note_fix` | `ai-processor` |
| Expand note | `note_expand` | `ai-processor` |

---

## Tag-Based Rendering System

AI responses contain special tags that `Chat.tsx` parses to render interactive components.

### Tag Parsing Priority
1. **Stickers**: `[[sticker:name]]` → Replaced with `<img>` from `Learnie stickers/` directory
2. **Image Generation**: `[[GENERATE_IMAGE: prompt]]` → Triggers async image generation, renders inline
3. **Note Updates**: `[[NOTE_UPDATE: {...}]]` → Creates or updates a note in Supabase
4. **Path Proposals**: `[[PROPOSE_PATH: attrs]]` → Renders `ChatPathProposal` component
5. **Game Cards**: `[[GAME_CARD: {...}]]` → Renders `ChatGameCard` component
6. **Note Previews**: `[[NOTE_PREVIEW: {...}]]` → Renders `NotePreview` component

### Component Mapping

| Tag | Component | File |
|-----|-----------|------|
| `[[PROPOSE_PATH:...]]` | `ChatPathProposal` | `components/ChatPathProposal.tsx` |
| `[[GAME_CARD:...]]` | `ChatGameCard` | `components/ChatGameCard.tsx` |
| `[[NOTE_PREVIEW:...]]` | `NotePreview` | `components/NotePreview.tsx` |
| Markdown content | `MarkdownRenderer` | `components/MarkdownRenderer.tsx` |
| Millionaire modes | `ChatMillionaireModes` | `components/ChatMillionaireModes.tsx` |

---

## Conversation History Management

### Storage
- **Database**: `chat_sessions` + `chat_messages` tables in Supabase
- **CRUD**: `utils/chatStorage.ts` handles all persistence
- **Session**: Each conversation has a unique session ID

### History Window
- AI receives last **14 messages** (`.slice(-14)`)
- Only `user` and `assistant` roles are forwarded (system messages excluded)
- First message detection: `isFirstMessage` flag controls greeting behavior

### Chat Modes
| Mode | Behavior |
|------|----------|
| `undefined` (default) | Learnie persona — casual, stickers enabled |
| `game_designer` | Curriculum designer — structured, no stickers |

---

## Key Components Hierarchy

```
Chat.tsx (page)
├── CinematicChatInput.tsx (input bar)
├── MessageBubble (inline, renders each message)
│   ├── MarkdownRenderer.tsx
│   ├── Sticker images
│   ├── ChatPathProposal.tsx
│   ├── ChatGameCard.tsx
│   ├── ChatMillionaireCard.tsx
│   ├── NotePreview.tsx
│   └── Generated images
├── NoteSelector.tsx (note attachment sheet)
└── GameToolsSheet.tsx (game tools bottom sheet)
```

---

## State Management in Chat

### Key State Variables
- `messages[]` — All chat messages (user + assistant)
- `proposalEditMode` — Whether user is editing a path proposal
- `attachedNote` — Currently attached note for collaboration
- `isTyping` — Controls typing indicator (blob animation)
- `gameGenerationContext` — Shared context for game state persistence

### Common Pitfalls
1. **Typing indicator reappears**: Ensure `setIsTyping(false)` is called BEFORE any async operations after receiving AI response
2. **Game card reverts to proposal**: `ChatGameCard` must check `gameGenerationContext` on mount to restore active game state
3. **Sticker not rendering**: Check that sticker name matches available list and image exists in `Learnie stickers/` directory
4. **Light mode text invisible**: Use CSS variables (`var(--text-primary)`) not hardcoded colors

---

## Adding a New Embedded Component

1. Create the component in `components/`
2. Define a new tag format: `[[TAG_NAME: data]]`
3. Add tag parsing logic in `Chat.tsx` message rendering
4. Add the corresponding prompt instruction in the edge function's system prompt
5. Update this skill document with the new tag
