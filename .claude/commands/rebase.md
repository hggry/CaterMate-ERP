Guide the user through rebasing their current branch onto main.

Steps:
1. Run `git status` to check for uncommitted changes.
   - If there are uncommitted changes: run `git stash` and note that a stash was saved.
2. Run `git fetch origin main` to get the latest state of main.
3. Run `git rebase origin/main`.
4. If the rebase succeeds without conflicts: proceed to step 6.
5. If there are conflicts:
   - List the conflicting files clearly.
   - Explain what a conflict marker looks like (`<<<<<<<`, `=======`, `>>>>>>>`) and how to resolve it.
   - Tell the user to open each file, resolve the conflict, then run `git add <file>` for each resolved file.
   - After the user confirms they've resolved conflicts: run `git rebase --continue`.
   - If at any point the user wants to abort: run `git rebase --abort` and stop.
6. Run `git push --force-with-lease origin <current-branch>` to update the remote branch.
7. If a stash was saved in step 1: run `git stash pop`.
8. Confirm success to the user.

If the current branch is `main`: warn the user that they should not rebase main onto itself and stop.
