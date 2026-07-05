# Forge repository Copilot / architecture instructions

This file contains the stable architecture rules for the Forge project. Keep it short and normative.

Rules
- Architecture: CLI → Application → Domain → Infrastructure
- The Git Engine (`src/git/engine.nim`) is the ONLY public infra API. Nothing outside `src/git` may import implementation modules like `git_engine`, `impl_cli`, or `impl_libgit2`.
- Sprint 1 API is minimal and immutable: `isRepository`, `open`, `close`, `head`, `branches`, `commits` only.
- All public errors must be typed exceptions defined in `src/git/errors.nim`.
- No writing, no DB, no AI, no caching in Sprint 1.
- If a proposed change touches the public API, create an ADR and get architectural approval.

Enforcement
- CI runs `tools/import_rule_check.sh` to ensure no forbidden imports exist.
- Experimental code should live under `/experimental` or `/tools` and must be explicitly documented as prototype.

Using Copilot
- Prefer suggestions that respect the above constraints. If Copilot suggests importing `git_engine` outside `src/git`, reject and refactor to use `git.engine` instead.
