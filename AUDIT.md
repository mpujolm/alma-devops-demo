# Alma Natural Cosmetics — Salesforce Metadata Audit

**Fecha:** 2026-05-02  
**Preparado para:** Demo Trailhead Barcelona  
**Org:** Alma (m.pujol.marsal@gmail.com)

---

## Resumen Ejecutivo

| Área | Total | Activos/Habilitados |
|---|---|---|
| Custom Objects | 5 | 5 |
| Custom Flows | 6 | 6 (todos activos) |
| Validation Rules | 1 | 1 |
| Permission Sets | 1 | Alma User |
| FLS Gaps corregidos | 14 | 0 pendientes |

**Modelo de datos central:** Dos cadenas de objetos relacionados.  
- **Pedidos:** `Contact → OrderRequest__c → OrderRequestLineItem__c`  
- **Producción:** `Recipe__c → Recipe_Line_Item__c → Raw_Material__c`

---

## 1. Flows

Todos los flows son **Record-Triggered** y están **activos**.

| Flow Name | Tipo | Objeto | Estado |
|---|---|---|---|
| Alma_Product_LowStockAlert | Record-Triggered | Product2 | Active |
| Update_Price_Recipe_Stored | Record-Triggered | Recipe_Line_Item__c | Active |
| OrderRequest_Generate_PDF_on_Delivered | Record-Triggered | OrderRequest__c | Active |
| Restore_Product_Stock_on_ORLI_Delete | Record-Triggered | OrderRequestLineItem__c | Active |
| Set_Order_Line_Item_Prices_from_Product | Record-Triggered | OrderRequestLineItem__c | Active |
| Update_Product_Stock_on_ORLI_Save | Record-Triggered | OrderRequestLineItem__c | Active |

**Notas:**
- 3 de los 6 flows actúan sobre `OrderRequestLineItem__c`, gestionando precios y stock
- El flow de PDF se dispara al marcar un pedido como "Delivered"
- El flow de stock restaura unidades cuando se elimina una línea de pedido

---

## 2. Validation Rules

| Objeto | Nombre de Regla | Descripción de Negocio | Activa |
|---|---|---|---|
| OrderRequestLineItem__c | Product_Required | Requiere que se seleccione un producto; impide guardar una línea de pedido sin producto asignado | Sí |

**Nota:** Cobertura mínima — hay margen para añadir más reglas de validación en el futuro (p.ej. cantidad > 0, estado de pedido, fechas).

---

## 3. Field-Level Security (FLS)

Auditoría cruzada de todos los campos custom contra los permisos definidos en `Alma_User`. Estado **tras corrección**.

### OrderRequest__c

| Campo | Tipo | Readable | Editable |
|---|---|---|---|
| Contact__c | Lookup | ✓ | ✓ |
| Notes__c | Long Text Area | ✓ | ✓ |
| Order_Date__c | Date | ✓ | ✓ *(corregido)* |
| Payment_Method__c | Picklist | ✓ | ✓ |
| Status__c | Picklist | ✓ | ✓ *(corregido)* |
| Total_Amount__c | Roll-Up Summary | ✓ | — |

### OrderRequestLineItem__c

| Campo | Tipo | Readable | Editable |
|---|---|---|---|
| Deposit_Container__c | Checkbox | ✓ | ✓ |
| Deposit_Price__c | Currency | ✓ | ✓ *(corregido)* |
| Line_Total__c | Formula | ✓ | — *(corregido)* |
| Photo__c | URL | ✓ | ✓ |
| Product__c | Lookup | ✓ | ✓ |
| Quantity__c | Number | ✓ | ✓ *(corregido)* |
| Unit_Price__c | Currency | ✓ | ✓ *(corregido)* |

### Raw_Material__c

| Campo | Tipo | Readable | Editable |
|---|---|---|---|
| INCI__c | Text | ✓ | ✓ |
| Material_Category__c | Picklist | ✓ | ✓ |
| Price__c | Currency | ✓ | ✓ |
| Quantity__c | Number | ✓ | ✓ |

### Recipe__c

| Campo | Tipo | Readable | Editable |
|---|---|---|---|
| Description__c | Text | ✓ | ✓ |
| Expiration_Date__c | Number | ✓ | ✓ |
| PAO__c | Number | ✓ | ✓ |
| Product_Category__c | Picklist | ✓ | ✓ |
| Skin_Type__c | Picklist | ✓ | ✓ |
| Total_Cost__c | Roll-Up Summary | ✓ | — *(corregido)* |
| Total_Quantity_ml__c | Roll-Up Summary | ✓ | ✓ |

