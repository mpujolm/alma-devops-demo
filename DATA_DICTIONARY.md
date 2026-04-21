# Alma Natural Cosmetics — Data Dictionary

Last updated: 2026-04-21

---

## Objects Overview

| Object | API Name | Type | Description |
|---|---|---|---|
| Contact | `Contact` | Standard | Alma customers |
| Order Request | `OrderRequest__c` | Custom | Customer order headers |
| Order Request Line Item | `OrderRequestLineItem__c` | Custom | Individual product lines within an order |
| Product Catalog | `Product2` | Standard | Alma product catalog *(custom fields pending)* |
| Recipe | `Recipe__c` | Custom | Product recipes *(pending)* |
| Recipe Line Item | `RecipeLineItem__c` | Custom | Ingredients within a recipe *(pending)* |
| Raw Material | `RawMaterial__c` | Custom | Raw ingredients used in recipes *(pending)* |

---

## Contact (Standard Object)

Customer records for Alma. One contact per customer (families, friends, schools, etc.)

| Field Label | API Name | Type | Required | Description |
|---|---|---|---|---|
| Name | `Name` | Name | ✅ | Customer full name |
| Account Name | `AccountId` | Lookup (Account) | | Account the contact belongs to |
| Phone | `Phone` | Phone | | Main phone number |
| Mobile Phone | `MobilePhone` | Phone | | Mobile phone number |
| Email | `Email` | Email | | Email address |
| Birthdate | `Birthdate` | Date | | Date of birth |
| Mailing Address | `MailingAddress` | Address | | Mailing address |
| Other Address | `OtherAddress` | Address | | Secondary address |
| Customer Type | `Customer_Type__c` | Picklist | | Relationship type: Family, Friend, School, Known, Other, New |
| Communication Preferences | `Communication_Preferences__c` | Multi-Select Picklist | | Preferred channels: Email, Phone, WhatsApp, In Person |
| First Order Request | `First_Order_Request__c` | Date | | Date of first order request |
| Last Order Request | `Last_Order_Request__c` | Date | | Date of most recent order request |
| Opt In | `Opt_In__c` | Checkbox | | Marketing communication consent |
| Opt In Date | `Opt_In_Date__c` | Date | | Date consent was given |
| Product Categories | `Product_Categories__c` | Multi-Select Picklist | | Product categories of interest: Cleaning, Cosmetics, Baby Cosmetics, Gels, Shampoo |
| Preference Notes | `Preference_Notes__c` | Long Text Area (32768, 4 lines) | | Free-text notes on preferences, special requests or personal details |

**Relationships:**
- One Contact → Many Order Requests (via `OrderRequest__c.Contact__c`)

---

## Order Request (`OrderRequest__c`)

Customer order headers. Each order has one or more line items.

| Field Label | API Name | Type | Required | Description |
|---|---|---|---|---|
| Order Number | `Name` | Auto Number (ORD-{0000}) | ✅ | Unique auto-generated order identifier |
| Order Date | `Order_Date__c` | Date | ✅ | Date the customer placed the order |
| Status | `Status__c` | Picklist | ✅ | Order status: Requested, In Progress, Ready, Delivered (default: Requested) |
| Contact | `Contact__c` | Lookup (Contact) | | Customer who placed the order |
| Payment Method | `Payment_Method__c` | Picklist | | Payment method: Bizum, Cash, Bank Transfer |
| Total Amount | `Total_Amount__c` | Currency | | Total order amount (sum of all line items + deposits) |
| Notes | `Notes__c` | Long Text Area (32768) | | Internal notes, delivery details, special instructions |

**Relationships:**
- Many Order Requests → One Contact (via `Contact__c`)
- One Order Request → Many Order Request Line Items (Master-Detail)

---

## Order Request Line Item (`OrderRequestLineItem__c`)

Individual product lines within an Order Request.

| Field Label | API Name | Type | Required | Description |
|---|---|---|---|---|
| Line Item Name | `Name` | Auto Number (LI-{0000}) | ✅ | Auto-generated identifier |
| Order Request | `OrderRequest__c` | Master-Detail (OrderRequest__c) | ✅ | Parent order |
| Product | `Product__c` | Lookup (Product2) | | Product from the Alma catalog |
| Quantity | `Quantity__c` | Number (0 dec.) | ✅ | Number of units ordered |
| Unit Price | `Unit_Price__c` | Currency | ✅ | Price per unit at time of order |
| Deposit Container | `Deposit_Container__c` | Checkbox | | Whether a container deposit applies (default: false) |
| Deposit Price | `Deposit_Price__c` | Currency | | Container deposit amount for this line item |
| Photo | `Photo__c` | URL | | Link to product photo (Google Drive or external storage) |

**Relationships:**
- Many Line Items → One Order Request (Master-Detail via `OrderRequest__c`)
- Many Line Items → One Product (Lookup via `Product__c`)

---

## Product Catalog (`Product2`) — Custom Fields Pending

Standard Salesforce object extended with Alma-specific fields.

