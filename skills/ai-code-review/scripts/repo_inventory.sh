#!/usr/bin/env bash
set -euo pipefail
# Read-only inventory helper. Avoid printing file contents or secret values.
root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$root"
printf 'Repository root: %s\n' "$root"
printf '\n== Git status ==\n'
git status --short 2>/dev/null || true
printf '\n== Top-level entries ==\n'
find . -maxdepth 1 -mindepth 1 -print 2>/dev/null | sed 's#^\./##' | sort
printf '\n== Tracked file counts by extension ==\n'
git ls-files 2>/dev/null | awk '
function ext(path, base,n,a) {
  n=split(path,a,"/"); base=a[n]
  if (base !~ /\./) return "[no extension]"
  sub(/^.*\./,"",base); return "." base
}
{ counts[ext($0)]++ }
END { for (e in counts) print counts[e],e }
' | sort -nr | head -40
printf '\n== Common risk entry points ==\n'
git ls-files | grep -E '(^|/)(controllers|jobs|services|webhooks|migrations|policies|middleware|routes|initializers)/|Gemfile|gemspec|Dockerfile|\.github/workflows/' | head -250 || true
