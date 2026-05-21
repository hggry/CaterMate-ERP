Generate a Conventional Commit message for the current changes.

Steps:
1. Run `git diff --staged` to see staged changes. If nothing is staged, run `git diff HEAD` instead and inform the user that nothing was staged.
2. Analyze the changes and determine the appropriate type and scope:
   - Valid types: feat, fix, chore, docs, refactor, test, style
   - Valid scopes: frontend, backend, database, ai, test, docs
3. Generate exactly 3 commit message options:
   - Option 1: Minimal and precise
   - Option 2: Slightly more descriptive, with a touch of humor in the body
   - Option 3: Maximum humor in the body, still accurate in the first line
   - All first lines must follow: `type(scope): short description in English`
   - The body/footer may be written in any tone, including humorous
4. Present the 3 options clearly numbered for the user to choose from.
5. After the user selects an option (or provides their own message), run: `git commit -m "<chosen message>"`

If nothing has changed (clean working tree), tell the user and stop.
