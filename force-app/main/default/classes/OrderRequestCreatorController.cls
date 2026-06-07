public with sharing class OrderRequestCreatorController {

    @AuraEnabled(cacheable=true)
    public static List<Product2> getProducts() {
        return [
            SELECT Id, Name, IsActive, Customer_Price__c, Unit_Container_Price__c
            FROM Product2
            WHERE IsActive = true
            ORDER BY Name ASC
        ];
    }

    @AuraEnabled
    public static Id createOrderRequest(Id contactId, String lineItemsJson) {
        List<LineItemWrapper> lineItems;
        try {
            lineItems = (List<LineItemWrapper>) JSON.deserialize(lineItemsJson, List<LineItemWrapper>.class);
        } catch (Exception e) {
            throw new AuraHandledException('Invalid line items data: ' + e.getMessage());
        }

        if (lineItems == null || lineItems.isEmpty()) {
            throw new AuraHandledException('At least one product must be selected.');
        }

        OrderRequest__c orderRequest = new OrderRequest__c(
            Contact__c = contactId,
            Order_Date__c = Date.today(),
            Status__c = 'Requested'
        );

        try {
            insert orderRequest;
        } catch (DmlException e) {
            throw new AuraHandledException('Error creating Order Request: ' + e.getDmlMessage(0));
        }

        List<OrderRequestLineItem__c> lineItemRecords = new List<OrderRequestLineItem__c>();
        for (LineItemWrapper item : lineItems) {
            lineItemRecords.add(new OrderRequestLineItem__c(
                OrderRequest__c = orderRequest.Id,
                Product__c = item.productId,
                Quantity__c = item.quantity,
                Customer_Price__c = item.customerPrice,
                Unit_Container_Price__c = item.depositPrice,
                Deposit_Container__c = item.returnContainer
            ));
        }

        try {
            insert lineItemRecords;
        } catch (DmlException e) {
            throw new AuraHandledException('Error creating line items: ' + e.getDmlMessage(0));
        }

        return orderRequest.Id;
    }

    public class LineItemWrapper {
        @AuraEnabled public Id productId;
        @AuraEnabled public Decimal quantity;
        @AuraEnabled public Boolean returnContainer;
        @AuraEnabled public Decimal customerPrice;
        @AuraEnabled public Decimal depositPrice;
        @AuraEnabled public Decimal lineTotal;
    }
}