@isTest
private class OrderRequestLineItemTriggerTest {

    // ─── Setup ────────────────────────────────────────────────────────────────
    // Creates one parent OrderRequest and three products with distinct stock levels
    // reused across all test methods to avoid repeated DML in each test.

    @TestSetup
    static void setup() {
        insert new OrderRequest__c(Order_Date__c = Date.today());

        insert new List<Product2>{
            new Product2(Name = 'Product High Stock',   IsActive = true, Stock__c = 100),
            new Product2(Name = 'Product Low Stock',    IsActive = true, Stock__c = 7),
            new Product2(Name = 'Product At Threshold', IsActive = true, Stock__c = 10)
        };
    }

    static OrderRequest__c getOrderRequest() {
        return [SELECT Id FROM OrderRequest__c LIMIT 1];
    }

    static Product2 getProduct(String name) {
        return [SELECT Id, Stock__c FROM Product2 WHERE Name = :name LIMIT 1];
    }

    static OrderRequestLineItem__c makeLine(Id productId, Id orderRequestId, Decimal qty) {
        return new OrderRequestLineItem__c(
            Product__c      = productId,
            OrderRequest__c = orderRequestId,
            Quantity__c     = qty,
            Unit_Price__c   = 10
        );
    }

    // ─── Test 1: Stock is correctly reduced; no case when above threshold ─────
    @isTest
    static void testStockReducedAboveThreshold() {
        Product2        p   = getProduct('Product High Stock');
        OrderRequest__c req = getOrderRequest();

        Test.startTest();
        insert makeLine(p.Id, req.Id, 10);
        Test.stopTest();

        Assert.areEqual(
            90,
            [SELECT Stock__c FROM Product2 WHERE Id = :p.Id].Stock__c,
            'Stock should decrease by 10'
        );
        Assert.areEqual(
            0,
            [SELECT COUNT() FROM Case WHERE Subject LIKE '%Product High Stock%'],
            'No case should be created when stock stays above threshold'
        );
    }

    // ─── Test 2: Stock drops below 5 → case is created with correct fields ───
    @isTest
    static void testCaseCreatedWhenStockBelowThreshold() {
        Product2        p   = getProduct('Product Low Stock'); // Stock = 7
        OrderRequest__c req = getOrderRequest();

        Test.startTest();
        insert makeLine(p.Id, req.Id, 3); // 7 - 3 = 4
        Test.stopTest();

        Assert.areEqual(
            4,
            [SELECT Stock__c FROM Product2 WHERE Id = :p.Id].Stock__c,
            'Stock should be 4 after subtracting 3'
        );

        List<Case> cases = [
            SELECT Subject, Priority, Status, Origin, Type
            FROM Case
            WHERE Subject LIKE '%Product Low Stock%'
        ];
        Assert.areEqual(1,              cases.size(),       'Exactly one case should be created');
        Assert.areEqual('High',         cases[0].Priority,  'Priority must be High');
        Assert.areEqual('New',          cases[0].Status,    'Status must be New');
        Assert.areEqual('Internal',     cases[0].Origin,    'Origin must be Internal');
        Assert.areEqual('Restock Alert',cases[0].Type,      'Type must be Restock Alert');
    }

    // ─── Test 3: Stock exactly at 5 → case is created (boundary condition) ───
    @isTest
    static void testCaseCreatedWhenStockExactlyAtThreshold() {
        Product2        p   = getProduct('Product At Threshold'); // Stock = 10
        OrderRequest__c req = getOrderRequest();

        Test.startTest();
        insert makeLine(p.Id, req.Id, 5); // 10 - 5 = 5
        Test.stopTest();

        Assert.areEqual(
            5,
            [SELECT Stock__c FROM Product2 WHERE Id = :p.Id].Stock__c,
            'Stock should be exactly 5'
        );
        Assert.areEqual(
            1,
            [SELECT COUNT() FROM Case WHERE Subject LIKE '%Product At Threshold%'],
            'Case must be created when stock equals exactly 5 (boundary)'
        );
    }

    // ─── Test 4: 200 line items for 200 different products — no governor limits
    @isTest
    static void testBulkInsert200Records() {
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < 200; i++) {
            products.add(new Product2(Name = 'Bulk Product ' + i, IsActive = true, Stock__c = 50));
        }
        insert products;

        OrderRequest__c req = getOrderRequest();
        List<OrderRequestLineItem__c> lineItems = new List<OrderRequestLineItem__c>();
        for (Product2 p : products) {
            lineItems.add(makeLine(p.Id, req.Id, 10));
        }

        Test.startTest();
        insert lineItems;
        Test.stopTest();

        for (Product2 p : [SELECT Stock__c FROM Product2 WHERE Name LIKE 'Bulk Product%']) {
            Assert.areEqual(40, p.Stock__c, 'Each product stock should decrease by 10');
        }
        Assert.areEqual(
            0,
            [SELECT COUNT() FROM Case WHERE Subject LIKE '%Bulk Product%'],
            'No cases when all stocks remain well above threshold'
        );
    }

    // ─── Test 5: Multiple line items for the same product → quantities aggregated
    @isTest
    static void testMultipleLineItemsSameProductAggregated() {
        Product2        p   = getProduct('Product High Stock'); // Stock = 100
        OrderRequest__c req = getOrderRequest();

        List<OrderRequestLineItem__c> lineItems = new List<OrderRequestLineItem__c>();
        for (Integer i = 0; i < 5; i++) {
            lineItems.add(makeLine(p.Id, req.Id, 10));
        }

        Test.startTest();
        insert lineItems; // 5 × 10 = 50 total
        Test.stopTest();

        Assert.areEqual(
            50,
            [SELECT Stock__c FROM Product2 WHERE Id = :p.Id].Stock__c,
            'Quantities must be aggregated: 100 - (5 × 10) = 50'
        );
    }

    // ─── Test 6: Null Product__c → trigger exits gracefully, no exception ─────
    @isTest
    static void testNullProductHandledGracefully() {
        OrderRequest__c req = getOrderRequest();

        Test.startTest();
        Boolean threw = false;
        try {
            insert new OrderRequestLineItem__c(
                Product__c      = null,
                OrderRequest__c = req.Id,
                Quantity__c     = 5,
                Unit_Price__c   = 10
            );
        } catch (Exception e) {
            threw = true;
        }
        Test.stopTest();

        Assert.isFalse(threw, 'A null Product__c should be skipped without throwing an exception');
    }
}
