/**
 * Invocable Apex called by the "Generate Delivery Note on Ready" Flow.
 * Enqueues a Queueable job to render the OrderDeliveryNote Visualforce page
 * as a PDF and attach it to the OrderRequest record as a ContentVersion file.
 *
 * getContentAsPDF() is not allowed in @future or Batch contexts but IS
 * supported in Queueable, which is why PDF generation is deferred here.
 */
public with sharing class GenerateDeliveryNotePDF {

    @InvocableMethod(
        label='Generate Delivery Note PDF'
        description='Renders the delivery note as a PDF and attaches it to the OrderRequest. Called when Status changes to Ready.'
        category='Order Management'
    )
    public static void generatePDF(List<Id> orderRequestIds) {
        System.enqueueJob(new DeliveryNotePDFQueueable(orderRequestIds));
    }

    public class DeliveryNotePDFQueueable implements Queueable, Database.AllowsCallouts {

        private List<Id> orderRequestIds;

        public DeliveryNotePDFQueueable(List<Id> orderRequestIds) {
            this.orderRequestIds = orderRequestIds;
        }

        public void execute(QueueableContext context) {
            Map<Id, String> orderNames = getOrderNames(orderRequestIds);
            List<ContentVersion> versionsToInsert = new List<ContentVersion>();

            for (Id orderId : orderRequestIds) {
                Blob pdfBlob = renderPdf(orderId);
                String orderName = orderNames.containsKey(orderId) ? orderNames.get(orderId) : String.valueOf(orderId);
                String fileName = 'Delivery_Note_' + orderName.replaceAll('[^a-zA-Z0-9_-]', '_');

                ContentVersion cv = new ContentVersion();
                cv.Title           = fileName;
                cv.PathOnClient    = fileName + '.pdf';
                cv.VersionData     = pdfBlob;
                // Setting FirstPublishLocationId auto-creates the ContentDocumentLink
                cv.FirstPublishLocationId = orderId;
                versionsToInsert.add(cv);
            }

            if (!versionsToInsert.isEmpty()) {
                insert versionsToInsert;
            }
        }

        private Map<Id, String> getOrderNames(List<Id> ids) {
            Map<Id, String> result = new Map<Id, String>();
            for (OrderRequest__c o : [
                SELECT Id, Name FROM OrderRequest__c WHERE Id IN :ids WITH SECURITY_ENFORCED
            ]) {
                result.put(o.Id, o.Name);
            }
            return result;
        }

        private Blob renderPdf(Id orderId) {
            if (Test.isRunningTest()) {
                return Blob.valueOf('PDF_TEST_CONTENT');
            }
            PageReference pdfPage = Page.OrderDeliveryNote;
            pdfPage.getParameters().put('id', orderId);
            return pdfPage.getContentAsPDF();
        }
    }
}
