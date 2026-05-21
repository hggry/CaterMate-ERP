Create a Pull Request from the current branch to main on GitHub.

Steps:
1. Run `git branch --show-current` to get the current branch name.
   - If the branch is not one of `backend`, `frontend`, `db`, `ai`, `test`: warn the user and stop.
2. Run `git log origin/main..HEAD --oneline` to get an overview of all commits on this branch that are not yet in main.
3. Run `git diff origin/main...HEAD --stat` to get a high-level summary of changed files.
4. Based on the commits and changed files, generate:
   - A PR title in the format: `type(scope): short description` (English, Conventional Commits style)
   - A PR body in German using this structure:
     ```
     ## Was wurde geändert?
     <1-3 bullet points summarizing the changes>

     ## Getestet
     <brief description of what was tested locally>

     ## Checkliste
     - [ ] `docker compose up --build` läuft lokal fehlerfrei
     - [ ] Kein API-Key, Passwort oder `.env`-Wert im Code
     ```
5. Show the generated title and body to the user for review. Ask if they want to proceed or make changes.
6. Run:
   ```
   gh pr create --base main --head <current-branch> --title "<title>" --body "<body>"
   ```
   
7. Output the PR URL after creation.