| Field Label | API Name | Type | Required | Description | Example |
|---|---|---|---|---|---|
| Product Name | `Name` | Text | ✅ | Commercial product name | Crema hidratante lavanda 100ml |
| Description | `Description` | Text Area | | Standard product description | Crema hidratante de día con aceite esencial... |
| Final Price | `Final_Price__c` | Currency | | Selling price excl. container deposit | 10,00 |
| Elaboration Cost | `Elaboration_Cost__c` | Currency | | Production cost excl. container deposit | 5,20 |
| Margin Percent | `Margin_Percent__c` | Percent (2 dec.) | | (Price - Cost) / Cost × 100 | 92,99% |
| Margin Euros | `Margin_Euros__c` | Currency | | Price - Cost in euros | 4,80 |
| Current Stock | `Current_Stock__c` | Number (0 dec.) | | Available units in stock | 10 |
| Units Per Batch | `Units_Per_Batch__c` | Number (0 dec.) | | Units produced per production batch | 10 |
| Volume Ml | `Volume_Ml__c` | Number (0 dec.) | | Product volume in ml | 100 |
| Deposit Price | `Deposit_Price__c` | Currency | | Container deposit price for this product | 1,50 |
| Photo | `Photo__c` | URL | | Product photo filename or URL | Crema_hidr_lav_100.jpg |

> ⚠️ **Pending confirmation:** Should Margin Percent and Margin Euros be formula fields (calculated from Final Price and Elaboration Cost) or editable fields?

**Relationships:**
- One Product → Many Order Request Line Items (via `OrderRequestLineItem__c.Product__c`)
- One Product → Many Recipe Line Items (via `RecipeLineItem__c.Raw_Material__c`) *(pending)*

---

## Recipe (`Recipe__c`) — Pending

Product recipes defining ingredients, quantities and properties.

| Field Label | API Name | Type | Required | Description | Example |
|---|---|---|---|---|---|
| Recipe Name | `Name` | Text | ✅ | Recipe name | Crema hidratante lavanda 100ml |
| Long Description | `Long_Description__c` | Long Text Area (32768) | | Full recipe instructions and usage | Fase I: ponemos al baño maría... |
| Total Quantity Ml | `Total_Quantity_Ml__c` | Number (0 dec.) | | Total volume produced by the recipe in ml | 200 |
| Shelf Life Months | `Shelf_Life_Months__c` | Number (0 dec.) | | Shelf life in months from manufacture | 12 |
| PAO Months | `PAO_Months__c` | Number (0 dec.) | | Period After Opening in months | 3 |
| Skin Type | `Skin_Type__c` | Picklist | | Skin type: Normal, Dry, Oily, All Family | All Family |
| Product Category | `Product_Category__c` | Picklist | | Category: Cleaning, Cosmetics, Baby Cosmetics, Gels, Shampoo | |

**Relationships:**
- One Recipe → Many Recipe Line Items (Master-Detail)

---

## Recipe Line Item (`RecipeLineItem__c`) — Pending

Individual ingredient lines within a Recipe.

| Field Label | API Name | Type | Required | Description | Example |
|---|---|---|---|---|---|
| Line Item Name | `Name` | Auto Number (RLI-{0000}) | ✅ | Auto-generated identifier | RLI-0001 |
| Recipe | `Recipe__c` | Master-Detail (Recipe__c) | ✅ | Parent recipe | |
| Raw Material | `Raw_Material__c` | Lookup (RawMaterial__c) | | Ingredient used in this line | Manteca de Karité |
| Quantity Grams | `Quantity_Grams__c` | Number (2 dec.) | | Quantity of ingredient in grams | 50 |
| Price | `Price__c` | Currency | | Price of this ingredient line | 2,00 |

> ⚠️ **Pending confirmation:** Should Price be a formula from Raw Material's Unit Price × Quantity, or manually entered?

**Relationships:**
- Many Recipe Line Items → One Recipe (Master-Detail via `Recipe__c`)
- Many Recipe Line Items → One Raw Material (Lookup via `Raw_Material__c`)

---

## Raw Material (`RawMaterial__c`) — Pending

Raw ingredients catalogue used in product recipes.

| Field Label | API Name | Type | Required | Description | Example |
|---|---|---|---|---|---|
| Ingredient Name | `Name` | Text | ✅ | Common name of the ingredient | Manteca de Karité |
| INCI Name | `INCI_Name__c` | Text (255) | | Official INCI nomenclature name | Butyrospermum Parkii Butter |
| Stock Quantity | `Stock_Quantity__c` | Number (0 dec.) | | Available stock in grams | 1000 |
| Unit Price | `Unit_Price__c` | Currency | | Price per unit (grams) | 16,00 |

**Relationships:**
- One Raw Material → Many Recipe Line Items (Lookup via `RecipeLineItem__c.Raw_Material__c`)

---

## Relationships Diagram

```
Contact
  └── OrderRequest__c (1:N via Contact__c)
        └── OrderRequestLineItem__c (Master-Detail)
              └── Product2 (Lookup via Product__c)

Recipe__c
  └── RecipeLineItem__c (Master-Detail)
        └── RawMaterial__c (Lookup via Raw_Material__c)

Product2
  ├── OrderRequestLineItem__c (Lookup)
  └── (future: linked to Recipe__c)
```

---

## Permission Sets

| Permission Set | API Name | Assigned To | Access |
|---|---|---|---|
| Alma User | `Alma_User` | Ana Pérez, Miquel Pujol | CRUD on OrderRequest__c, OrderRequestLineItem__c + Edit on all custom fields |
