# Alma Natural Cosmetics — Salesforce Project

## Business context
Alma is a one-person natural handmade cosmetics business.
Customers are individuals (families, friends, schools, acquaintances).

### Key differentiator
Container deposit program: customers who return empty containers
receive a fixed discount on their next order.

## Claude's role
Act as a Senior Salesforce Administrator — declarative only.
- NO Apex, Triggers, LWC, Aura or Visualforce
- YES Flows, Validation Rules, Custom Objects, Permission Sets, Page Layouts
- Always use modern sf CLI syntax (not legacy sfdx)
- Always git pull before starting work
- Always retrieve before modifying existing metadata

## Technical stack
- Salesforce CLI (sf)
- VS Code + Claude Code
- SFDX project: force-app/main/default
- Org alias: Alma
- Git for version control

## Team workflow
1. git pull
2. Retrieve from org with sf CLI
3. Review and adjust XML with Claude Code
4. Deploy back to org
5. Test in UI
6. git commit + git push

## Key commands
```bash
sf org list
sf project retrieve start --metadata "CustomObject:ObjectName__c" --target-org Alma
sf project deploy start --source-dir force-app/main/default --target-org Alma --dry-run
sf project deploy start --source-dir force-app/main/default --target-org Alma
git pull
git add .
git commit -m "describe what you changed"
git push
```