### Recipe_Line_Item__c

| Campo | Tipo | Readable | Editable |
|---|---|---|---|
| Price__c | Formula | ✓ | — |
| Price_Recipe__c | Formula | ✓ | — *(corregido)* |
| Price_total_Recipe_Stored__c | Currency | ✓ | ✓ *(corregido)* |
| Quantity__c | Formula | ✓ | — |
| Quantity_Recipe__c | Number | ✓ | ✓ *(corregido)* |
| Raw_Material__c | Lookup | ✓ | ✓ |
| Recipe__c | Lookup | ✓ | ✓ *(corregido)* |

### Contact (campos custom)

| Campo | Tipo | Readable | Editable |
|---|---|---|---|
| Communication_Preferences__c | Multi-Select Picklist | ✓ | ✓ |
| Contact_Origin__c | Picklist | ✓ | ✓ |
| First_Order_Request__c | Date | ✓ | ✓ |
| Languages__c | Text | ✓ | ✓ *(corregido)* |
| Last_Order_Request__c | Date | ✓ | ✓ |
| Level__c | Picklist | ✓ | ✓ *(corregido)* |
| Opt_In_Date__c | Date | ✓ | ✓ |
| Opt_In__c | Checkbox | ✓ | ✓ |
| Preference_Notes__c | Long Text Area | ✓ | ✓ |
| Product_Categories__c | Multi-Select Picklist | ✓ | ✓ |

> **14 campos corregidos** — 2 en OrderRequest__c, 4 en OrderRequestLineItem__c, 1 en Recipe__c, 4 en Recipe_Line_Item__c, 2 en Contact.  
> Campos formula y roll-up marcados como `editable=false` (comportamiento correcto en Salesforce).

---

## 4. Permission Sets

### Resumen de acceso por objeto

| Permission Set | Objetos con acceso CRUD completo | Objetos con acceso parcial |
|---|---|---|
| Alma User | OrderRequest__c, OrderRequestLineItem__c, Raw_Material__c, Recipe_Line_Item__c, Recipe__c | Product2 (sin Modify All / View All), Contact (solo campos custom) |

---

### Alma User

**Descripción:** Grants access to Alma Natural Cosmetics custom objects and fields. Assigned to all active Alma users.

#### Permisos de Objeto

| Objeto | Create | Read | Edit | Delete | Modify All | View All |
|---|---|---|---|---|---|---|
| OrderRequest__c | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| OrderRequestLineItem__c | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Product2 | ✓ | ✓ | ✓ | ✓ | ✗ | ✗ |
| Raw_Material__c | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Recipe_Line_Item__c | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Recipe__c | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |

#### Permisos de Campo destacados

**Contact (campos custom):** Communication_Preferences__c, Contact_Origin__c, First_Order_Request__c, Last_Order_Request__c, Opt_In_Date__c, Opt_In__c, Preference_Notes__c, Product_Categories__c (Read + Edit)

**OrderRequest__c:** Contact__c, Notes__c, Payment_Method__c, Total_Amount__c (Read + Edit)

**OrderRequestLineItem__c:** Deposit_Container__c, Photo__c, Product__c (Read + Edit)

**Product2 (campos custom):** Batch_Production__c, Deposit_Price__c, Euros_Margin__c, Label_Price__c, Labor_cost__c, Margin_Percent__c, Price__c, Product_Image__c, Production_Cost__c, Stock__c, etc. (mayoría Read + Edit; `Product_Category__c` y `Unit_production_quantity__c` solo Read)

**Raw_Material__c:** INCI__c, Material_Category__c, Price__c, Quantity__c (Read + Edit)

**Recipe__c:** Description__c, Expiration_Date__c, PAO__c, Product_Category__c, Skin_Type__c, Total_Quantity_ml__c (Read + Edit)

---

## 5. Custom Objects

### Resumen

| Objeto | Label | Descripción |
|---|---|---|
| OrderRequest__c | Order Request | Cabecera de pedido de cliente. Relacionado con Contact. |
| OrderRequestLineItem__c | Order Request Line Item | Línea de producto dentro de un pedido. Relacionada con OrderRequest__c y Product2. |
| Raw_Material__c | Raw Material | Materias primas/ingredientes usados en recetas de cosmética. |
| Recipe__c | Recipe | Formulaciones/recetas de productos Alma Natural. |
| Recipe_Line_Item__c | Recipe Line Item | Ingrediente individual dentro de una receta con cálculo de coste. |

---

### OrderRequest__c — Order Request

