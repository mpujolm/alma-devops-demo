@IsTest
private class AlmaOrderEntryControllerTest {

    @TestSetup
    static void setup() {
        Contact c = new Contact(FirstName = 'Ana', LastName = 'Alma');
        insert c;

        List<Product2> products = new List<Product2>{
            new Product2(Name = 'Crema Hidratante', IsActive = true,
                         Price__c = 15.00, Stock__c = 100, Quantity_ml__c = 50),
            new Product2(Name = 'Jabón Natural', IsActive = true,
                         Price__c = 8.00,  Stock__c = 50,  Quantity_ml__c = 100),
            new Product2(Name = 'Serum Inactivo', IsActive = false,
                         Price__c = 20.00, Stock__c = 10,  Quantity_ml__c = 30)
        };
        insert products;
    }

    // ── getActiveProducts ──────────────────────────────────────────────────────

    @IsTest
    static void testGetActiveProductsReturnsOnlyActive() {
        Test.startTest();
        List<Product2> result = AlmaOrderEntryController.getActiveProducts();
        Test.stopTest();

        System.assertEquals(2, result.size(), 'Solo deben devolverse productos activos');
        for (Product2 p : result) {
            System.assert(p.IsActive, 'Todos los productos deben estar activos');
        }
    }

    @IsTest
    static void testGetActiveProductsFields() {
        Test.startTest();
        List<Product2> result = AlmaOrderEntryController.getActiveProducts();
        Test.stopTest();

        Product2 first = result[0];
        System.assertNotEquals(null, first.Name);
        System.assertNotEquals(null, first.Price__c);
        System.assertNotEquals(null, first.Stock__c);
    }

    // ── getContactIdFromUser ───────────────────────────────────────────────────

    @IsTest
    static void testGetContactIdFromUserInternalUser() {
        // Internal users have no ContactId — method must return null without throwing
        Test.startTest();
        String contactId = AlmaOrderEntryController.getContactIdFromUser();
        Test.stopTest();

        System.assertEquals(null, contactId,
            'Los usuarios internos no tienen ContactId');
    }

    // ── createOrder ────────────────────────────────────────────────────────────

    @IsTest
    static void testCreateOrderSingleLine() {
        Contact contact  = [SELECT Id FROM Contact LIMIT 1];
        Product2 product = [SELECT Id, Price__c FROM Product2 WHERE IsActive = true LIMIT 1];

        AlmaOrderEntryController.OrderLineWrapper line = new AlmaOrderEntryController.OrderLineWrapper();
        line.productId = product.Id;
        line.quantity  = 3;
        line.unitPrice = product.Price__c;

        Test.startTest();
        String orderName = AlmaOrderEntryController.createOrder(
            contact.Id,
            new List<AlmaOrderEntryController.OrderLineWrapper>{ line }
        );
        Test.stopTest();

        System.assertNotEquals(null, orderName, 'El nombre del pedido no debe ser nulo');
        System.assert(orderName.startsWith('ORD-'), 'El autonúmero debe empezar por ORD-');

        OrderRequest__c order = [
            SELECT Contact__c, Status__c, Order_Date__c
            FROM   OrderRequest__c
            LIMIT  1
        ];
        System.assertEquals(contact.Id,    order.Contact__c);
        System.assertEquals('Requested',   order.Status__c);
        System.assertEquals(Date.today(),  order.Order_Date__c);

        List<OrderRequestLineItem__c> items = [
            SELECT Product__c, Quantity__c, Unit_Price__c
            FROM   OrderRequestLineItem__c
        ];
        System.assertEquals(1,          items.size());
        System.assertEquals(product.Id, items[0].Product__c);
        System.assertEquals(3,          items[0].Quantity__c);
        System.assertEquals(product.Price__c, items[0].Unit_Price__c);
    }

    @IsTest
    static void testCreateOrderMultipleLines() {
        Contact contact          = [SELECT Id FROM Contact LIMIT 1];
        List<Product2> products  = [SELECT Id, Price__c FROM Product2 WHERE IsActive = true ORDER BY Name];

        List<AlmaOrderEntryController.OrderLineWrapper> lines =
            new List<AlmaOrderEntryController.OrderLineWrapper>();
        for (Product2 p : products) {
            AlmaOrderEntryController.OrderLineWrapper l = new AlmaOrderEntryController.OrderLineWrapper();
            l.productId = p.Id;
            l.quantity  = 1;
            l.unitPrice = p.Price__c;
            lines.add(l);
        }

        Test.startTest();
        String orderName = AlmaOrderEntryController.createOrder(contact.Id, lines);
        Test.stopTest();

        System.assertNotEquals(null, orderName);
        List<OrderRequestLineItem__c> items = [SELECT Id FROM OrderRequestLineItem__c];
        System.assertEquals(products.size(), items.size(),
            'Debe crearse una línea por producto');
    }

    @IsTest
    static void testCreateOrderNoLines() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];

        Test.startTest();
        String orderName = AlmaOrderEntryController.createOrder(
            contact.Id,
            new List<AlmaOrderEntryController.OrderLineWrapper>()
        );
        Test.stopTest();

        System.assertNotEquals(null, orderName);
        List<OrderRequest__c> orders = [SELECT Id FROM OrderRequest__c];
        System.assertEquals(1, orders.size(), 'Debe crearse la cabecera aunque no haya líneas');
        List<OrderRequestLineItem__c> items = [SELECT Id FROM OrderRequestLineItem__c];
        System.assertEquals(0, items.size(), 'No deben crearse líneas');
    }

    @IsTest
    static void testCreateOrderThrowsOnError() {
        // Passing null lines causes NullPointerException wrapped as AuraHandledException
        // when the list operations are called on null — covered by the null guard,
        // so here we force an error via a bad Product Id on the line item.
        Contact contact = [SELECT Id FROM Contact LIMIT 1];

        AlmaOrderEntryController.OrderLineWrapper badLine = new AlmaOrderEntryController.OrderLineWrapper();
        badLine.productId = contact.Id; // wrong SObject type → DML error
        badLine.quantity  = 1;
        badLine.unitPrice = 10;

        Boolean caughtException = false;
        Test.startTest();
        try {
            AlmaOrderEntryController.createOrder(
                contact.Id,
                new List<AlmaOrderEntryController.OrderLineWrapper>{ badLine }
            );
        } catch (AuraHandledException ex) {
            caughtException = true;
        }
        Test.stopTest();

        System.assert(caughtException, 'Debe lanzarse AuraHandledException ante un error de DML');
    }
}
