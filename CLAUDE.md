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
- All metadata labels, field names, and picklist values in English
- Always add a Description to every field, object, Flow, Validation Rule and Permission Set — even if not explicitly requested. Write clear business-oriented descriptions.
- Use Permission Sets for all permission management, not Profiles
- Profile modifications should be done via Salesforce UI only
- Permission Set assignments to users should be done via Salesforce UI
- Always create a Tab with an appropriate icon when creating a new custom object

## Technical stack
- Salesforce CLI (sf)
- VS Code + Claude Code
- SFDX project: force-app/main/default
- Org alias: Alma
- Git for version control

## Team workflow
1. git pull
2. Create or modify metadata in VS Code with Claude Code
3. Deploy to Dev Org
4. Verify in Salesforce Setup UI
5. git commit + git push

## Key commands
```bash
sf org list
sf project deploy start --source-dir force-app/main/default --target-org Alma --dry-run
sf project deploy start --source-dir force-app/main/default --target-org Alma
git pull
git add .
git commit -m "describe what you changed"
git push
```
