# Runtime Profile

`bin/runtime-profile PATH` inspects repository configuration and emits JSON describing Ruby, Rails, Bundler, and CI version evidence.

It intentionally distinguishes resolved versions from constraints and does not silently choose between conflicting sources.

## Example

```bash
ruby bin/runtime-profile /path/to/app
```

## Evidence model

| Evidence | Meaning |
|---|---|
| Gemfile.lock | concrete resolved dependency/runtime evidence |
| .ruby-version | local Ruby-version declaration |
| Gemfile | dependency/runtime constraints |
| *.gemspec | library Ruby compatibility constraints |
| .tool-versions | tool-version declaration |
| mise.toml | tool-version declaration |
| CI workflows | supported/tested version matrix |
| deployment config | production runtime evidence |

## Resolution principles

- A concrete lockfile Ruby version is separated from a Ruby constraint.
- A Rails version in Gemfile is a constraint until the lockfile resolves it.
- CI matrices describe supported/tested versions, not necessarily the developer's local runtime.
- Conflicting high-confidence evidence produces `status: conflict` and no resolved version.
- Insufficient evidence produces `status: unknown`.
- The output preserves candidates and sources so an AI coding assistant can inspect the evidence.

## Intended agent workflow

```text
runtime-profile
  -> inspect evidence
  -> resolve or report conflict
  -> identify version-sensitive API
  -> implement compatible code
  -> test
```

The tool does not install dependencies, modify configuration, or select a version on behalf of the project.