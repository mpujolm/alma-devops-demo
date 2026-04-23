# Alma Natural Cosmetics — Data Dictionary

Last updated: 2026-04-23

---

## Objects Overview

| Object | API Name | Type | Description |
|---|---|---|---|
| Contact | `Contact` | Standard | Alma customers |
| Order Request | `OrderRequest__c` | Custom | Customer order headers |
| Order Request Line Item | `OrderRequestLineItem__c` | Custom | Individual product lines within an order |
| Product Catalog | `Product2` | Standard | Alma product catalog *(custom fields pending)* |
| Recipe | `Recipe__c` | Custom | Product recipes |
| Recipe Line Item | `Recipe_Line_Item__c` | Custom | Ingredients within a recipe |
| Raw Material | `Raw_Material__c` | Custom | Raw ingredients used in recipes |

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

## Product Catalog (`Product2`)

Standard Salesforce object extended with Alma-specific fields.

| Field Label | API Name | Type | Required | Description |
|---|---|---|---|---|
| Product Name | `Name` | Text | ✅ | Commercial product name |
| Description | `Description` | Text Area | | Standard product description |
| Price | `Price__c` | Currency | | Selling price excl. container deposit |
| Production Cost | `Production_Cost__c` | Currency | | Production cost excl. container deposit |
| Margin % | `Margin_Percent__c` | Percent (2 dec.) | | % profit on production cost |
| Euros Margin | `Euros_Margin__c` | Currency | | Margin amount in euros |
| Stock | `Stock__c` | Number (0 dec.) | | Available units in stock |
| Batch Production | `Batch_Production__c` | Number (0 dec.) | | Units produced per production batch |
| Quantity (ml) | `Quantity_ml__c` | Number (0 dec.) | | Product volume in ml |
| Deposit Price | `Deposit_Price__c` | Currency | | Container deposit price for this product |
| Product Image | `Product_Image__c` | HTML | | Product image (rich text / HTML) |
| Recipe | `Recipe__c` | Lookup (Recipe__c) | | Recipe linked to this product |

**Relationships:**
- One Product → Many Order Request Line Items (via `OrderRequestLineItem__c.Product__c`)
- One Product → One Recipe (via `Recipe__c`)

---

## Recipe (`Recipe__c`)

Product recipes defining ingredients, quantities and properties.

| Field Label | API Name | Type | Required | Description |
|---|---|---|---|---|
| Recipe Name | `Name` | Text | ✅ | Recipe name |
| Description | `Description__c` | Text (255) | | Recipe description, properties and usage instructions |
| Total Quantity (ml) | `Total_Quantity_ml__c` | Number (0 dec.) | | Total volume produced by the recipe in ml |
| Expiration Date | `Expiration_Date__c` | Number (0 dec.) | | Shelf life in months from manufacture (unopened) |
| PAO | `PAO__c` | Number (0 dec.) | | Period After Opening in months |
| Skin Type | `Skin_Type__c` | Picklist | | Skin type: Normal, Dry Skin, Oily Skin, Family Skin Care |
| Product Category | `Product_Category__c` | Picklist | | Category: Cleaning product, Cosmetic, Kids cosmetic, Shower gel, Shampoo |

**Relationships:**
- One Recipe → Many Recipe Line Items (via `Recipe_Line_Item__c.Recipe__c`)
- One Recipe → Many Products (via `Product2.Recipe__c`)

---

## Recipe Line Item (`Recipe_Line_Item__c`)

Individual ingredient lines within a Recipe.

| Field Label | API Name | Type | Required | Description |
|---|---|---|---|---|
| Line Item Name | `Name` | Text | ✅ | Ingredient line identifier |
| Recipe | `Recipe__c` | Lookup (Recipe__c) | | Parent recipe |
| Raw Material | `Raw_Material__c` | Lookup (Raw_Material__c) | | Ingredient used in this line |
| Quantity | `Quantity__c` | Number (0 dec.) | | Quantity of ingredient in grams |
| Price | `Price__c` | Currency | | Price of this ingredient line in euros |

**Relationships:**
- Many Recipe Line Items → One Recipe (Lookup via `Recipe__c`)
- Many Recipe Line Items → One Raw Material (Lookup via `Raw_Material__c`)

---

## Raw Material (`Raw_Material__c`)

Raw ingredients catalogue used in product recipes.

| Field Label | API Name | Type | Required | Description |
|---|---|---|---|---|
| Material Name | `Name` | Text | ✅ | Common name of the ingredient |
| INCI | `INCI__c` | Text (255) | | Official INCI nomenclature name |
| Material Category | `Material_Category__c` | Picklist | | Category: Tensionactivo, Principio activo, Aceite esencial/Aroma, Liquido, Conservante, Emulsionante, Aceites |
| Quantity | `Quantity__c` | Number (0 dec.) | | Available stock in grams |
| Price | `Price__c` | Currency | | Price in euros of the raw material |

**Relationships:**
- One Raw Material → Many Recipe Line Items (Lookup via `Recipe_Line_Item__c.Raw_Material__c`)

---

## Relationships Diagram

```
Contact
  └── OrderRequest__c (1:N via Contact__c)
        └── OrderRequestLineItem__c (Master-Detail)
              └── Product2 (Lookup via Product__c)

Recipe__c
  ├── Recipe_Line_Item__c (1:N via Recipe__c)
  │     └── Raw_Material__c (Lookup via Raw_Material__c)
  └── Product2 (1:N via Recipe__c)

Product2
  └── OrderRequestLineItem__c (Lookup via Product__c)
```

---

## Permission Sets

| Permission Set | API Name | Assigned To | Access |
|---|---|---|---|
| Alma User | `Alma_User` | Ana Pérez, Miquel Pujol | CRUD on OrderRequest__c, OrderRequestLineItem__c + Edit on all custom fields |
