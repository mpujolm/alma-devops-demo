public with sharing class CreateOrderController {

    @AuraEnabled(cacheable=true)
    public static List<Product2> getActiveProducts() {
        return [
            SELECT Id, Name, Customer_Price__c, Deposit_Price__c
            FROM Product2
            WHERE IsActive = true
            ORDER BY Name
        ];
    }

    @AuraEnabled
    public static Id saveOrder(Id contactId, String orderLines) {
        List<OrderLineInput> lines = (List<OrderLineInput>) JSON.deserialize(
            orderLines, List<OrderLineInput>.class
        );

        if (lines == null || lines.isEmpty()) {
            throw new AuraHandledException('Order must contain at least one line item.');
        }

        OrderRequest__c order = new OrderRequest__c(
            Contact__c = contactId,
            Order_Date__c = Date.today(),
            Status__c = 'Requested'
        );
        insert order;

        List<OrderRequestLineItem__c> lineItems = new List<OrderRequestLineItem__c>();
        for (OrderLineInput line : lines) {
            lineItems.add(new OrderRequestLineItem__c(
                OrderRequest__c = order.Id,
                Product__c = line.productId,
                Quantity__c = line.quantity,
                Deposit_Container__c = line.depositContainer,
                Customer_Price__c = line.customerPrice,
                Unit_Price__c = line.customerPrice,
                Deposit_Price__c = line.depositPrice
            ));
        }
        insert lineItems;

        return order.Id;
    }

    public class OrderLineInput {
        @AuraEnabled public Id productId;
        @AuraEnabled public Decimal quantity;
        @AuraEnabled public Boolean depositContainer;
        @AuraEnabled public Decimal customerPrice;
        @AuraEnabled public Decimal depositPrice;
    }
}