**Descripción:** Stores customer order headers. Each order contains one or more order lines with products and quantities.

| Campo | Label | Tipo | Descripción |
|---|---|---|---|
| Contact__c | Contact | Lookup (Contact) | Cliente que realizó el pedido |
| Order_Date__c | Order Date | Date | Fecha en que el cliente realizó el pedido (requerido) |
| Status__c | Status | Picklist | Estado actual: Requested → In Progress → Ready → Delivered (requerido) |
| Payment_Method__c | Payment Method | Picklist | Método de pago: Bizum, Cash, Bank Transfer |
| Notes__c | Notes | Long Text Area | Notas internas: instrucciones especiales o detalles de entrega |
| Total_Amount__c | Total Amount | Roll-Up Summary (SUM) | Suma automática de los Line Total de todas las líneas del pedido |

---

### OrderRequestLineItem__c — Order Request Line Item

**Descripción:** Línea individual de producto dentro de un pedido. Parte del programa de depósito de envases.

| Campo | Label | Tipo | Descripción |
|---|---|---|---|
| OrderRequest__c | Order Request | Master-Detail | Pedido padre (borrar pedido borra líneas) |
| Product__c | Product | Lookup (Product2) | Producto del catálogo Alma (requerido) |
| Quantity__c | Quantity | Number | Unidades pedidas (requerido) |
| Unit_Price__c | Unit Price | Currency | Precio unitario copiado del producto al guardar (bloqueado en el momento del pedido) |
| Deposit_Container__c | Deposit Container | Checkbox | Indica si se aplica descuento por devolución de envase vacío |
| Deposit_Price__c | Deposit Price | Currency | Precio del depósito copiado del producto al guardar |
| Line_Total__c | Line Total | Formula (Currency) | Total de línea: cantidad × precio unitario, menos depósito si aplica |
| Photo__c | Photo | URL | Enlace a la foto del producto (Google Drive u almacenamiento externo) |

---

### Raw_Material__c — Raw Material

**Descripción:** Materias primas/ingredientes usados en formulaciones de productos cosméticos.

| Campo | Label | Tipo | Descripción |
|---|---|---|---|
| Material_Category__c | Material Category | Picklist | Categoría: Tensionactivo, Principio activo, Aceite esencial/Aroma, Liquido, Conservante, Emulsionante, Aceites |
| INCI__c | INCI | Text(255) | Nombre oficial del ingrediente según nomenclatura INCI |
| Quantity__c | Quantity | Number | Stock en gramos |
| Price__c | Price | Currency | Precio en euros |

---

### Recipe__c — Recipe

**Descripción:** Formulaciones de productos Alma Natural, incluyendo categoría de producto e información de vida útil.

| Campo | Label | Tipo | Descripción |
|---|---|---|---|
| Description__c | Description | Text(255) | Descripción completa, propiedades e instrucciones de uso |
| Product_Category__c | Product Category | Picklist | Categoría: Cleaning product, Cosmetic, Kids cosmetic, Shower gel, Shampoo |
| Skin_Type__c | Skin Type | Picklist | Tipo de piel: Normal, Dry Skin, Oily Skin, Family Skin Care |
| PAO__c | PAO | Number | Period After Opening: meses de uso tras abrir el envase |
| Expiration_Date__c | Expiration Date | Number | Meses hasta caducidad (sin abrir) |
| Total_Cost__c | Total Cost | Roll-Up Summary (SUM) | Coste total de ingredientes de la receta |
| Total_Quantity_ml__c | Total Quantity ml | Roll-Up Summary (SUM) | Producción total en ml |

---

### Recipe_Line_Item__c — Recipe Line Item

**Descripción:** Ingrediente individual dentro de una receta, con cálculo de coste proporcional.

| Campo | Label | Tipo | Descripción |
|---|---|---|---|
| Recipe__c | Recipe | Lookup (Recipe__c) | Receta padre |
| Raw_Material__c | Raw Material | Lookup (Raw_Material__c) | Ingrediente utilizado |
| Quantity_Recipe__c | Quantity | Number | Gramos de este ingrediente en la receta |
| Quantity__c | Quantity (Raw Material) | Formula (Number) | Lee el stock actual de la materia prima relacionada |
| Price__c | Price (Raw Material) | Formula (Currency) | Lee el precio actual de la materia prima relacionada |
| Price_Recipe__c | Price | Formula (Currency) | Coste proporcional: gramos usados × precio / stock total |
| Price_total_Recipe_Stored__c | Price total Recipe Stored | Currency | Coste total almacenado de esta línea de ingrediente |
