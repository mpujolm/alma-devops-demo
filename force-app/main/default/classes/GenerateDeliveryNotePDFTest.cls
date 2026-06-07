@IsTest
private class GenerateDeliveryNotePDFTest {

    @TestSetup
    static void setup() {
        Contact customer = new Contact(LastName = 'Test Customer');
        insert customer;

        OrderRequest__c order = new OrderRequest__c(
            Contact__c     = customer.Id,
            Order_Date__c  = Date.today(),
            Status__c      = 'Requested',
            Payment_Method__c = 'Cash'
        );
        insert order;

        Product2 product = new Product2(Name = 'Test Cream', IsActive = true);
        insert product;

        OrderRequestLineItem__c lineItem = new OrderRequestLineItem__c(
            OrderRequest__c     = order.Id,
            Product__c          = product.Id,
            Quantity__c         = 2,
            Customer_Price__c   = 15.00,
            Deposit_Container__c = true,
            Unit_Container_Price__c = 1.50
        );
        insert lineItem;
    }

    @IsTest
    static void testGeneratePDFInvocable() {
        OrderRequest__c order = [SELECT Id FROM OrderRequest__c LIMIT 1];

        Test.startTest();
        GenerateDeliveryNotePDF.generatePDF(new List<Id>{ order.Id });
        Test.stopTest();

        // Queueable ran synchronously inside Test.stopTest()
        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :order.Id
        ];
        Assert.areEqual(1, links.size(), 'One PDF file should be attached to the order');

        ContentVersion cv = [
            SELECT Title, PathOnClient, FileType
            FROM ContentVersion
            WHERE ContentDocumentId = :links[0].ContentDocumentId
            LIMIT 1
        ];
        Assert.isTrue(cv.Title.startsWith('Delivery_Note_'), 'File title should start with Delivery_Note_');
        Assert.isTrue(cv.PathOnClient.endsWith('.pdf'), 'File should have .pdf extension');
    }

    @IsTest
    static void testVFControllerWithValidId() {
        OrderRequest__c order = [SELECT Id FROM OrderRequest__c LIMIT 1];

        Test.startTest();
        PageReference pageRef = Page.OrderDeliveryNote;
        pageRef.getParameters().put('id', order.Id);
        Test.setCurrentPage(pageRef);

        OrderDeliveryNoteController ctrl = new OrderDeliveryNoteController();
        Test.stopTest();

        Assert.isNotNull(ctrl.order, 'Order should be loaded');
        Assert.areEqual(order.Id, ctrl.order.Id, 'Loaded order Id should match');
        Assert.areEqual(1, ctrl.lineItems.size(), 'One line item should be loaded');
        Assert.isNotNull(ctrl.generatedDate, 'Generated date should be set');
    }

    @IsTest
    static void testVFControllerWithInvalidId() {
        Test.startTest();
        PageReference pageRef = Page.OrderDeliveryNote;
        pageRef.getParameters().put('id', 'a000000000000000AA');
        Test.setCurrentPage(pageRef);

        OrderDeliveryNoteController ctrl = new OrderDeliveryNoteController();
        Test.stopTest();

        Assert.isNull(ctrl.order, 'Order should be null for invalid Id');
        Assert.areEqual(0, ctrl.lineItems.size(), 'No line items for invalid Id');
    }
}
