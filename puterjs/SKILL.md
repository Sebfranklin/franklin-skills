---
name: puterjs
description: "Expert guidance on using Puter.js for building serverless web applications. Use this skill whenever the user asks to build an app, website, or script using Puter, or mentions features like Puter AI (chat, image generation, speech), Puter.js cloud storage (fs), Key-Value database (kv), static hosting, or authentication. This skill provides the exact syntax for puter.ai.chat, puter.ai.txt2img, puter.fs, puter.kv, and puter.hosting."
---

# Puter.js Expert Skill

This skill provides comprehensive instructions on using Puter.js to build serverless web applications without backend code or API keys.

## Core Concepts
- **User-Pays Model**: You do not need to provide API keys. Puter.js routes requests and the end-user covers the cost via their Puter account.
- **Integration**: Simply include `<script src="https://js.puter.com/v2/"></script>` in the HTML. All APIs are available on the global `puter` object.

## 1. AI API (`puter.ai`)

Puter provides access to 500+ models.

### Text Generation (`puter.ai.chat`)
```javascript
// Basic usage (defaults to a nano model)
const response = await puter.ai.chat("What is the capital of France?");
console.log(response.message.content[0].text || response); // Handle ChatResponse object

// Explicit model and streaming
const streamResponse = await puter.ai.chat("Explain quantum mechanics", { 
    model: "claude-sonnet-4", 
    stream: true 
});
for await (const part of streamResponse) {
    if (part.text) console.log(part.text);
}

// Function calling
const responseWithTools = await puter.ai.chat("What's the weather in Paris?", {
    tools: [{
        type: "function",
        function: {
            name: "get_weather",
            description: "Get weather for a location",
            parameters: { type: "object", properties: { location: { type: "string" } }, required: ["location"] }
        }
    }]
});
```
*Note: `puter.ai.chat` returns a `ChatResponse` object, not a string. Extract text using `response.message.content[0].text` or stringify it safely.*

### Image Generation (`puter.ai.txt2img`)
```javascript
// Basic usage
const imageElement = await puter.ai.txt2img("A cyberpunk city");
document.body.appendChild(imageElement);

// Explicit models
const dalleImg = await puter.ai.txt2img("A cyberpunk city", { 
    provider: 'openai-image-generation', 
    model: 'dall-e-3' 
});
```

### Speech & Audio
```javascript
// Text to Speech
const audioEl = await puter.ai.txt2speech("Hello world!");
audioEl.play();

// Speech to Text (Transcribe)
const transcript = await puter.ai.speech2txt('https://example.com/audio.mp3');
console.log(transcript.text);

// Speech to Speech (Voice Changer)
const changedVoice = await puter.ai.speech2speech('~/recording.wav', { voice: '21m00Tcm4TlvDq8ikWAM' });
changedVoice.play();
```

## 2. Cloud Storage (`puter.fs`)

Provides a file system interface.
```javascript
// Write a file
const file = await puter.fs.write('hello.txt', 'Hello, world!');

// Read a file
const blob = await puter.fs.read('hello.txt');
const text = await blob.text();

// Create directory
await puter.fs.mkdir('my-folder');

// Delete file
await puter.fs.delete('hello.txt');
```

## 3. Key-Value Database (`puter.kv`)

```javascript
// Set a value
await puter.kv.set('highScore', 100);

// Get a value
const score = await puter.kv.get('highScore');

// Delete a key
await puter.kv.del('highScore');
```

## 4. Static Hosting (`puter.hosting`)

Publish a directory to a live URL.
```javascript
// Host a directory under a random subdomain
const site = await puter.hosting.create(puter.randName(), 'my-folder');
console.log(`Live at: https://${site.subdomain}.puter.site`);
```

## 5. Authentication (`puter.auth`)

Automatically handled for most APIs, but available for explicit sign-in flows.
```javascript
// Trigger sign in (must be tied to a user action like a click)
await puter.auth.signIn();

// Check status
const isLoggedIn = puter.auth.isSignedIn();

// Get user info
const user = await puter.auth.getUser();

// Sign out
puter.auth.signOut();
```

## Common Pitfalls & Constraints
- **Chat Responses**: `puter.ai.chat` returns an object. Attempting to render it directly into the DOM (e.g., `innerHTML = response`) will yield `[object Object]` or throw an error.
- **Image Generation Models**: Always pass the `model` parameter explicitly in `txt2img` to avoid `Missing model` backend errors if the default routing fails.
- **Authentication Popups**: `puter.auth.signIn()` opens a popup and MUST be triggered by a synchronous user action (like an `onclick` handler) to bypass browser popup blockers.