#!/bin/bash
set -e

# ==================== CONFIGURATION ====================
JIRA_URL="https://your-domain.atlassian.net"
JIRA_EMAIL="your-email@example.com"
PROJECT_KEY="PROJ" 
INPUT_FILE="roadmap.md"
# =======================================================

if [ -z "$1" ]; then
    echo "❌ Error: Missing Jira API Token parameter."
    echo "Usage: ./import_roadmap.sh <YOUR_JIRA_API_TOKEN>"
    exit 1
fi

JIRA_TOKEN="$1"

if ! command -v jq &> /dev/null; then
    echo "❌ Error: 'jq' is not installed."
    exit 1
fi

AUTH_HEADER=$(echo -n "${JIRA_EMAIL}:${JIRA_TOKEN}" | base64)
CURRENT_EPIC_KEY=""
TOTAL_TASKS_PROCESSED=0

echo "🚀 Launching Production Deployment Pipeline..."
echo "🔒 Account: $JIRA_EMAIL"
echo "📦 Source Ingestion Target: $INPUT_FILE"
echo "---------------------------------------------------------"

while IFS= read -r line || [ -n "$line" ]; do
    line=$(echo "$line" | tr -d '\r' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    [ -z "$line" ] && continue

    if [[ "$line" =~ ^"## " ]]; then
        EPIC_NAME=$(echo "$line" | sed 's/^## //')
        echo "---------------------------------------------------------"
        echo "🏗️  Creating Sprint Epic: $EPIC_NAME..."

        PAYLOAD=$(jq -n \
            --arg proj "$PROJECT_KEY" \
            --arg sum "$EPIC_NAME" \
            '{"fields": {"project": {"key": $proj}, "summary": $sum, "description": "Agile Sprint Tracker Epic", "issuetype": {"name": "Epic"}}}')

        RESPONSE=$(curl -s -X POST \
            -H "Authorization: Basic ${AUTH_HEADER}" \
            -H "Content-Type: application/json" \
            -d "$PAYLOAD" \
            "${JIRA_URL}/rest/api/2/issue")

        CURRENT_EPIC_KEY=$(echo "$RESPONSE" | jq -r '.key')
        
        if [ "$CURRENT_EPIC_KEY" == "null" ] || [ -z "$CURRENT_EPIC_KEY" ]; then
            echo "❌ Failed to create cloud Epic. API Response: $RESPONSE"
            exit 1
        fi
        echo "✅ Live Epic Created & Registered: $CURRENT_EPIC_KEY"
        echo "---------------------------------------------------------"

    else
        TOTAL_TASKS_PROCESSED=$((TOTAL_TASKS_PROCESSED + 1))
        CLEAN_TASK=$(echo "$line" | sed -E 's/^(-\s*\[\s*\]|-\s*|[*+]\s*|[0-9]+[\.\)]\s*)//')

        echo "     🔹 Registering Task $TOTAL_TASKS_PROCESSED: $CLEAN_TASK..."

        if [ -z "$CURRENT_EPIC_KEY" ]; then
            echo "⚠️  Warning: Orphaned task before Epic. Skipping."
            continue
        fi

        PAYLOAD=$(jq -n \
            --arg proj "$PROJECT_KEY" \
            --arg sum "$CLEAN_TASK" \
            --arg epic "$CURRENT_EPIC_KEY" \
            '{"fields": {"project": {"key": $proj}, "summary": $sum, "description": "DevOps Execution Task", "issuetype": {"name": "Task"}, "parent": {"key": $epic}}}')

        RESPONSE=$(curl -s -X POST \
            -H "Authorization: Basic ${AUTH_HEADER}" \
            -H "Content-Type: application/json" \
            -d "$PAYLOAD" \
            "${JIRA_URL}/rest/api/2/issue")

        TASK_KEY=$(echo "$RESPONSE" | jq -r '.key')
        
        if [ "$TASK_KEY" != "null" ] && [ -n "$TASK_KEY" ]; then
            curl -s -X POST \
                -H "Authorization: Basic ${AUTH_HEADER}" \
                -H "Content-Type: application/json" \
                -d "{\"issues\":[\"$TASK_KEY\"]}" \
                "${JIRA_URL}/rest/api/2/epic/${CURRENT_EPIC_KEY}/issue" > /dev/null || true
                
            echo "         ↳ Saved to Cloud As: $TASK_KEY"
        else
            echo "         ❌ API rejected creation payload. Response: $RESPONSE"
            exit 1
        fi
    fi

done < "$INPUT_FILE"

echo "---------------------------------------------------------"
echo "🎉 Production Import Complete! All items are now populated on your board."