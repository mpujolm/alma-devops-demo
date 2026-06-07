@IsTest
public class CreateOrderControllerTest {

    @TestSetup
    static void setup() {
        Contact c = new Contact(LastName = 'Test Customer');
        insert c;

        Product2 p = new Product2(
            Name = 'Test Cream',
            IsActive = true,
            Deposit_Price__c = 2.00
        );
        insert p;
    }

    @IsTest
    static void testGetActiveProducts() {
        Test.startTest();
        List<Product2> result = CreateOrderController.getActiveProducts();
        Test.stopTest();

        System.assert(!result.isEmpty(), 'Should return active products');
    }

    @IsTest
    static void testSaveOrder() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        Product2 p = [SELECT Id FROM Product2 LIMIT 1];

        String linesJson = JSON.serialize(new List<Map<String, Object>>{
            new Map<String, Object>{
                'productId' => p.Id,
                'quantity' => 2,
                'depositContainer' => false,
                'customerPrice' => 10.00,
                'depositPrice' => 2.00
            }
        });

        Test.startTest();
        Id orderId = CreateOrderController.saveOrder(c.Id, linesJson);
        Test.stopTest();

        System.assertNotEquals(null, orderId, 'Order Id should not be null');

        OrderRequest__c order = [SELECT Contact__c, Status__c, Order_Date__c FROM OrderRequest__c WHERE Id = :orderId];
        System.assertEquals(c.Id, order.Contact__c, 'Contact should match');
        System.assertEquals('Requested', order.Status__c, 'Status should be Requested');
        System.assertEquals(Date.today(), order.Order_Date__c, 'Order date should be today');

        List<OrderRequestLineItem__c> items = [
            SELECT Quantity__c, Deposit_Container__c, Customer_Price__c, Deposit_Price__c
            FROM OrderRequestLineItem__c
            WHERE OrderRequest__c = :orderId
        ];
        System.assertEquals(1, items.size(), 'Should have one line item');
        System.assertEquals(2, items[0].Quantity__c, 'Quantity should match');
        System.assertEquals(false, items[0].Deposit_Container__c, 'Deposit container should be false');
        System.assertEquals(10.00, items[0].Customer_Price__c, 'Customer price should match');
        System.assertEquals(2.00, items[0].Deposit_Price__c, 'Deposit price should match');
    }

    @IsTest
    static void testSaveOrderWithContainerReturn() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        Product2 p = [SELECT Id FROM Product2 LIMIT 1];

        String linesJson = JSON.serialize(new List<Map<String, Object>>{
            new Map<String, Object>{
                'productId' => p.Id,
                'quantity' => 1,
                'depositContainer' => true,
                'customerPrice' => 10.00,
                'depositPrice' => 2.00
            }
        });

        Test.startTest();
        Id orderId = CreateOrderController.saveOrder(c.Id, linesJson);
        Test.stopTest();

        OrderRequestLineItem__c item = [
            SELECT Deposit_Container__c FROM OrderRequestLineItem__c WHERE OrderRequest__c = :orderId
        ];
        System.assertEquals(true, item.Deposit_Container__c, 'Deposit container should be true for return');
    }

    @IsTest
    static void testSaveOrderEmptyLinesThrows() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        String linesJson = JSON.serialize(new List<Object>());

        Test.startTest();
        try {
            CreateOrderController.saveOrder(c.Id, linesJson);
            System.assert(false, 'Expected AuraHandledException for empty order');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage() != null, 'Exception message should not be null');
        }
        Test.stopTest();
    }
}
