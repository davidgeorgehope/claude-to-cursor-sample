---
name: secure-commit
description: Review a git commit for secrets and unsafe commands before the user commits. Use when preparing a commit or when the user asks to check a diff.
---

# Secure commit

1. Diff staged changes.
2. Flag secrets, credentials, and destructive shell in the diff.
3. Suggest a safer commit message if needed.
