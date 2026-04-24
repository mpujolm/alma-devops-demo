trigger OrderRequestLineItemTrigger on OrderRequestLineItem__c (after insert) {

    // PHASE 1 — Collect all Product IDs from incoming records, skip nulls
    Set<Id> productIds = new Set<Id>();
    for (OrderRequestLineItem__c li : Trigger.new) {
        if (li.Product__c != null) {
            productIds.add(li.Product__c);
        }
    }
    if (productIds.isEmpty()) return;

    // PHASE 2 — Single SOQL for all products in this transaction
    Map<Id, Product2> productMap = new Map<Id, Product2>(
        [SELECT Id, Name, Stock__c FROM Product2 WHERE Id IN :productIds]
    );

    // PHASE 3 — Aggregate ordered quantities per product in memory
    // Multiple line items may reference the same product; quantities must be summed
    // before touching any record to avoid partial updates
    Map<Id, Decimal> quantityByProduct = new Map<Id, Decimal>();
    for (OrderRequestLineItem__c li : Trigger.new) {
        if (li.Product__c == null || !productMap.containsKey(li.Product__c)) continue;
        Decimal qty = li.Quantity__c != null ? li.Quantity__c : 0;
        Decimal current = quantityByProduct.containsKey(li.Product__c)
            ? quantityByProduct.get(li.Product__c)
            : 0;
        quantityByProduct.put(li.Product__c, current + qty);
    }

    // PHASE 4 — Calculate new stock in memory and flag low-stock products
    List<Product2> productsToUpdate = new List<Product2>();
    List<Case>     casesToCreate    = new List<Case>();

    for (Id productId : quantityByProduct.keySet()) {
        Product2 product     = productMap.get(productId);
        Decimal  currentStock = product.Stock__c != null ? product.Stock__c : 0;
        Decimal  newStock     = currentStock - quantityByProduct.get(productId);

        product.Stock__c = newStock;
        productsToUpdate.add(product);

        if (newStock <= 5) {
            casesToCreate.add(new Case(
                Subject     = '⚠️ Low Stock Alert: ' + product.Name,
                Description = 'Product ' + product.Name + ' has only ' + newStock.intValue()
                            + ' units remaining. Please restock as soon as possible.',
                Status      = 'New',
                Priority    = 'High',
                Origin      = 'Internal',
                Type        = 'Restock Alert'
            ));
        }
    }

    // PHASE 5 — Single DML per operation (2 DML statements max for any batch size)
    if (!productsToUpdate.isEmpty()) update productsToUpdate;
    if (!casesToCreate.isEmpty())    insert casesToCreate;
}
