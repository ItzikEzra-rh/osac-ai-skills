---
title: feature-slug
authors:
  - TBD
creation-date: yyyy-mm-dd
last-updated: yyyy-mm-dd
tracking-link:
  - TBD
prd: "prd.md"
brief: "brief.md"
---

# Feature Title

The PRD owns motivation, goals, non-goals and user outcomes. The design brief
owns stakeholders, agreed principles, alternatives, trade-offs and open
questions. This document captures the architecture, contracts and behavior
needed to build the feature. Do not repeat what the PRD or brief already say.

Keep every section header. If a section does not apply, write "N/A" with a
short reason.

## Scope

Which PRD capabilities this design delivers, and which it defers. One bullet
each, by PRD identifier.

## High-Level Design

The components involved, what each one does, and how data flows between them.
Use a diagram when it helps.

### Guard Rails

The invariants and boundaries that must hold for the design to be correct.
One rule per bullet. Include atomicity, idempotency, ordering, tenant
isolation, and what happens to state on crash, restart or restore.

## API and Access Changes

New or changed APIs, CRDs, schemas and database tables, and who may access them.

## Observability

Metrics, events and logging.

## Security

## Scale

## Upgrade and Compatibility

## Deployment

## Failure Handling and Recovery

## Gotchas

Edge cases and non-obvious behavior implementers and reviewers must not miss.

## Validation Strategy

How we prove the design works: the key scenarios by test tier.
