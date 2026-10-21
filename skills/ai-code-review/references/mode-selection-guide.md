# Review Mode Selection

| Request | Mode |
|---|---|
| Review a pasted snippet or one file | single-file review |
| Review a PR, branch, commit range, or diff | PR/diff review |
| Audit an entire application or repository | whole-repository audit |
| Learn general review technique without reviewing a target | the reviewer training curriculum plus relevant domain references |

## Defaults for ambiguous requests

- "Review this PR", "safe to merge", or "review recent changes" → PR/diff review. Resolve the base if not supplied.
- "What's wrong with this code?" with a snippet → single-file review.
- "Is this codebase healthy?" or "find security issues in my app" without a specific change → repo audit.
- "Review like a senior engineer" → use the three-pass method in all applicable modes.
- If the user gives a file and says it is part of a PR, prefer PR/diff review.
- If only a GitHub URL is provided: PR URL → diff review; file URL → single-file review; commit URL → diff review for that commit.
- If unclear whether the user means a single file or whole repo, ask one short question.

Do not choose the expensive whole-repository audit unless requested or clearly implied.
