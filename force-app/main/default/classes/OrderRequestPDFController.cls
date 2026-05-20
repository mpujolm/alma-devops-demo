public with sharing class OrderRequestPDFController {

    public OrderRequest__c orderRequest { get; private set; }
    public List<LineItemWrapper> lineItems { get; private set; }
    public String formattedTotal { get; private set; }

    public class LineItemWrapper {
        public OrderRequestLineItem__c item { get; set; }
        public String productName { get; set; }
        public String formattedUnitPrice { get; set; }
        public String formattedDepositPrice { get; set; }
        public String formattedLineTotal { get; set; }
        public String rowClass { get; set; }

        public LineItemWrapper(OrderRequestLineItem__c item, Integer index) {
            this.item = item;
            this.productName = item.Product__r.Name;
            this.formattedUnitPrice = formatCurrency(item.Unit_Price__c);
            this.formattedDepositPrice = item.Deposit_Container__c ? formatCurrency(item.Deposit_Price__c) : '-';
            this.formattedLineTotal = formatCurrency(item.Line_Total__c);
            this.rowClass = Math.mod(index, 2) == 0 ? '' : 'even';
        }
    }

    public OrderRequestPDFController() {
        Id recordId = ApexPages.currentPage().getParameters().get('id');

        orderRequest = [
            SELECT Id, Name, Order_Date__c, Status__c, Payment_Method__c,
                   Total_Amount__c, Notes__c, Contact__r.Name
            FROM OrderRequest__c
            WHERE Id = :recordId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        List<OrderRequestLineItem__c> items = [
            SELECT Id, Product__r.Name, Quantity__c, Unit_Price__c,
                   Deposit_Price__c, Deposit_Container__c, Line_Total__c
            FROM OrderRequestLineItem__c
            WHERE OrderRequest__c = :recordId
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate ASC
        ];

        lineItems = new List<LineItemWrapper>();
        for (Integer i = 0; i < items.size(); i++) {
            lineItems.add(new LineItemWrapper(items[i], i));
        }

        formattedTotal = formatCurrency(orderRequest.Total_Amount__c);
    }

    private static String formatCurrency(Decimal amount) {
        if (amount == null) return '€ 0.00';
        Decimal rounded = amount.setScale(2);
        String formatted = rounded.toPlainString();
        Integer dotIndex = formatted.indexOf('.');
        if (dotIndex == -1) {
            formatted += '.00';
        } else if (formatted.length() - dotIndex - 1 == 1) {
            formatted += '0';
        }
        return '€ ' + formatted;
    }
}