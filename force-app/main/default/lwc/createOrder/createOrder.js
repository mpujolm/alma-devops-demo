import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getActiveProducts from '@salesforce/apex/CreateOrderController.getActiveProducts';
import saveOrder from '@salesforce/apex/CreateOrderController.saveOrder';

const EUR = new Intl.NumberFormat('es-ES', { style: 'currency', currency: 'EUR' });

export default class CreateOrder extends NavigationMixin(LightningElement) {
    @api recordId;

    _products = [];
    _inputs = {};
    isLoading = true;
    isSaving = false;
    error;

    connectedCallback() {
        getActiveProducts()
            .then(products => {
                this._products = products;
                this.isLoading = false;
            })
            .catch(err => {
                this.error = err.body?.message || 'Error loading products';
                this.isLoading = false;
            });
    }

    get orderLines() {
        return this._products.map(p => {
            const { quantity = 0, depositContainer = false } = this._inputs[p.Id] || {};
            const lineTotal =
                quantity * (p.Customer_Price__c || 0) +
                (depositContainer ? 0 : p.Deposit_Price__c || 0);
            return {
                productId: p.Id,
                name: p.Name,
                customerPrice: p.Customer_Price__c || 0,
                depositPrice: p.Deposit_Price__c || 0,
                quantity,
                depositContainer,
                lineTotal,
                formattedCustomerPrice: EUR.format(p.Customer_Price__c || 0),
                formattedDepositPrice: EUR.format(p.Deposit_Price__c || 0),
                formattedLineTotal: EUR.format(lineTotal),
            };
        });
    }

    get grandTotal() {
        return this.orderLines.reduce((sum, line) => sum + line.lineTotal, 0);
    }

    get formattedGrandTotal() {
        return EUR.format(this.grandTotal);
    }

    handleQuantityChange(event) {
        const productId = event.target.dataset.id;
        const quantity = Math.max(0, Number(event.target.value) || 0);
        this._inputs = {
            ...this._inputs,
            [productId]: { ...(this._inputs[productId] || { depositContainer: false }), quantity }
        };
    }

    handleDepositChange(event) {
        const productId = event.target.dataset.id;
        const depositContainer = event.target.checked;
        this._inputs = {
            ...this._inputs,
            [productId]: { ...(this._inputs[productId] || { quantity: 0 }), depositContainer }
        };
    }

    handleSave() {
        const linesToSave = this.orderLines.filter(l => l.quantity > 0);
        if (linesToSave.length === 0) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Validation',
                message: 'Please add at least one product with a quantity greater than zero.',
                variant: 'warning'
            }));
            return;
        }
        this.isSaving = true;
        const orderLines = JSON.stringify(
            linesToSave.map(l => ({
                productId: l.productId,
                quantity: l.quantity,
                depositContainer: l.depositContainer,
                customerPrice: l.customerPrice,
                depositPrice: l.depositPrice
            }))
        );
        saveOrder({ contactId: this.recordId, orderLines })
            .then(orderId => {
                this.isSaving = false;
                this._inputs = {};
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Order created successfully.',
                    variant: 'success'
                }));
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: { recordId: orderId, actionName: 'view' }
                });
            })
            .catch(err => {
                this.isSaving = false;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: err.body?.message || 'Failed to create order.',
                    variant: 'error'
                }));
            });
    }
}
