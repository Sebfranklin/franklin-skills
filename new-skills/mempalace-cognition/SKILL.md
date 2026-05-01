---
name: mempalace-cognition
description: Mandatory skill for managing and searching the MemPalace long-term memory system. You MUST use this skill whenever a user asks a question about past projects, architectural decisions, user preferences, or bug history. Use this skill to ensure the background llama-server is running and to maintain a consistent memory taxonomy. Always check MemPalace before proposing complex solutions to avoid repeating past mistakes.
---

<instructions>
# MemPalace Cognition Skill

You are now operating with Long-Term Memory capabilities.

## The Brain Lifecycle (llama-server)
For semantic (concept) search to function, the local background brain must be running.
If a search command prints a warning that the server is down or unreachable:
1. Immediately run the following command in the background (`is_background: true`):
   `llama-server --model ~/.gemini/models/nomic-embed-text-v1.5.Q4_K_M.gguf --embedding --port 8080 --threads 2 --no-mmap`
2. Wait ~5-10 seconds for it to fully load and bind to the port.
3. Re-run your `search` or `add` command.

## Taxonomy Guidelines (Wings & Rooms)
When using the `add` command, enforce a strict and predictable taxonomy.
Format: `python3 ~/.gemini/MemPalace_Manager.py add "<Wing>" "<Room>" "<Content>"`

**Approved Wings:**
- `Architecture`: For global rules, patterns, tech stacks, and library preferences.
- `Bugs`: For resolved issues, crash reports, and environment-specific fixes.
- `Features`: For successfully completed modules or capabilities.
- `User`: For personal user preferences, tone of voice, or workflow habits.

**Rooms:** Use specific, concise nouns (e.g., `React`, `Termux`, `Authentication`, `NumPy`).

## The "Vault of Truth" Rule
MemPalace is NOT a scratchpad. It is a Vault of Absolute Truth.
- Do NOT save unverified code, untested bug fixes, or "in-progress" thoughts.
- A memory may ONLY be saved if the user explicitly says it is verified/working, OR if it has been audited and approved by the `adversarial-reviewer` sub-agent.
- If saving a bug fix, include the error symptom and the exact solution in the `<Content>`.
</instructions>
