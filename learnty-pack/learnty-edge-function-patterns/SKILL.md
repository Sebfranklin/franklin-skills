---
name: learnty-edge-function-patterns
description: Patterns, rules, and templates for creating and modifying Learnty Supabase Edge Functions
---

# Learnty Edge Function Patterns

## Architecture Overview

Learnty uses **Supabase Edge Functions** (Deno) as the AI backend. Each function is a self-contained HTTP handler in `supabase/functions/<name>/index.ts`.

### Dual-Function System

Every function exists in two copies:
- **Production**: `supabase/functions/<name>/` → deployed to Supabase, called in production builds
- **Test (Re-Edge)**: `supabase/functions/test-<name>/` → deployed separately, called during `npm run dev`

The frontend automatically routes via `aiService.ts`:
```typescript
const isDev = import.meta.env.DEV;
const finalFunctionName = isDev ? `test-${functionName}` : functionName;
```

> **RULE**: When making changes, ONLY update and deploy the `test-` prefixed function first. Verify it works locally/remotely. Then ask the user: "Should I apply the same changes to the main (production) edge function?" Only update and deploy the production copy after explicit confirmation.

---

## Mandatory Boilerplate

Every edge function MUST include this exact structure:

### 1. CORS Headers (Required)
```typescript
const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    'Access-Control-Allow-Methods': 'POST, GET, OPTIONS, PUT, DELETE'
};
```

### 2. OPTIONS Handler (Required)
```typescript
serve(async (req) => {
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders });
    }
    // ... handler logic
});
```

### 3. Pollinations API Key Retrieval (Required for AI functions)
```typescript
const apiKey = (Deno.env.get('POLLINATIONS_API') || Deno.env.get('POLLINATIONS_API_KEY') || "").trim();
```

### 4. Pollinations API Call Headers (Required — ALL 4 headers)
```typescript
const headers = {
    "Authorization": `Bearer ${apiKey}`,
    "Content-Type": "application/json",
    "Origin": "https://pollinations.ai",
    "Referer": "https://pollinations.ai/"
};
```

> **CRITICAL**: `Origin` and `Referer` headers are MANDATORY for Pollinations tier validation. Omitting them causes silent auth failures.

### 5. Model Selection (Mandatory)
```typescript
model: 'gemini-2.5-flash-lite'  // ALWAYS this model. No exceptions.
```

### 6. API Endpoint
```
https://gen.pollinations.ai/v1/chat/completions
```

---

## Response Patterns

### Text Response (Chat, Customer Support)
```typescript
return new Response(JSON.stringify({ text: cleanedText }), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' }
});
```

### JSON Response (Quiz Generators)
AI returns text with embedded JSON. Always clean it:
```typescript
let cleanText = text.replace(/```json/gi, '').replace(/```/g, '').trim();
const jsonMatch = cleanText.match(/\{[\s\S]*\}/);
if (jsonMatch) cleanText = jsonMatch[0];
const parsed = JSON.parse(cleanText);
```

### Error Response
- **User-facing errors**: Return status `200` with friendly message (Chat, Customer Support)
- **System errors**: Return status `500` with debug info (Quiz Generators)

```typescript
// Friendly (chat-style functions)
return new Response(JSON.stringify({
    error: "My brain is doing a quick reboot! 🧠",
    debug_error: error instanceof Error ? error.message : String(error)
}), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    status: 200  // Keep UI functional
});

// System (generator functions)
return new Response(JSON.stringify({
    error: error instanceof Error ? error.message : 'Unknown error'
}), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    status: 500
});
```

---

## Function Registry

| Function | Action Key | Purpose | Input | Output |
|----------|-----------|---------|-------|--------|
| `chatbot-assistant` | `chat` | Learnie chatbot | `{ message, conversationHistory, mode }` | `{ text }` |
| `topic-quiz-generator` | `generate_quiz` | Learning quests | `{ topic, depth, modules }` | `{ milestones[] }` |
| `millionaire-quiz-generator` | `generate_millionaire_quiz` | The Gauntlet game | `{ mode, topic, user_history }` | `{ questions[] }` |
| `customer-support-iva` | `customer_service` | Support agent Iva | `{ prompt }` | `{ text }` |
| `get-youtube-video` | N/A (direct) | Video search | `{ topic, offset }` | `{ videoId, title }` |
| `generate-image` | N/A (direct) | Image generation | `{ prompt, width, height, model }` | Binary image |
| `ai-processor` | fallback | Legacy processor | `{ action, prompt }` | `{ text }` |

---

## Deployment Rules

1. **Test-first workflow**: Always update `test-<name>` first, never touch production until test is verified
2. **Local test** using `run_local.ps1` and `test_local.ps1` before any deployment
3. **Deploy test**: `supabase functions deploy test-<function-name>`
4. **Verify**: Confirm test function works correctly (locally or remotely)
5. **Ask user**: "Test function verified. Should I now apply the same changes to the main (production) edge function?"
6. **Deploy main** (only after user says yes): `supabase functions deploy <function-name>`
7. **Verify remote secrets** match: `POLLINATIONS_API`, `YOUTUBE_DATA_API`
8. **Never deploy production** without explicit user permission

## Adding a New Edge Function

1. Create `supabase/functions/<name>/index.ts` with the boilerplate above
2. Create `supabase/functions/test-<name>/index.ts` (identical copy)
3. Add routing in `utils/aiService.ts` → `callAIFunction` switch
4. Add new action to `AIRequest.action` type union in `utils/aiService.ts`
5. Add response handling to the `switch (request.action)` block
6. Add to `warmUpEdgeFunctions` if latency-critical
