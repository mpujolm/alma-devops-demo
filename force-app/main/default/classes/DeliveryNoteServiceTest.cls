@IsTest
private class DeliveryNoteServiceTest {

    @TestSetup
    static void setupData() {
        Contact c = new Contact(FirstName = 'Maria', LastName = 'Garcia', Email = 'maria@example.com', Phone = '555-1234');
        insert c;

        Product2 p = new Product2(Name = 'Rose Cream', IsActive = true);
        insert p;

        OrderRequest__c order = new OrderRequest__c(
            Contact__c = c.Id,
            Order_Date__c = Date.today(),
            Status__c = 'Requested'
        );
        insert order;

        OrderRequestLineItem__c li = new OrderRequestLineItem__c(
            OrderRequest__c = order.Id,
            Product__c = p.Id,
            Quantity__c = 2,
            Customer_Price__c = 15.00,
            Deposit_Container__c = false,
            Unit_Container_Price__c = 2.00
        );
        insert li;
    }

    @IsTest
    static void testGeneratePdfAttachesFileToRecord() {
        OrderRequest__c order = [SELECT Id FROM OrderRequest__c LIMIT 1];

        Test.startTest();
        DeliveryNoteService.generateDeliveryNote(new List<Id>{ order.Id });
        Test.stopTest();

        List<ContentVersion> cvList = [SELECT Id, Title FROM ContentVersion WHERE Title LIKE 'Delivery Note%'];
        System.assertEquals(1, cvList.size(), 'Expected one ContentVersion to be created');

        List<ContentDocumentLink> cdlList = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :order.Id];
        System.assertEquals(1, cdlList.size(), 'Expected one ContentDocumentLink on the Order Request');
    }

    @IsTest
    static void testGenerateMultiplePdfs() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        List<OrderRequest__c> orders = new List<OrderRequest__c>{
            new OrderRequest__c(Contact__c = c.Id, Order_Date__c = Date.today(), Status__c = 'Requested'),
            new OrderRequest__c(Contact__c = c.Id, Order_Date__c = Date.today(), Status__c = 'Requested')
        };
        insert orders;
        List<Id> orderIds = new List<Id>{ orders[0].Id, orders[1].Id };

        Test.startTest();
        DeliveryNoteService.generateDeliveryNote(orderIds);
        Test.stopTest();

        List<ContentDocumentLink> cdlList = [
            SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId IN :orderIds
        ];
        System.assertEquals(2, cdlList.size(), 'Expected two ContentDocumentLinks for two orders');
    }

    @IsTest
    static void testEmptyListIsNoOp() {
        Test.startTest();
        DeliveryNoteService.generateDeliveryNote(new List<Id>());
        Test.stopTest();

        List<ContentVersion> cvList = [SELECT Id FROM ContentVersion WHERE Title LIKE 'Delivery Note%'];
        System.assertEquals(0, cvList.size(), 'No ContentVersions should be created for an empty input');
    }

    @IsTest
    static void testInvalidIdIsSkipped() {
        Id fakeId = '801000000000001AAA';

        Test.startTest();
        DeliveryNoteService.generateDeliveryNote(new List<Id>{ fakeId });
        Test.stopTest();

        List<ContentVersion> cvList = [SELECT Id FROM ContentVersion WHERE Title LIKE 'Delivery Note%'];
        System.assertEquals(0, cvList.size(), 'No ContentVersions should be created for a non-existent order');
    }
}