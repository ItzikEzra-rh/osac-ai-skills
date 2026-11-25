---
name: "grill-design"
description: "Interview the developer about a planned change, then write a simple design - the gist in one paragraph, one small diagram, about 15 short points. Use for any design doc, RFC or enhancement proposal, new or rewritten."
---

# Grill, then design

A design must be simple. Most designs fit in one sentence, such as: "the upload service checks each upload against the user's storage limit before it saves the file, and an upload over the limit fails." Say that first, draw it with a few boxes, and then add only what a reviewer needs to approve it and an implementer needs to build it.

## Budget

- The whole design: about 120 to 150 lines of markdown, diagrams included.
- The first paragraph: three to five sentences.
- About 15 numbered points.
- One architecture diagram, with at most 8 boxes.
- At most one sequence diagram, with at most 4 participants and 8 messages.

Over budget means the design carries detail that belongs in the code, or it is two designs. Cut the detail. Don't squeeze it into fewer words.

## The word ladder

The same idea, five ways:

1. Simple words work. Complicated ones don't.
2. The more complicated our language, the harder it becomes to understand what we're actually saying.
3. When we introduce unnecessary terminology into communication, we create barriers that obscure the very ideas we're attempting to convey.
4. Deploying specialized lexical constructs invariably generates cognitive overhead that undermines comprehension of the foundational concepts.
5. Recursive deployment of domain-specific nomenclature precipitates a hermeneutical opacity antithetical to transparent ideational transmission.

All five say the same thing. Only the words get harder. Each level looks only a little worse than the one before, so a design can climb without anyone noticing. The budget above can't catch it either: level 5 is as short as level 2.

The same climb in a design:

- Level 1: "Uploads over the limit fail."
- Level 2: "The upload service rejects files over the limit."
- Level 4: "The ingestion layer enforces quota-based admission control on inbound payloads."

Write at level 1 where you can, and never above level 2.

## 1. Read before you ask

Read the ticket or PRD, the code the change touches, and related designs. Don't ask what you can look up. Collect the real names: APIs, fields, tables, errors, components, roles and config keys. For each part, note whether it exists today, where it runs, and which repository or module holds its code.

When rewriting an existing design, treat it as answers to the questions below. Ask only about what it leaves unclear or contradicts, and check its claims against the code.

## 2. Grill

Ask at most three questions at a time, the most important first, and wait for the answers. Skip what your reading answered.

- The problem: one concrete case of what goes wrong today.
- The change, in one sentence.
- The parts: which are new, which exist, where each runs, and where its code lives.
- The main flow, step by step.
- What each role gets, and anything a reader would expect that is left out.
- The hardest rule, such as a race or a limit, with numbers.
- Failures that change what users see.
- What is out of scope, and each "why not X?" a reviewer will ask.

Ask again when an answer gives no fact:

- After "handle", "support" or "ensure", ask what exactly happens.
- After a made-up word, ask for the real name.
- After an edge case, ask whether it changes the design. If it doesn't, it belongs in the code.

Before you write the design, write its first paragraph and get the developer's yes. If you can't write it, keep asking.

## 3. Write

Use these sections, in this order:

- Title and first paragraph. The paragraph the developer said yes to: what changes, the main new parts, and what each role gets. Then one line that names the ticket.
- Today and with this design. A table of at most five rows, when the design changes something that exists.
- How it works. The architecture diagram, then one bullet per step, three to five steps. End with "Each step has its own section below."
- Definitions. Only words a new team member would have to look up, such as words from outside the team's own system. At most six, one line each.
- One section per step, with the numbered points. Number them straight through. Put the sequence diagram, if any, in the section of the flow it shows.
- Security, when the design has security rules.
- Where the code goes. Three lines: new, changed, unchanged.
- API. What users call or set, as one short table or list.
- Alternatives, at most three lines, and Not in this design, one line.

Add nothing else. A failure, an upgrade step or a size limit that changes what users see is a point.

## Diagrams

Use mermaid. Draw what a person would sketch on a whiteboard in 30 seconds.

- Architecture: a flowchart. A box (subgraph) for each cluster or server. Inside it, only the parts this design is about. A new module is its own box, labeled "(new)". New code that is central to the design and lives inside an existing component is a box inside that component's box. Smaller changes go in "Where the code goes".
- Labels are names of one to three words. Arrows show the main flow only, with a one-word label when it matters, such as "upload" or "reads".
- Mark new parts with one color. Leave everything else plain.
- Sequence diagram: only for the one flow the architecture diagram doesn't make obvious.

## Writing rules

- Each point makes one claim in its first sentence. At most two sentences follow.
- Plain words. Use the words a new team member uses every day, in short sentences with one idea each. Name the thing, not its category: "the check rejects the upload", not "validation is applied to the request". No idioms. Say who does what. Real names such as PostgreSQL stay, but the words around them must be plain.
- One name for each thing, the one the code and the docs use. Spell out each acronym once.
- Tickets by name: "the storage limits design (PHOTO-120)", never a bare ID.
- Exact requirements: "any SMTP mail server", not "Gmail".
- Say what a thing is, not what it isn't.
- State what is left out where a reader would expect it, such as a file type the design doesn't cover.
- Leave out code tours, function names, file paths, source tags, requirement IDs and review history.

## 4. Check before handing over

- Read the first paragraph again. It must still match the points.
- Look at each rendered diagram briefly. If you can't say what it shows, remove boxes.
- Read only the headings and each point's first sentence. They must tell the whole design.
- Count the lines against the budget.
- For each sentence, ask whether a reviewer would decide differently, or an implementer would build differently, without it. If not, cut it.
- For each sentence that stays, ask whether simpler words would say the same thing. If they would, use them.
- Check every name and number against the code or the developer's answers.

## 5. After review

A reviewer's question marks the point that caused it. Rewrite that point so the question can't come up. Don't add a clause to it. A question about a detail that doesn't change the design gets its answer in the review thread, not in the design. Add only what the code, the source design or the developer's answers say: a made-up rule is worse than a missing one, because readers believe it. Each round of review makes the design a little longer and its words a little harder, so run the checks in section 4 again.
