# 🚀 Jira Agile Roadmap Automation Engine

An automated bash orchestration script that parses a clean Markdown file and populates it directly into an Atlassian Jira Agile Board. It instantly transforms high-level Sprint blocks into Jira **Epics** and daily bullet points into **Tasks** nested directly underneath their parent containers.

---

## 🛠️ Architecture Flow

1. **Ingestion Engine:** Reads lines from `roadmap.md` dynamically, stripping whitespace and multi-platform carriage returns (`\r`).
2. **Context Tracker:** When a Header (`##`) is evaluated, a live Jira API request initiates an **Epic**. The script stores its global issue key (e.g., `PROJ-1`).
3. **Task Relational Mapping:** Every subsequent text string is structured into an atomic task payload using `jq`, referencing the global parent epic key to construct a nested relational board layout.

---

## 📋 Prerequisites

### 1. Install JSON Dependencies

The pipeline utilizes the `jq` utility package for secure JSON payload generation. Install it via your local OS package manager:

* **macOS:** `brew install jq`
* **Ubuntu/Debian:** `sudo apt install jq`

### 2. Generate an Atlassian API Token

To authenticate safely without displaying your password:

1. Navigate to your Atlassian Security Profile page.
2. Click **Create API Token**.
3. Label it (e.g., `roadmap-automation`) and save the token securely.

---

## ⚙️ Configuration Parameters

Before running the automation engine, update the `CONFIGURATION` section inside `export-to-jira.sh` with your Jira environment details.

### JIRA_URL

**What it is:**
The base web address of your Jira Cloud instance. The script uses this value to determine which Jira server should receive API requests.

**Where to find it:**

1. Open Jira in your web browser.
2. Log in to your Atlassian account.
3. Copy the first portion of the URL ending with `.atlassian.net`.

**Example:**

```text
https://your-company-name.atlassian.net
```

---

### JIRA_EMAIL

**What it is:**
The email address associated with your Atlassian account. The script combines this email address with your API token to authenticate API requests.

**Where to find it:**

1. Click your profile avatar within Jira.
2. Open **Account Settings** or **Profile**.
3. Copy the email address displayed for your Atlassian account.

**Example:**

```text
john.doe@example.com
```

---

### PROJECT_KEY

**What it is:**
A unique identifier assigned to your Jira project. Jira prefixes every issue created within the project using this key.

**Example:**

```text
LD
```

Resulting issue keys:

```text
LD-1
LD-2
LD-3
```

**Where to find it:**

**Method 1: URL**

1. Open your Jira project.
2. Inspect the browser URL.

Example:

```text
https://your-company-name.atlassian.net/jira/software/projects/LD/boards/1
```

The project key is:

```text
LD
```

**Method 2: Existing Issues**

Look at any issue already created within your project.

Example:

```text
LD-25
```

The prefix (`LD`) is your project key.

> **Important:** Ensure your project is a Company-Managed project and the key contains no hyphens.

---

### INPUT_FILE

**What it is:**
The Markdown roadmap file that the automation engine processes. The script reads this file line-by-line and converts sprint headers into Jira Epics and bullet-point entries into Jira Tasks.

**Where to find it:**

Create the file inside the same directory as your `export-to-jira.sh` script.

**Recommended Structure:**

```text
project-root/
├── export-to-jira.sh
└── roadmap.md
```

**Example Configuration:**

```bash
INPUT_FILE="roadmap.md"
```

---

## 🚀 Quick Start Guide

### Step 1: Prepare Your Workspace

Ensure both files (`export-to-jira.sh` and your structured `roadmap.md`) are stored within the same root folder level.

Example:

```text
project-root/
├── export-to-jira.sh
└── roadmap.md
```

Open `export-to-jira.sh` and configure the required values under the `CONFIGURATION` block.

---

### Step 2: Configure System Permissions

To allow script execution while maintaining proper ownership boundaries, assign execute permissions:

```bash
chmod 764 export-to-jira.sh
```

---

### Step 3: Run the Automation Engine

Execute the script and provide your Atlassian API Token as an argument:

```bash
./export-to-jira.sh <API_TOKEN>
```

Example:

```bash
./export-to-jira.sh ATATT3xFfGF0...
```

---

## 📝 Example Roadmap Structure

```markdown
## Sprint 1 - Project Foundation

- Create repository structure
- Configure CI/CD pipeline
- Setup development environment

## Sprint 2 - Core Features

- Implement authentication
- Create user management module
- Build dashboard UI
```

The automation engine will automatically create:

* **Epic:** Sprint 1 - Project Foundation

  * Task: Create repository structure
  * Task: Configure CI/CD pipeline
  * Task: Setup development environment

* **Epic:** Sprint 2 - Core Features

  * Task: Implement authentication
  * Task: Create user management module
  * Task: Build dashboard UI

---

## 🎯 Result

After execution, your Jira board will contain:

* Automatically generated Epics from Markdown headers (`##`)
* Automatically generated Tasks from bullet-point entries
* Parent-child relationships maintained between Epics and Tasks
* Consistent issue hierarchy without manual Jira data entry

This enables teams to manage sprint planning directly from a version-controlled Markdown roadmap while keeping Jira synchronized automatically.
