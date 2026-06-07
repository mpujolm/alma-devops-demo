/**
 * Controller for the OrderDeliveryNote Visualforce PDF page.
 * Fetches the OrderRequest and its line items using the 'id' URL parameter.
 */
public with sharing class OrderDeliveryNoteController {

    public OrderRequest__c order { get; private set; }
    public List<OrderRequestLineItem__c> lineItems { get; private set; }
    public Date generatedDate { get; private set; }

    public OrderDeliveryNoteController() {
        generatedDate = Date.today();
        String orderId = ApexPages.currentPage().getParameters().get('id');

        List<OrderRequest__c> orders = [
            SELECT Id, Name, Order_Date__c, Status__c, Payment_Method__c,
                   Total_Amount_Ana__c, Contact__r.Name
            FROM OrderRequest__c
            WHERE Id = :orderId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        if (!orders.isEmpty()) {
            order = orders[0];
        }

        lineItems = [
            SELECT Id, Product__r.Name, Quantity__c, Customer_Price__c,
                   Deposit_Container__c, Unit_Container_Price__c, Line_Total__c
            FROM OrderRequestLineItem__c
            WHERE OrderRequest__c = :orderId
            WITH SECURITY_ENFORCED
            ORDER BY Product__r.Name ASC
        ];
    }
}
