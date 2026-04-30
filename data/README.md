# Sample Data Import

This folder contains sample records for the Alma project. Import them in the following order to respect object dependencies.

## Prerequisites

Make sure the metadata from the latest `main` branch has been deployed to your org before importing data.

## Import Order

```bash
# 1. Raw Materials (no dependencies)
sf data import tree --target-org <your-org> --files data/Raw_Material__c.json

# 2. Recipes (no dependencies)
sf data import tree --target-org <your-org> --files data/Recipe__c.json

# 3. Recipe Line Items (depends on Recipe__c and Raw_Material__c)
sf data import tree --target-org <your-org> --files data/Recipe_Line_Item__c.json

# 4. Products (depends on Recipe__c)
sf data import tree --target-org <your-org> --files data/Product2.json
```

## Recalculate Roll-Up Summaries

After importing, run this Apex script to recalculate the `Total_Cost__c` and `Total_Quantity_ml__c` roll-up fields on Recipe__c and populate `Price_total_Recipe_Stored__c` on each line:

```bash
sf apex run --target-org <your-org> --file scripts/apex/recalculate_recipe_rollups.apex
```

## Record Counts

| Object | Records |
|--------|---------|
| Raw_Material__c | 25 |
| Recipe__c | 4 |
| Recipe_Line_Item__c | 32 |
| Product2 | 3 |
