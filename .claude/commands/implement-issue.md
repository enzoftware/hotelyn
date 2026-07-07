# Implement GitHub issue #$ARGUMENTS

Follow these steps:

1. **Read the issue**: Fetch the full issue details using `gh issue view $ARGUMENTS`.

2. **Create a branch**: Check out `main`, pull latest, then create a new branch named `feat/issue-$ARGUMENTS-<short-description>` based on the issue title.

3. **Implement the feature**:
   - Read all relevant existing code before making changes.
   - Follow the project's existing patterns, conventions, and architecture.
   - Prefer editing existing files over creating new ones.
   - Write comprehensive unit tests covering happy paths, edge cases, and error conditions.
   - Ensure the full workspace builds

4. **Run CodeRabbit review**: Execute `coderabbit review` to get AI-powered code review feedback on your changes.

5. **Address review feedback**: Read the CodeRabbit review output, then fix every actionable item. Re-run tests after applying fixes.

6. **Commit and create a PR**:
   - Stage only the relevant files (no `git add -A`).
   - Write a clear commit message referencing the issue number.
   - Push the branch and create a PR using `gh pr create` with:
     - A concise title (under 70 characters).
     - A body containing a `## Summary` section with bullet points and `Closes #$ARGUMENTS`, and a `## Test plan` section with a checklist.
