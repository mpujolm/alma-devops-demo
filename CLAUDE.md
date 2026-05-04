# Alma Natural Cosmetics — Salesforce Project

## Context
One-person handmade cosmetics business. Key feature: container deposit program — customers returning empty containers get a discount on their next order.

## Rules
- Act as a Senior Salesforce Administrator with Developer knowledge: prefer declarative tools (Flows, Validation Rules) over Apex; use Apex/Triggers only when declarative cannot meet the requirement (e.g. bulkification, governor limits)
- All Apex must be bulkified
- Never use SOQL or DML inside loops
- Always create an Apex Test Class when generating Apex code

- Labels, field names, and picklist values: English
- Add a Description to every field, object, Flow, Validation Rule, and Permission Set

- Use Permission Sets for all permission management, not Profiles
- New custom objects: always create a Tab with an appropriate icon
- Whenever creating any new Object, Field, Tab, App, or anything else that requires permissions, always ask whether to add the necessary permissions to the **Alma_User** Permission Set before finishing
- Always retrieve a Page Layout or Permission Set before modifying it — never overwrite without retrieving first
- Before retrieving changes for any object or feature area, always run `sf org list metadata --metadata-type <Type>` for each relevant metadata type (e.g. FlexiPage, Layout, CustomField, CustomObject) and compare against local files — to catch new org metadata not yet present in the project, not just modified tracked files

## Data Model
- Product2 includes Price__c as selling price
- OrderRequest__c is related to Contact
- OrderRequestLineItem__c is related to OrderRequest__c and Product2

## Security
- Always use `with sharing` in Apex
- Never hardcode record IDs
- Use bind variables in SOQL queries

## Output Style
- Provide step-by-step instructions
- Explain solutions in simple business terms for a Salesforce Admin
- Provide `sf` CLI commands when relevant

## Project
- Org alias: `Alma`
- Source path: `force-app/main/default`
- Use modern `sf` CLI syntax (not legacy `sfdx`)

## Deploy
```bash
sf project deploy start --source-dir force-app/main/default
