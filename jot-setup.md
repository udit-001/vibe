# Jot Setup Guide for Collaborative Planning

This guide documents how to set up [jot](https://github.com/badlogic/jot) — a minimal self-hosted collaborative markdown editor — for planning and feedback workflows between humans and agents.

## What You'll Get

- A self-hosted markdown editor running in Docker
- Inline comment threads anchored to specific text
- CLI access for reading, editing, and commenting on documents
- A workflow where reviewers add inline feedback and authors revise based on comments

---

## Prerequisites

- Docker and Docker Compose
- Node.js (for the jot CLI)
- `curl` (for API setup steps)

---

## Step 1: Clone and Configure Jot

```bash
# Clone the repository
git clone https://github.com/badlogic/jot.git ~/Dev/public/jot
cd ~/Dev/public/jot

# Create data directory
mkdir -p data/notes
```

---

## Step 2: Create a Docker Compose File

Create `docker-compose.local.yml` in the jot directory:

```yaml
services:
  jot:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: jot
    restart: unless-stopped
    ports:
      - "3210:3000"
    environment:
      PORT: 3000
      DATA_DIR: /app/data
    volumes:
      - jot_data:/app/data
    networks:
      - jot_network

volumes:
  jot_data:
    driver: local

networks:
  jot_network:
    driver: bridge
```

> **Note:** The original Dockerfile has a redundant `npm ci --omit=dev` in the final stage that may fail on slow networks. If you encounter build errors, copy `node_modules` from the `deps` stage instead of reinstalling.

---

## Step 3: Start the Server

```bash
docker compose -f docker-compose.local.yml up -d --build
```

Verify it's running:

```bash
docker ps | grep jot
curl -s -o /dev/null -w "%{http_code}" http://localhost:3210/
# Should return 200
```

Jot will be available at **http://localhost:3210**

---

## Step 4: Install the CLI

```bash
npm install -g @mariozechner/jot
```

---

## Step 5: Set Up Authentication

Jot uses a single owner password and API keys for programmatic access.

### 5.1 Set the Owner Password

Run this once to initialize the owner account:

```bash
curl -s -X POST http://localhost:3210/api/auth/setup \
  -H "Content-Type: application/json" \
  -d '{"password":"YOUR_PASSWORD","confirmPassword":"YOUR_PASSWORD"}'
```

This returns a device token (temporary):

```json
{"ok":true,"token":"YOUR_DEVICE_TOKEN","ownerLocalStorageTokenKey":"md_owner_token"}
```

### 5.2 Create an API Key

Device tokens expire. For persistent CLI access, create a dedicated API key:

```bash
# Exchange the device token for a session cookie
curl -s -c cookies.txt -X POST http://localhost:3210/api/auth/token \
  -H "Content-Type: application/json" \
  -d '{"token":"YOUR_DEVICE_TOKEN"}'

# Create an API key
curl -s -b cookies.txt -X POST http://localhost:3210/api/keys \
  -H "Content-Type: application/json" \
  -d '{}'
```

Returns:

```json
{"ok":true,"id":"...","label":"unnamed","key":"YOUR_API_KEY","createdAt":"..."}
```

**Save this API key.** It is used to register the CLI in the next step.

### 5.3 Register the CLI

Use the API key to register the jot instance:

```bash
jot register local http://localhost:3210 YOUR_API_KEY
```

Test it:

```bash
jot local list
```

> **Security note:** API keys can be revoked at any time from the jot web UI (Settings → API Keys) or via `DELETE /api/keys/:id`.

---

## Step 6: Create Your First Planning Document

```bash
# Create a new note
jot local create "Sprint 1 Planning"

# Update with content
jot local update <note-id> markdown "# Sprint 1 Planning

## Goals
- [ ] Task one
- [ ] Task two

## Discussion
Use this section for feedback and questions.
"
```

Or create via the API:

```bash
curl -s -b cookies.txt -X POST http://localhost:3210/api/notes \
  -H "Content-Type: application/json" \
  -d '{"title":"Sprint 1 Planning","markdown":"# Sprint 1 Planning\n\n## Goals\n- [ ] Task one\n- [ ] Task two\n\n## Discussion\nUse this section for feedback."}'
```

---

## Step 7: The Collaborative Workflow

The typical flow is: **Author creates a plan → Reviewer adds inline comments → Author revises based on feedback.**

This works for:
- Human author + human reviewer
- Human author + agent reviewer
- Agent author + human reviewer
- Any combination

### 7.1 Create a Share Link

Enable public access to a note so reviewers can view and comment without an account:

```bash
# Update the note's share access
# Options: "none", "view", "comment", "edit"
jot local update <note-id> shareAccess comment
```

The share URL is: `http://localhost:3210/s/<share-id>`

### 7.2 Reviewer Adds Comments

**Via browser (no login required with share URL):**
1. Open the share URL
2. Select any text in the document
3. Add an inline comment

**Via CLI (if reviewer has an API key):**

```bash
jot local comment <note-id> "exact quoted text" "Your feedback here"
```

### 7.3 Author Reads Comments

```bash
# Read note with all comments
jot local read <note-id>
```

The output shows:
- Full markdown content
- Thread IDs and message IDs
- Author and timestamps

### 7.4 Author Responds and Revises

**Reply to a comment:**

```bash
jot local reply <note-id> <thread-id> <message-id> "Your response here"
```

**Revise the document:**

```bash
# Apply text edits (JSON array of {oldText, newText})
jot local edit <note-id> '[{"oldText":"Task one","newText":"Task one (updated)"}]'

# Or replace the entire markdown
jot local update <note-id> markdown "# Updated content..."
```

**Mark a thread as resolved when consensus is reached:**

```bash
jot local resolve <note-id> <thread-id>
```

---

## Example: Complete Planning Session

**1. Author creates a plan:**

```bash
jot local create "Database Migration RFC"
jot local update <id> markdown "# Database Migration RFC

## Current State
We use SQLite for article storage.

## Proposal
Migrate to PostgreSQL for better concurrency.

## Risks
- Data migration complexity
- Connection pooling setup
"
jot local update <id> shareAccess comment
```

**2. Reviewer opens the share URL and comments:**

> On: "Migrate to PostgreSQL for better concurrency."  
> Comment: "What about read replicas? We have heavy read load."

**3. Author reads and responds:**

```bash
jot local read <id>
# Sees the comment on the PostgreSQL line
jot local reply <id> <thread-id> <msg-id> "Good point. I'll add a section on read replicas and connection pooling."
```

**4. Author updates the document:**

```bash
jot local edit <id> '[{"oldText":"## Risks","newText":"## Read Replicas\nWe will configure 2 read replicas for the heavy aggregation queries.\n\n## Risks"}]'
```

**5. Reviewer resolves the thread when satisfied**

---

## Useful Commands

| Command | Description |
|---------|-------------|
| `jot local list` | List all notes |
| `jot local read <id>` | Read note with comments |
| `jot local create [title]` | Create a new note |
| `jot local update <id> markdown "..."` | Replace full content |
| `jot local update <id> shareAccess <level>` | Set sharing permissions |
| `jot local edit <id> '[{oldText, newText}]'` | Apply text edits |
| `jot local comment <id> "quote" "body"` | Comment on quoted text |
| `jot local reply <id> <tid> <mid> "body"` | Reply to a comment |
| `jot local resolve <id> <tid>` | Mark thread as resolved |
| `jot local reopen <id> <tid>` | Reopen a resolved thread |
| `jot local delete <id>` | Delete a note |

---

## Docker Management

```bash
# View logs
docker logs jot -f

# Stop the server
docker compose -f docker-compose.local.yml down

# Start again (data persists in volume)
docker compose -f docker-compose.local.yml up -d

# Restart
docker restart jot

# Open shell in container
docker exec -it jot sh
```

---

## Data Persistence

All data is stored in a Docker volume (`jot_data`) mounted at `/app/data`:

```
data/
  auth.json          # Owner password and tokens
  notes/
    <id>.md          # Markdown content
    <id>.json        # Metadata and comment threads
```

The volume persists across container restarts and rebuilds.

---

## Tips for Effective Collaboration

1. **Use descriptive titles** — Makes it easy to find plans via `jot local list`
2. **Comment on specific text** — Select exact quotes so the author knows precisely what to address
3. **Resolve threads** — Clear signal that consensus is reached
4. **Use checklists** — Great for tracking action items in sprint plans
5. **Set appropriate share access** — `view` for read-only, `comment` for feedback, `edit` for full collaboration
6. **Threaded replies** — Ask clarifying questions before making changes

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `401 Unauthorized` | API key is invalid or expired. Create a new one via the web UI or `/api/keys` |
| `Error 400: oldText is empty` | The `edit` command requires non-empty `oldText`. Use `update` to replace full markdown instead |
| Build fails with `npm ci --omit=dev` | Network timeout. Fix Dockerfile to copy `node_modules` from `deps` stage |
| Container won't start | Check port 3210 isn't in use: `lsof -i :3210` |
| Reviewer can't comment | Check that `shareAccess` is set to `comment` or `edit` on the note |

---

## Resources

- [jot Repository](https://github.com/badlogic/jot)
- [jot README](https://github.com/badlogic/jot/blob/main/README.md) — Full API reference and CLI docs
- Local instance: http://localhost:3210

---

*This guide was created based on setting up jot for the news-aggregator project. It documents a generic collaborative planning workflow that works for any combination of humans and agents.*