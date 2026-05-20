# Project-Architect

**Description**: The Project-Architect skill standardizes directory structure, file placement, and storage hygiene. Use this skill BEFORE creating any new files, building features, or making changes to the codebase. It ensures code is organized logically (apps, packages, tests, etc.) and enforces strict rules on where temporary or junk files can be placed.

## Instructions
1. **Directory Structure Check**: Before writing any file, analyze the existing project structure and determine the appropriate home for the new content. If no appropriate directory exists, propose a new one based on established conventions (e.g., `apps/` for web, `packages/` for shared libraries, `tests/` for tests).
2. **Path Enforcement**: ALWAYS verify and enforce file paths before creating them.
3. **Storage Hygiene**: NEVER write temporary, junk, or build artifacts into the project root. ONLY place these files in designated `temp/`, `build/`, or `.cache/` folders.
4. **Consistency**: Ensure all file naming and placement strictly follows the conventions discovered in the project's existing structure.
5. **Pre-Flight Validation**: If asked to "create a file" or "start a feature", first describe the planned directory structure and file locations, wait for confirmation if the project is large or complex, then proceed to implementation.
