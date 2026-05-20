@IsTest
private class OrderCreationControllerTest {

    @TestSetup
    static void setup() {
        insert new Product2(Name = 'Test Product', IsActive = true, Price__c = 10.00, Deposit_Price__c = 2.00);
        insert new Contact(LastName = 'Test Contact');
    }

    @IsTest
    static void testGetActiveProducts() {
        Test.startTest();
        List<Product2> products = OrderCreationController.getActiveProducts();
        Test.stopTest();
        System.assertNotEquals(0, products.size(), 'Should return active products');
    }

    @IsTest
    static void testCreateOrderReturnsContainer() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        Product2 p = [SELECT Id, Deposit_Price__c FROM Product2 LIMIT 1];

        OrderCreationController.LineItemWrapper item = new OrderCreationController.LineItemWrapper();
        item.productId = p.Id;
        item.quantity = 2;
        item.customerPrice = 10.00;
        item.depositPrice = p.Deposit_Price__c;
        item.returnsContainer = true;

        Test.startTest();
        Id orderId = OrderCreationController.createOrder(c.Id, 'Test', 'Cash', new List<OrderCreationController.LineItemWrapper>{ item });
        Test.stopTest();

        OrderRequest__c order = [SELECT Contact__c, Status__c FROM OrderRequest__c WHERE Id = :orderId];
        System.assertEquals(c.Id, order.Contact__c);
        System.assertEquals('Requested', order.Status__c);

        OrderRequestLineItem__c li = [SELECT Deposit_Container__c, Deposit_Price__c FROM OrderRequestLineItem__c WHERE OrderRequest__c = :orderId];
        System.assertEquals(true, li.Deposit_Container__c);
        System.assertEquals(0, li.Deposit_Price__c, 'Deposit should be 0 when container is returned');
    }

    @IsTest
    static void testCreateOrderNoReturn() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        Product2 p = [SELECT Id, Deposit_Price__c FROM Product2 LIMIT 1];

        OrderCreationController.LineItemWrapper item = new OrderCreationController.LineItemWrapper();
        item.productId = p.Id;
        item.quantity = 1;
        item.customerPrice = 10.00;
        item.depositPrice = p.Deposit_Price__c;
        item.returnsContainer = false;

        Test.startTest();
        Id orderId = OrderCreationController.createOrder(c.Id, '', 'Bizum', new List<OrderCreationController.LineItemWrapper>{ item });
        Test.stopTest();

        OrderRequestLineItem__c li = [SELECT Deposit_Container__c, Deposit_Price__c FROM OrderRequestLineItem__c WHERE OrderRequest__c = :orderId];
        System.assertEquals(false, li.Deposit_Container__c);
        System.assertEquals(p.Deposit_Price__c, li.Deposit_Price__c, 'Deposit should be charged when container is not returned');
    }

    @IsTest
    static void testCreateOrderMultipleItems() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        Product2 p = [SELECT Id, Deposit_Price__c FROM Product2 LIMIT 1];

        List<OrderCreationController.LineItemWrapper> items = new List<OrderCreationController.LineItemWrapper>();
        for (Integer i = 0; i < 3; i++) {
            OrderCreationController.LineItemWrapper item = new OrderCreationController.LineItemWrapper();
            item.productId = p.Id;
            item.quantity = i + 1;
            item.customerPrice = 10.00;
            item.depositPrice = p.Deposit_Price__c;
            item.returnsContainer = Math.mod(i, 2) == 0;
            items.add(item);
        }

        Test.startTest();
        Id orderId = OrderCreationController.createOrder(c.Id, 'Bulk test', 'Bank Transfer', items);
        Test.stopTest();

        System.assertEquals(3, [SELECT COUNT() FROM OrderRequestLineItem__c WHERE OrderRequest__c = :orderId], 'Should have 3 line items');
    }
}