# Writing Skills for Agents

How to write the documents an agent reads in this repository: a skill's `SKILL.md`, its `references/` files, manifest triggers, `AGENTS.md`, and router entries. `docs/SKILL_CONTRACT.md` defines the required sections and the size limits; this guide is about the writing. A well-written skill makes the agent take the same process every run, even when the output differs.

## Pointers

A **pointer** is text that is always in the agent's context and names material that is not: a skill `description`, a manifest trigger list, a router row, a line in `AGENTS.md`, or a row of a skill's `## References` table. The pointer's wording, not the target's content, decides whether and when the agent loads the material.

- If an agent misses a reference it needed, sharpen the pointer before moving the material into `SKILL.md`.
- State what the material is and list each distinct case that should load it. Synonyms for one case are one case; keep the clearest word.
- Put the triggering word first. "Use when reviewing a branch…" loads more reliably than "This skill, which is about several kinds of review…".
- Cut words the target already carries. Always-loaded text costs context on every turn, so pointers are pruned harder than bodies.

## Two costs

Every document spends one of two budgets:

- **Context cost**: always-loaded text (descriptions, triggers, `AGENTS.md`) occupies the agent's window on every turn, whether or not it applies.
- **Maintainer cost**: people have to know which documents exist and when each applies. Spend it where human judgement matters.

Material behind a pointer costs only the pointer's line in context. That is why deep knowledge lives in `references/` and `AGENTS.md` stays short.

## Placing material

A skill mixes **steps** (what the agent does, in order) and **reference** (rules, definitions, and facts it consults). Place each piece by how soon the agent needs it:

1. **Steps in `SKILL.md`**: inspection, decision rules, the change contract, and verification.
2. **Reference in `SKILL.md`**: what every change in the skill's area needs, such as critical invariants and failure modes.
3. **Reference in `references/`**: what only some changes need, loaded through the `## References` table.

The test is branching: keep in `SKILL.md` what every path through the skill needs, and move behind a pointer what only some paths reach. Too little moved down and the steps drown in detail; too much and the agent misses rules it needed.

Keep a concept's definition, rules, and caveats together under one heading, in one file. Scattering one idea across sections is as costly as duplicating it.

## Completion criteria

End every step on a criterion the agent can check:

- make it **clear**: "one command, already run, that fails on this bug" beats "understand the bug";
- make it **demanding** where thoroughness matters: "every touched boundary's change contract checked" drives more work than "check the contracts";
- when a vague criterion invites rushing to later steps, sharpen the criterion first. Split the steps into separate skills only if rushing persists, and only across a real context boundary such as a sub-agent or a hand-off.

## Words that carry behavior

A short, well-known word can carry a whole behavior: *tight* loop, *red* test, *vertical slice*, *seam*, *deep* module. Repeat the word, not the explanation, so it gathers meaning across the document and links to the same word in prompts, code, and other skills. Prefer an existing word over a coined one; a coined word must be defined and recruits nothing the model already knows.

Look for phrases that repeat an idea at several sites ("fast, deterministic, low-overhead") and replace them with one word ("tight").

State the target behavior rather than the forbidden one. "Log identifiers and state transitions" steers better than a list of what not to log. Keep a prohibition only as a hard guardrail that cannot be phrased positively, and pair it with the positive rule. The `Never …` lines in this repository's critical invariants are such guardrails; keep them few.

## Pruning

- **One source of truth per rule.** A rule lives in its owning skill's change contract or invariants, not repeated in `AGENTS.md`, the router, and three references. Other places point to it.
- **Do not cache the environment.** Versions, commands, and file layouts that the agent can look up (`Gemfile.lock`, `bin/`, `--help`) go stale when copied. Write down what cannot be looked up: the unwritten convention, the reason for a choice, the trap no config reveals.
- **Remove what no longer applies.** A line that never affects the task, or describes behavior that changed, is sediment. Delete it rather than adding a correction beside it.
- **Delete no-ops.** A sentence the model already follows by default ("write clean code", "be careful") costs tokens and changes nothing. If a rule is too weak to change behavior, use a stronger word or drop it.

## Checklist for a skill change

- [ ] the manifest description and triggers name each distinct case, with the triggering word first
- [ ] every step ends on a checkable criterion
- [ ] `SKILL.md` holds only what every path needs; the rest is in `references/`, one level deep
- [ ] each rule has one home; other files point to it
- [ ] no copied environment facts, no no-ops, no stale lines
- [ ] `bin/validate` passes, including the size gate

## Source

Adapted, in this repository's words, from the `writing-for-agents` skill in https://github.com/mattpocock/skills (MIT License, Copyright (c) 2026 Matt Pocock).
