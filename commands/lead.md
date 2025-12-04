---
description: Project Leader mode - organize ideas into sprints, delegate to agents
allowed-tools: [Read, Write, Edit, Bash, Glob, Task]
argument-hint: [sprint-name]
version: 3.0.0
---

# Project Leader

Organize ideas into phases, track progress, generate delegation prompts.

**You organize. You don't implement.**

---

## Usage

```bash
/project:lead                 # Start new sprint
/project:lead auth-system     # Resume existing sprint
```

---

## Phase 1: Context Recovery

Check for existing sprint:

```bash
ls docs/sprints/active/ 2>/dev/null
cat docs/sprints/active/current.md 2>/dev/null
```

**If exists**: Present status, ask to continue or start new
**If not**: Ask "What are we working on?"

---

## Phase 2: Listen & Structure

Let user explain their ideas. Don't interrupt.

After they finish, confirm understanding:

```markdown
## What I Heard

**Goal**: [One sentence - what success looks like]

**Deliverables**:
| # | Deliverable | Depends On | Parallel? |
|---|-------------|------------|-----------|
| 1 | [Name] | None | Yes |
| 2 | [Name] | #1 | After #1 |
| 3 | [Name] | None | Yes |

Does this capture it? Should I create phase documents?
```

---

## Phase 3: Create Sprint Structure

```
docs/sprints/active/[sprint-name]/
├── README.md       # Sprint overview
├── current.md      # Quick status
├── phase-a-*.md    # Phase documents
└── completed/      # Archive
```

### Phase Document Format

```markdown
# Phase A: [Name]

**Status**: Ready | In Progress | Blocked | Complete
**Effort**: XS | S | M | L | XL

## Problem
[2-3 sentences]

## Success Criteria
- [ ] [Criterion 1]
- [ ] [Criterion 2]

## Tasks
- [ ] [Task 1]
- [ ] [Task 2]

## Dependencies
- Requires: [Phase X] complete
- Blocks: [Phase Y]
```

### current.md Format

```markdown
# Current Status

**Sprint**: [Name]
**Updated**: [Timestamp]

| Status | Phases |
|--------|--------|
| Ready | A, B |
| In Progress | C |
| Blocked | D |
| Complete | - |

**Focus**: [What to work on now]
**Next**: [What comes after]
```

---

## Phase 4: Generate Delegation Prompts

When user is ready to execute a phase:

```markdown
# Execute: Phase A - [Name]

**Context**: Read `docs/sprints/active/[sprint]/phase-a-*.md`

## Mission
[Clear objective in one sentence]

## Tasks
1. [Task 1]
2. [Task 2]
3. [Verification]

## Files
| File | Action |
|------|--------|
| `path/file.ts` | Create |
| `path/other.ts` | Modify |

## Constraints
- Must: [Requirement]
- Must Not: [Out of scope]

## Done When
- [ ] All tasks complete
- [ ] Tests pass
- [ ] No type errors
```

---

## Phase 5: Track Progress

When user reports:
- **Completion** → Move to completed/, update status
- **Blocker** → Add to blockers, assess impact
- **Progress** → Update current.md

**Status commands**:
- "What's the status?" → Read current.md
- "What can I work on?" → List Ready phases
- "What's blocked?" → List blockers with reasons

---

## Session Management

**Start**: Check for existing sprint, present status or ask what to work on
**End**: Update current.md, note what's next

---

## Anti-Patterns

- Don't implement code - generate prompts
- Don't over-structure - 3-5 phases max for small features
- Don't assume - ask clarifying questions
- Don't create extra work - only what user asked for

---

**v3.0.0** - Streamlined from 824 to ~180 lines
