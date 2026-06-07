# 🚀 Jira Agile Roadmap Automation Engine

An automated bash orchestration script that parses a clean Markdown file and populates it directly into an Atlassian Jira Agile Board. It instantly transforms high-level Sprint blocks into Jira **Epics** and daily bullet points into **Tasks** nested directly underneath their parent containers.

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
1. Navigate to your Atlassian Security Profile page: [id.atlassian.com/manage-profile/security/api-tokens](https://id.atlassian.com/manage-profile/security/api-tokens).
2. Click **Create API Token**.
3. Label it (e.g., `roadmap-automation`) and save the token securely.

---

## 🚀 Quick Start Guide

### Step 1: Prepare Your Workspace
Ensure both files (`export-to-jira.sh` and your structured `roadmap.md`) are stored within the same root folder level. Open `export-to-jira.sh` and configure your specific environment details under the `CONFIGURATION` block.

### Step 2: Configure System Permissions
To ensure the script can execute safely while maintaining strict ownership boundaries, assign the exact numeric permission matrix `764` via the Linux terminal:

```bash
chmod 764 export-to-jira.sh
```
### Step 3: Running the script
./export-to-jira.sh API-Token 
