# Alma Natural Cosmetics — Salesforce Project

## Context
Small handmade cosmetics business operated by one person.

Key feature: a reusable container deposit program — when customers place a new order, they can return empty containers and receive a discount equivalent to the container deposit value deducted from the new purchase.

## Rules
- Act as a Senior Salesforce Administrator with Developer knowledge: prefer declarative tools (Flows, Validation Rules) over Apex; use Apex/Triggers only when declarative cannot meet the requirement (e.g. bulkification, governor limits)
- All Apex must be bulkified
- Never use SOQL or DML inside loops
- Always create an Apex Test Class when generating Apex code
- Labels, field names, and picklist values: English
- Add a Description to every field, object, Flow, Validation Rule, and Permission Set
- Use Permission Sets for all permission management, not Profiles
- New custom objects: always create a Tab with an appropriate icon
- Whenever creating any new Object, Field, Tab, App, Apex Class, or LWC, always add the necessary permissions to the **Alma_User** Permission Set automatically — do not ask first
- Always retrieve a Page Layout or Permission Set before modifying it — never overwrite without retrieving first
- Run `sf org list metadata --metadata-type <Type>` only when retrieving or modifying existing metadata (e.g. editing a Layout, updating a Permission Set, retrieving a Flow) — skip for net-new metadata creation where there is no risk of overwriting existing work

## Data Model
- Product2 includes Customer_Price__c as selling price (formula: batch price × increase / batch units)
- Product2 has a Lookup to Recipe__c (the recipe used to produce the product)
- Recipe__c has a Master-Detail with Recipe_Line_Item__c (the ingredients/raw materials used)
- Recipe_Line_Item__c has a Lookup to Raw_Material__c (the raw material for each recipe line)
- OrderRequest__c is related to Contact
- OrderRequestLineItem__c is related to OrderRequest__c and Product2

## Security
- Always use `with sharing` in Apex
- Never hardcode record IDs
- Use bind variables in SOQL queries

## Project
- Source path: `force-app/main/default`
- Use modern `sf` CLI syntax (not legacy `sfdx`)
- Always ask before deploying any changes to the org (`sf project deploy start` or equivalent) — never deploy without explicit confirmation
