---
name: trixel-hermes
description: The unified agentic core for Franklin Sebastian. Automates TRIXEL development, CUV ministry systems, and mobile device health without needing explicit activation.
---
# Trixel-Hermes Unified Skill Pack

## Overview
This skill implements the **Hermes Agent** philosophy. It provides an integrated suite of mobile automation, TRIXEL development tools, and CUV ministry systems.

## Core Capabilities

### 1. Mobile & Device Automation
- **Organize Downloads**: Run `python scripts/file_organizer.py` to move files from `/Download` to their respective project folders.
- **Device Health**: Run `bash scripts/device_health.sh` to check battery and system status before heavy tasks.

### 2. TRIXEL / Learnty DevOps
- **Global Git Sync**: Run `bash scripts/git_sync.sh` to pull and push all local TRIXEL repositories in one go.

### 3. CUV Ministry Systems
- **Teaching Processing**: Extract and summarize CUV mandates and teaching outlines.
- **Member Comms**: Automate SMS broadcasts using `termux-sms-send`.

### 4. Agentic Evolution (The Hermes Loop)
- **Memory Review**: Summarize our session and update `MEMORY.md`.
- **Skill Discovery**: Identify recurring manual patterns and propose new script-based automations.

## Workflow Instructions
1. **Be Proactive**: If the user mentions "sync my repos" or "clean up my files," execute the relevant script immediately.
2. **Maintain Context**: Always reference the user's dual-path (TRIXEL & CUV).
3. **Verify Success**: Every automation must report a clear success/failure status.
