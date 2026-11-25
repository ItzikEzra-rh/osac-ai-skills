# OSAC Design — Writing Guidance

Instructions for drafting a design with `D/template.md`. Not part of the output.

## The bar

`D/example-498.md` is the model to copy. It is a different feature, so copy its
shape, length and tone, never its content. Read it fully before writing.

- **Hard budget: 150-200 lines and about 1,200 words.** This is a limit, not a
  target to fill. Count before you finish. If you are over, cut until you fit.
- A reader should finish the document in 10 minutes.
- The design states decisions. It does not explain how code is written,
  restate the PRD, or argue with every alternative.

## How to cut

Cut in this order until you fit the budget:

1. Anything the PRD already says.
2. Implementation mechanics: function names, step-by-step code flow, field-by-field
   schemas that the API section can link or summarize.
3. Repetition. Each fact appears once.
4. Explanations of obvious choices.
5. Low-risk alternatives.

Never cut a Guard Rail. If the Guard Rails alone push you over, shorten
everything else further.

## Sentences

- **Numbered rules.** Each rule in a step section and in Guard Rails is a
  numbered item: a bold one-sentence rule, then at most two plain sentences of
  reason or detail. Numbering continues across sections, as in the example.
- **Conditions always go in a table.** If behavior depends on a condition,
  write a table of condition -> behavior. Never write "if", "when", "unless" or
  "only when" chains in a sentence. One simple condition in a sentence is fine
  only when there is no other case.
- **Define things by what they are.** Never by what they are not. Write
  "Billing position: the time of the last round saved in the database", never
  "the last round, not the wall clock".
- **No parentheses inside rules.** Move the content to its own sentence or to
  Definitions.
- **Concrete words.** Name the component, field, topic or table. Avoid: contract,
  boundary, surface, shape, carry, hold, envelope, projects/projection,
  intent, semantics, posture.
- Short sentences, under 25 words. No semicolons.
- No inline source markers such as `[PRD: X]`, `[Locked: D4]` or `[Research: §]`.
  Name a PRD item in words only when a reader needs it.
- No history of earlier positions or review rounds.
- No customer or engagement names. The repository is public.

## Grounding

- Check the source tree before calling a component new or existing.
- If the design differs from an accepted EP, name the EP and the difference in
  one sentence.

## Sections

- **Summary paragraph**: what changes for users and operators.
- **Today and with this design**: 3-6 rows, behavior a person notices.
- **How it works**: one diagram, one bullet per step. The step names become
  the section names below.
- **Definitions**: only terms a reader would not know. One sentence each.
- **Step sections**: numbered rules only.
- **Guard Rails**: 3-8 numbered rules that keep results correct and are not
  already stated in a step section.
- **Security**: numbered rules, or one line if nothing changes.
- **Where the code goes**: New / Changed / Unchanged.
- **API**: a table or a short list.
- **Alternatives**: at most 4, one line each.
- **Not in this design**: one line listing deferrals. Unresolved questions go
  here too, phrased as "Open: ...", at most 3.
