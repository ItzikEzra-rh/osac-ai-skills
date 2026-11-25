# {Feature name}

{One paragraph, 3-5 sentences: what the system will do after this design, the
main new pieces, and who can do what. Plain words.}

Design for {feature} ({JIRA}). See the [PRD](prd.md) for requirements.

## Today and with this design

| | Today | With this design |
|---|---|---|
| {aspect a user or operator notices} | {current behavior} | {new behavior} |

## How it works

{One Mermaid diagram of the main flow. Mark new components.}

- **{Step 1}.** {one sentence}
- **{Step 2}.** {one sentence}
- **{Step 3}.** {one sentence}

Each step has its own section below.

## Definitions

- **{Term}**: {what it is, in one sentence}

## {Step 1}

1. **{Rule, one sentence.}** {One or two sentences: the reason, or the detail an implementer needs.}

## {Step 2}

2. **{Rule.}** {Reason or detail.}

## Guard Rails

{Numbered rules continue. The invariants that keep results correct: atomic
writes, duplicate prevention, what happens on crash, restart, restore and
failure. Only the ones not already stated above.}

## Security

## Where the code goes

- **New:** {components}
- **Changed:** {components and what changes}
- **Unchanged:** {APIs, CRDs or protos left alone}

## API

{Table or short list of new or changed APIs, topics, routes, config values.}

## Alternatives

- **{Alternative}.** {Why not, one sentence.}

## Not in this design

{One line: what is deferred, with Jira keys or PRD identifiers where known.}
