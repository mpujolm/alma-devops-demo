@IsTest
public class OrderRequestCreatorControllerTest {

    @TestSetup
    static void makeData() {
        Contact c = new Contact(FirstName = 'Test', LastName = 'Customer');
        insert c;

        insert new List<Product2>{
            new Product2(Name = 'Cream', IsActive = true, Deposit_Price__c = 2.00),
            new Product2(Name = 'Serum', IsActive = true, Deposit_Price__c = 3.00),
            new Product2(Name = 'Inactive Product', IsActive = false, Deposit_Price__c = 1.00)
        };
    }

    @IsTest
    static void testGetProducts_returnsOnlyActiveProducts() {
        Test.startTest();
        List<Product2> products = OrderRequestCreatorController.getProducts();
        Test.stopTest();

        System.assertEquals(2, products.size(), 'Should return only active products');
        for (Product2 p : products) {
            System.assert(p.IsActive, 'All returned products must be active');
        }
    }

    @IsTest
    static void testCreateOrderRequest_withoutContainerReturn() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        Product2 p = [SELECT Id FROM Product2 WHERE Name = 'Cream' LIMIT 1];

        String lineItemsJson = JSON.serialize(new List<Map<String, Object>>{
            new Map<String, Object>{
                'productId'       => p.Id,
                'quantity'        => 2,
                'returnContainer' => false,
                'customerPrice'   => 15.00,
                'depositPrice'    => 2.00,
                'lineTotal'       => 32.00
            }
        });

        Test.startTest();
        Id orderId = OrderRequestCreatorController.createOrderRequest(c.Id, lineItemsJson);
        Test.stopTest();

        OrderRequest__c order = [SELECT Contact__c, Total_Amount_Ana__c, Status__c, Order_Date__c FROM OrderRequest__c WHERE Id = :orderId];
        System.assertEquals(c.Id, order.Contact__c, 'Contact should match');
        System.assertEquals('Requested', order.Status__c, 'Status should be Requested');
        System.assertEquals(32.00, order.Total_Amount_Ana__c, 'Order total should be 32');
        System.assertEquals(Date.today(), order.Order_Date__c, 'Order date should be today');

        List<OrderRequestLineItem__c> items = [
            SELECT Product__c, Quantity__c, Deposit_Container__c
            FROM OrderRequestLineItem__c WHERE OrderRequest__c = :orderId
        ];
        System.assertEquals(1, items.size(), 'Should have 1 line item');
        System.assertEquals(p.Id, items[0].Product__c);
        System.assertEquals(2, items[0].Quantity__c);
        System.assertEquals(false, items[0].Deposit_Container__c, 'Container not returned');
    }

    @IsTest
    static void testCreateOrderRequest_withContainerReturn() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        Product2 p = [SELECT Id FROM Product2 WHERE Name = 'Serum' LIMIT 1];

        String lineItemsJson = JSON.serialize(new List<Map<String, Object>>{
            new Map<String, Object>{
                'productId'       => p.Id,
                'quantity'        => 1,
                'returnContainer' => true,
                'customerPrice'   => 25.00,
                'depositPrice'    => 3.00,
                'lineTotal'       => 25.00
            }
        });

        Test.startTest();
        Id orderId = OrderRequestCreatorController.createOrderRequest(c.Id, lineItemsJson);
        Test.stopTest();

        OrderRequest__c order = [SELECT Total_Amount_Ana__c FROM OrderRequest__c WHERE Id = :orderId];
        System.assertEquals(25.00, order.Total_Amount_Ana__c, 'Deposit should not be included when container is returned');

        List<OrderRequestLineItem__c> items = [SELECT Deposit_Container__c FROM OrderRequestLineItem__c WHERE OrderRequest__c = :orderId];
        System.assertEquals(true, items[0].Deposit_Container__c, 'Deposit_Container__c should be true');
    }

    @IsTest
    static void testCreateOrderRequest_multipleProducts() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        List<Product2> products = [SELECT Id FROM Product2 WHERE IsActive = true ORDER BY Name];

        String lineItemsJson = JSON.serialize(new List<Map<String, Object>>{
            new Map<String, Object>{
                'productId' => products[0].Id, 'quantity' => 2, 'returnContainer' => false,
                'customerPrice' => 15.00, 'depositPrice' => 2.00, 'lineTotal' => 32.00
            },
            new Map<String, Object>{
                'productId' => products[1].Id, 'quantity' => 3, 'returnContainer' => true,
                'customerPrice' => 25.00, 'depositPrice' => 3.00, 'lineTotal' => 75.00
            }
        });

        Test.startTest();
        Id orderId = OrderRequestCreatorController.createOrderRequest(c.Id, lineItemsJson);
        Test.stopTest();

        OrderRequest__c order = [SELECT Total_Amount_Ana__c FROM OrderRequest__c WHERE Id = :orderId];
        System.assertEquals(107.00, order.Total_Amount_Ana__c, 'Total should be 32 + 75 = 107');

        System.assertEquals(2, [SELECT COUNT() FROM OrderRequestLineItem__c WHERE OrderRequest__c = :orderId], 'Should have 2 line items');
    }

    @IsTest
    static void testCreateOrderRequest_emptyLineItems_throwsException() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();
        try {
            OrderRequestCreatorController.createOrderRequest(c.Id, '[]');
            System.assert(false, 'Expected AuraHandledException');
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e.getMessage(), 'Exception should carry a message');
        }
        Test.stopTest();
    }
}