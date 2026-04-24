public with sharing class AlmaOrderEntryController {

    /**
     * Wrapper for a single order line item passed from the LWC.
     */
    public class OrderLineWrapper {
        @AuraEnabled public Id      productId;
        @AuraEnabled public Decimal quantity;
        @AuraEnabled public Decimal unitPrice;
    }

    /**
     * Returns all active products for the order entry product picker.
     */
    @AuraEnabled(cacheable=true)
    public static List<Product2> getActiveProducts() {
        return [
            SELECT Id, Name, Price__c, Stock__c, Quantity_ml__c
            FROM   Product2
            WHERE  IsActive = true
            ORDER BY Name ASC
        ];
    }

    /**
     * Resolves the Contact Id linked to the currently logged-in Experience Cloud user.
     * Returns null for internal (non-community) users.
     */
    @AuraEnabled(cacheable=true)
    public static String getContactIdFromUser() {
        List<User> users = [
            SELECT ContactId
            FROM   User
            WHERE  Id = :UserInfo.getUserId()
            LIMIT  1
        ];
        if (!users.isEmpty() && users[0].ContactId != null) {
            return users[0].ContactId;
        }
        return null;
    }

    /**
     * Creates an OrderRequest__c header and its OrderRequestLineItem__c children
     * in a single transaction. Returns the auto-number (ORD-XXXX) of the created order.
     * linesJson: JSON array of { productId, quantity, unitPrice } objects.
     */
    @AuraEnabled
    public static String createOrder(Id contactId, String linesJson) {
        try {
            OrderRequest__c order = new OrderRequest__c(
                Contact__c    = contactId,
                Status__c     = 'Requested',
                Order_Date__c = Date.today()
            );
            insert order;

            if (String.isNotBlank(linesJson)) {
                List<OrderLineWrapper> lines = (List<OrderLineWrapper>)
                    JSON.deserialize(linesJson, List<AlmaOrderEntryController.OrderLineWrapper>.class);

                List<OrderRequestLineItem__c> lineItems = new List<OrderRequestLineItem__c>();
                for (OrderLineWrapper line : lines) {
                    lineItems.add(new OrderRequestLineItem__c(
                        OrderRequest__c = order.Id,
                        Product__c      = line.productId,
                        Quantity__c     = line.quantity,
                        Unit_Price__c   = line.unitPrice
                    ));
                }
                if (!lineItems.isEmpty()) insert lineItems;
            }

            return [SELECT Name FROM OrderRequest__c WHERE Id = :order.Id LIMIT 1].Name;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
