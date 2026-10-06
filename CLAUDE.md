# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Salesforce DX project (`OC_Projet08`), source-tracked under `force-app/` (default package directory, API version 65.0). It is currently an empty scaffold — no custom objects, Apex, or LWC have been added yet.

Connected org alias: `OC_Projet08` (set as default via `sf config set target-org`).

## Commands

Package management is npm; org/metadata operations go through the Salesforce CLI (`sf`).

- Install tooling deps: `npm install`
- Push local source to the default org: `sf project deploy start`
- Pull org changes into source: `sf project retrieve start`
- Run Apex tests in the org: `sf apex run test --target-org OC_Projet08 --result-format human`
- Run LWC/Aura unit tests (Jest): `npm run test` (aliases: `npm run test:unit`, `npm run test:unit:watch`, `npm run test:unit:coverage`)
  - Single test file: `npx sfdx-lwc-jest force-app/main/default/lwc/<component>/__tests__/<file>.test.js`
- Lint LWC/Aura JS: `npm run lint`
- Format all supported files: `npm run prettier` (check only: `npm run prettier:verify`)

## Git hooks

Husky + lint-staged run on commit (`npm run prepare` sets up the hook): Prettier formats staged `cls/cmp/component/css/html/js/json/md/page/trigger/xml/yaml/yml` files, ESLint runs on staged `aura`/`lwc` JS, and `sfdx-lwc-jest` runs related tests for any staged LWC files.

## Structure notes

- New metadata (Apex classes, LWC, Aura, objects, etc.) goes under `force-app/main/default/...` following standard SFDX folder conventions.
- `.forceignore` excludes `package.xml`, LWC `jsconfig.json`/`.eslintrc.json`, and `__tests__/**` from push/pull/status operations.
- `config/project-scratch-def.json` defines the scratch org shape if scratch orgs are used instead of the dev org above.

## Apex architecture (mandatory — Apex Well-Architected Framework, awaf.dev)

These rules are non-negotiable for all Apex written in this repo. Reference: https://www.awaf.dev/

### Selector layer

- All SOQL must be encapsulated in dedicated selector classes — never inline SOQL in domain, service, or trigger handler classes.
- Selector classes centralize data access so queries can be mocked in tests instead of relying on real DML/records.
- One selector class per SObject, named `<SObject>Selector` (e.g. `AccountSelector`), placed under `force-app/main/default/classes/selectors/`.
- Selector methods return typed lists/maps of the SObject (or wrapper), never raw dynamic SOQL strings assembled outside the class.

### Service layer

- All business logic — the logic users care about directly (e.g. "when an Opportunity is Closed Won, create a default Contract") — lives in service classes, never in triggers or trigger handlers.
- Trigger handlers are infrastructure only: they route records (`Trigger.new`/`Trigger.old`) to the correct service method and contain no business rules themselves.
- Service methods must be built "inside-out": accept domain objects/collections directly (e.g. `List<Opportunity>`) rather than requiring a trigger context, so they can be called and tested independently of a trigger.
- Decouple business logic from infrastructure (DML, callouts, governor-limit handling, retries) via dependency injection/wrappers, so the business rule can be unit-tested without real database operations.
- Do not split classes into artificial "Service" vs "Domain" buckets purely by naming convention — the deciding factor for where logic lives is cohesion: keep logic that changes together, together.
- Service classes live under `force-app/main/default/classes/services/`, named `<Domain>Service` (e.g. `OpportunityService`).

### Trigger layer

- One trigger per SObject, named `<SObject>Trigger`, placed under `force-app/main/default/triggers/`.
- Every trigger declares **all** events: `before insert, before update, before delete, after insert, after update, after delete, after undelete` — even when no business rule uses an event yet.
- The trigger body is exactly one line: `new <SObject>TriggerHandler().dispatch();`. No business logic, no service call, no selector call, no condition in the trigger.
- Every handler is named `<SObject>TriggerHandler`, lives under `force-app/main/default/classes/`, and exposes a public `dispatch()` method that does a `switch on Trigger.operationType` and calls exactly one dedicated method per event: `beforeInsert`, `beforeUpdate`, `beforeDelete`, `afterInsert`, `afterUpdate`, `afterDelete`, `afterUndelete`.
- `dispatch()` is the only place that reads the `Trigger.*` context variables (`Trigger.new`, `Trigger.old`, `Trigger.oldMap`, `Trigger.operationType`); the per-event methods receive typed collections as parameters so they stay testable.
- Per-event methods only detect which records are concerned and delegate to a service method. Business rules (validation, field mapping, thresholds) belong in `<Domain>Service`, never in the handler. Events with no rule yet keep an empty method.
- Tests must exercise every event through real DML (insert, update, delete, undelete) so each `dispatch()` branch is covered.

### Constants

- All constants for the project live in a single file/class, never scattered across business logic classes.
- Within that file, constants are grouped and separated by type/category (e.g. a block for Status values, a block for Record Type developer names, a block for limits/thresholds, a block for field API names), each block clearly delimited so a given type of constant is easy to locate.
- Place it at `force-app/main/default/classes/constants/Constants.cls` (or split per bounded domain only if the file becomes unwieldy — default to one file).

### Naming conventions

- Name variables by meaning, not by type: `accounts` / `inactiveContacts`, never `accountList` / `contactSet`.
- Extract complex boolean conditions into well-named methods (`isEligibleForSync()`, `hasRequiredFields()`) instead of inlining boolean logic in `if` statements.
- When comparing two instances of the same type, use names that show how they differ: `oldOppty`/`newOppty`, `childOppty`/`parentOppty` — never `o1`/`o2`.
- Rename identifiers when their contents/requirements change, so the name always matches actual behavior (e.g. `allContacts` → `recentlyCreatedContacts` if the query is narrowed).
- Classes, methods, and variables must be named clearly and explicitly enough to self-document what they do — a reader should understand a class/method/field's purpose from its name alone, without needing to open its body or read a comment.
