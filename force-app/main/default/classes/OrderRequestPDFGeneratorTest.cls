@IsTest
private class OrderRequestPDFGeneratorTest {

    @TestSetup
    static void setupData() {
        Contact contact = new Contact(
            FirstName = 'Anna',
            LastName = 'Test',
            Email = 'anna.test@example.com'
        );
        insert contact;

        Product2 product = new Product2(
            Name = 'Rose Body Cream',
            IsActive = true,
            Price__c = 18.00,
            Deposit_Price__c = 2.00
        );
        insert product;

        OrderRequest__c order = new OrderRequest__c(
            Contact__c = contact.Id,
            Order_Date__c = Date.today(),
            Status__c = 'Ready',
            Payment_Method__c = 'Bizum'
        );
        insert order;

        OrderRequestLineItem__c lineItem = new OrderRequestLineItem__c(
            OrderRequest__c = order.Id,
            Product__c = product.Id,
            Quantity__c = 2,
            Unit_Price__c = 18.00,
            Deposit_Price__c = 2.00,
            Deposit_Container__c = true
        );
        insert lineItem;
    }

    @IsTest
    static void testGeneratePDFSingleOrder() {
        OrderRequest__c order = [SELECT Id FROM OrderRequest__c LIMIT 1];

        OrderRequestPDFGenerator.Request req = new OrderRequestPDFGenerator.Request();
        req.orderRequestId = order.Id;

        Test.startTest();
        OrderRequestPDFGenerator.generatePDF(new List<OrderRequestPDFGenerator.Request>{ req });
        Test.stopTest();

        List<ContentVersion> files = [
            SELECT Id, Title, PathOnClient
            FROM ContentVersion
            WHERE FirstPublishLocationId = :order.Id
        ];
        Assert.areEqual(1, files.size(), 'One PDF should be attached to the order');
        Assert.isTrue(files[0].Title.startsWith('Order Confirmation'), 'File title should start with Order Confirmation');
        Assert.isTrue(files[0].PathOnClient.endsWith('.pdf'), 'File should have .pdf extension');
    }

    @IsTest
    static void testGeneratePDFBulk() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];

        List<OrderRequest__c> orders = new List<OrderRequest__c>();
        for (Integer i = 0; i < 5; i++) {
            orders.add(new OrderRequest__c(
                Contact__c = contact.Id,
                Order_Date__c = Date.today(),
                Status__c = 'Ready',
                Payment_Method__c = 'Cash'
            ));
        }
        insert orders;

        List<OrderRequestPDFGenerator.Request> requests = new List<OrderRequestPDFGenerator.Request>();
        for (OrderRequest__c order : orders) {
            OrderRequestPDFGenerator.Request req = new OrderRequestPDFGenerator.Request();
            req.orderRequestId = order.Id;
            requests.add(req);
        }

        Test.startTest();
        OrderRequestPDFGenerator.generatePDF(requests);
        Test.stopTest();

        List<Id> orderIds = new List<Id>();
        for (OrderRequest__c o : orders) { orderIds.add(o.Id); }

        List<ContentVersion> files = [
            SELECT Id FROM ContentVersion
            WHERE FirstPublishLocationId IN :orderIds
        ];
        Assert.areEqual(5, files.size(), 'One PDF should be generated per order');
    }
}
