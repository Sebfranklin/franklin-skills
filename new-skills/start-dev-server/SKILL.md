---
name: start-dev-server
description: Starts a Node.js/Vite development server. Includes specific fixes for Termux/Android environments such as removing the unsupported Supabase CLI and resolving React 19 peer dependency conflicts. Use this skill whenever the user asks to start, run, or fix the development server.
---

# Start Dev Server

This skill provides a robust way to start a development server, particularly tailored for Termux (Android) environments where certain dependencies might fail to install.

## Workflow

When asked to start the development server, follow these steps:

1. **Check `package.json` for unsupported dependencies:**
   - On Android/Termux environments, the `supabase` CLI package fails to install because there are no pre-built binaries for `android arm64`.
   - If `supabase` is present in `devDependencies` or `dependencies` in `package.json`, use the `replace` tool to remove it before running `npm install`.

2. **Install Dependencies:**
   - Projects using React 19 often face peer dependency conflicts with packages like `react-helmet-async` or `@tanstack/react-query`.
   - Run the installation with the `--legacy-peer-deps` flag to bypass these conflicts, and use `--no-audit --no-fund` to speed up the process:
     ```bash
     npm install --legacy-peer-deps --no-audit --no-fund
     ```

3. **Start the Server:**
   - Look at the `scripts` in `package.json` to find the correct dev command (usually `npm run dev` or `npx vite --host`).
   - Execute the start command in the background using the `run_shell_command` tool with `is_background: true`.
   - Ensure you bind to the host (e.g., `--host` for Vite) so the server is accessible on the local network.

4. **Verify and Report:**
   - Use the `read_background_output` tool with a delay (e.g., `delay_ms: 5000`) to check the background process output.
   - Confirm the server has started successfully and provide the user with the Local and Network URLs from the console output.

## Example Tool Usage

**Removing Supabase CLI from package.json:**
Use the `replace` tool to target the exact line where `"supabase": "..."` is defined and remove it.

**Running install and starting the server:**
```json
{
  "command": "npm install --legacy-peer-deps --no-audit --no-fund && npx vite --host",
  "is_background": true
}
```
