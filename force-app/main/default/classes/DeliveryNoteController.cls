public with sharing class DeliveryNoteController {
    public OrderRequest__c order { get; private set; }
    public List<OrderRequestLineItem__c> lineItems { get; private set; }
    public Boolean hasNotes { get; private set; }
    public Boolean hasContact { get; private set; }
    public String deliveryDate { get; private set; }
    public String formattedNotes { get; private set; }

    public DeliveryNoteController() {
        hasNotes = false;
        hasContact = false;
        deliveryDate = Date.today().format();
        formattedNotes = '';

        String recordId = ApexPages.currentPage().getParameters().get('id');
        if (String.isBlank(recordId)) return;

        List<OrderRequest__c> orders = [
            SELECT Id, Name, Order_Date__c, Status__c, Payment_Method__c,
                   Notes__c, Total_Amount_Ana__c,
                   Contact__c, Contact__r.Name, Contact__r.Email, Contact__r.Phone
            FROM OrderRequest__c
            WHERE Id = :recordId
            WITH SECURITY_ENFORCED
        ];
        if (orders.isEmpty()) return;

        order = orders[0];
        hasNotes = String.isNotBlank(order.Notes__c);
        hasContact = order.Contact__c != null;
        if (hasNotes) {
            formattedNotes = order.Notes__c.escapeHtml4().replace('\n', '<br/>');
        }

        lineItems = [
            SELECT Id, Name, Product__r.Name, Product_Category__c,
                   Quantity__c, Customer_Price__c, Deposit_Container__c,
                   Unit_Container_Price__c, Line_Total__c
            FROM OrderRequestLineItem__c
            WHERE OrderRequest__c = :recordId
            WITH SECURITY_ENFORCED
            ORDER BY Name
        ];
    }
}