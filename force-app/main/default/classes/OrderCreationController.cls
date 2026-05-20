public with sharing class OrderCreationController {

    @AuraEnabled(cacheable=true)
    public static List<Product2> getActiveProducts() {
        return [
            SELECT Id, Name, Customer_Price__c, Deposit_Price__c, Product_Category__c
            FROM Product2
            WHERE IsActive = true
            ORDER BY Name
        ];
    }

    @AuraEnabled
    public static Id createOrder(
        Id contactId,
        String notes,
        String paymentMethod,
        List<LineItemWrapper> lineItems
    ) {
        OrderRequest__c order = new OrderRequest__c(
            Contact__c = contactId,
            Notes__c = notes,
            Payment_Method__c = paymentMethod,
            Status__c = 'Requested',
            Order_Date__c = Date.today()
        );
        insert order;

        List<OrderRequestLineItem__c> items = new List<OrderRequestLineItem__c>();
        for (LineItemWrapper item : lineItems) {
            Decimal depositAmt = item.returnsContainer ? 0 : (item.depositPrice != null ? item.depositPrice : 0);
            items.add(new OrderRequestLineItem__c(
                OrderRequest__c = order.Id,
                Product__c = item.productId,
                Quantity__c = item.quantity,
                Unit_Price__c = item.customerPrice,
                Customer_Price__c = item.customerPrice,
                Deposit_Price__c = depositAmt,
                Deposit_Container__c = item.returnsContainer
            ));
        }
        if (!items.isEmpty()) {
            insert items;
        }
        return order.Id;
    }

    public class LineItemWrapper {
        @AuraEnabled public Id productId { get; set; }
        @AuraEnabled public Decimal quantity { get; set; }
        @AuraEnabled public Decimal customerPrice { get; set; }
        @AuraEnabled public Decimal depositPrice { get; set; }
        @AuraEnabled public Boolean returnsContainer { get; set; }
    }
}