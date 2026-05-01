public with sharing class OrderRequestPDFGenerator {

    public class Request {
        @InvocableVariable(label='Order Request ID' required=true)
        public Id orderRequestId;
    }

    @InvocableMethod(
        label='Generate Order Confirmation PDF'
        description='Generates a branded PDF confirmation for an Order Request and attaches it as a File on the record. Called by the OrderRequest Generate PDF on Delivered Flow.'
    )
    public static void generatePDF(List<Request> requests) {
        List<Id> orderIds = new List<Id>();
        for (Request req : requests) {
            orderIds.add(req.orderRequestId);
        }

        Map<Id, OrderRequest__c> ordersMap = new Map<Id, OrderRequest__c>([
            SELECT Id, Name
            FROM OrderRequest__c
            WHERE Id IN :orderIds
            WITH SECURITY_ENFORCED
        ]);

        List<ContentVersion> versionsToInsert = new List<ContentVersion>();

        for (Request req : requests) {
            OrderRequest__c order = ordersMap.get(req.orderRequestId);

            Blob pdfBlob;
            if (Test.isRunningTest()) {
                pdfBlob = Blob.valueOf('PDF placeholder for tests');
            } else {
                PageReference pdfPage = Page.OrderRequestPDF;
                pdfPage.getParameters().put('id', req.orderRequestId);
                pdfBlob = pdfPage.getContentAsPDF();
            }

            ContentVersion cv = new ContentVersion();
            cv.Title = 'Order Confirmation - ' + order.Name;
            cv.PathOnClient = 'OrderConfirmation_' + order.Name + '.pdf';
            cv.VersionData = pdfBlob;
            // Setting FirstPublishLocationId automatically creates the ContentDocumentLink
            cv.FirstPublishLocationId = req.orderRequestId;
            versionsToInsert.add(cv);
        }

        insert versionsToInsert;
    }
}
