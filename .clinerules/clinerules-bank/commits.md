# Commit Conventions

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

## Types include:

- feat: A new feature
- fix: A bug fix
- docs: Documentation changes
- style: Changes that do not affect the meaning of the code
- refactor: Code changes that neither fix a bug nor add a feature
- perf: Performance improvements
- test: Adding or correcting tests
- chore: Changes to the build process or auxiliary tools

## Examples:

- `feat: add user authentication system`
- `fix: resolve issue with data not loading`
- `docs: update installation instructions`

## AI Agent Rules

<rules>
- Remind the user to always run `git add .` from the workspace root to stage changes
- The user prefers to manage git actions (git add, git commit, git push) manually so do not suggest that the agent run these commands.
- Review staged changes before committing to ensure no unintended files are included
- Format commit titles as `type: brief description` where type is one of:
  - feat: new feature
  - fix: bug fix
  - docs: documentation changes
  - style: formatting, missing semi colons, etc
  - refactor: code restructuring
  - test: adding tests
  - chore: maintenance tasks
- Keep commit title brief and descriptive (max 72 chars)
- Add two line breaks after commit title
- Include a detailed body paragraph explaining:
  - What changes were made
  - Why the changes were necessary
  - Any important implementation details
- End commit message with " -Agent Generated Commit Message"
- Push changes to the current remote branch
</rules>
