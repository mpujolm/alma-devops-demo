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
- Whenever creating any new Object, Field, Tab, App, or anything else that requires permissions, always ask whether to add the necessary permissions to the **Alma_User** Permission Set before finishing
- Always retrieve a Page Layout or Permission Set before modifying it — never overwrite without retrieving first
- Before retrieving changes for any object or feature area, always run `sf org list metadata --metadata-type <Type>` for each relevant metadata type (e.g. FlexiPage, Layout, CustomField, CustomObject) and compare against local files — to catch new org metadata not yet present in the project, not just modified tracked files

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
