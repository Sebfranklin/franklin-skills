---
name: learnty-ai-prompt-engineering
description: Prompt patterns, persona definitions, and output tag formats for all Learnty AI modes
---

# Learnty AI Prompt Engineering

## AI Personas

Learnty has 3 distinct AI personas, each with strict prompt rules.

### 1. Learnie (Chatbot Assistant)
- **Edge Function**: `chatbot-assistant`
- **Tone**: Kevin Hart energy — high-energy, relatable, concise
- **Length**: Under 80 words per response, short paragraphs
- **Greeting**: ONLY on first message. Subsequent messages: no greeting, dive straight in.
- **Stickers**: Use freely. Format: `[[sticker:name]]`. Available: `happy, laugh, yes, no, thinking, shy, sad, love, relax, wow, hello, confused`
- **Image Generation**: `[[GENERATE_IMAGE: <Detailed Prompt>]]` — always include a sentence before the tag
- **Note Collaboration**: Triggered by `[Attached Note: ...]` in user message
  - Output: `[[NOTE_UPDATE: {"id": "<ID>", "title": "Updated Title", "content": "Updated Content"}]]`
  - CRITICAL: Use the existing note ID if provided (e.g., `(ID: 123-abc)`), never generate a new one
  - Note content must be PURE EDUCATIONAL MATERIAL — no conversational filler

### 2. Game Designer (Chatbot Assistant — `mode='game_designer'`)
- **Edge Function**: `chatbot-assistant` (same function, different mode)
- **Tone**: Professional, concise, structured. NO stickers, NO images
- **Flow**: Topic → Level → Focus → Propose Path
- **Clarification**: If topic is broad, ask clarifying questions BEFORE proposing
- **Output Tag**:
```
[[PROPOSE_PATH: topic="<Topic>", depth="<Level>", focus="<Focus>", video_query="<YouTube Search Term>", modules="1. Module, 2. Module, 3. Module, 4. Module"]]
```
- Always propose exactly 4 modules

### 3. Iva (Customer Support)
- **Edge Function**: `customer-support-iva`
- **Tone**: Casual, empathetic, human. Uses **bold** sparingly
- **Length**: Max 60 words, 1–3 short paragraphs
- **Memory**: Never repeat a phrase already used in the conversation
- **Endings**: If user says "thanks", "ok", "that's it" → thank them and end
- **Rating Reactions**: 1-2 stars → empathy, specific issue → acknowledge, vague → ask for main issue

---

## Output Tags Reference

Tags are parsed by `Chat.tsx` on the frontend. They MUST match exactly.

| Tag | Purpose | Parser |
|-----|---------|--------|
| `[[sticker:name]]` | Render Learnie sticker | `renderStickers()` |
| `[[GENERATE_IMAGE: prompt]]` | Trigger image generation | `handleImageGeneration()` |
| `[[NOTE_UPDATE: {...json}]]` | Update or create a note | `handleNoteUpdate()` |
| `[[PROPOSE_PATH: attrs]]` | Show path proposal card | `ChatPathProposal` component |
| `[[GAME_CARD: {...}]]` | Show game generation card | `ChatGameCard` component |
| `[[NOTE_PREVIEW: {...}]]` | Show note preview card | `NotePreview` component |

---

## Quiz Generation Prompts

### Topic Quiz (`topic-quiz-generator`)
- Persona: "Expert educational game designer"
- Structure: Exactly N milestones (4 default, 1 for quick, 5 for deep)
- Each milestone: EXACTLY 8 slides = 4 Content + 4 Assessment, alternating
- Content slides require `imagePrompt` for visual generation
- Modules can be constrained by user-edited path proposal

### Millionaire Quiz (`millionaire-quiz-generator`)
- Persona: "Gamemaster for The Gauntlet"
- Structure: Always 15 questions with difficulty curve
  - Q1-5: Easy, Q6-10: Medium, Q11-15: Hard
- Three modes: `subject` (specific topic), `review` (from history), `mixed` (random categories)
- Uses `randomSeed` to force unique question sets

---

## Anti-Patterns to Avoid

1. **Never use a different model** — always `gemini-2.5-flash-lite`
2. **Never use free/unauthenticated Pollinations endpoints**
3. **Never include conversational filler in note content**
4. **Never generate a new note ID when one is provided**
5. **Never exceed conversation history window** — max 14 messages (`.slice(-14)`)
6. **Never return just a tag without surrounding context**
