import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue }           from 'lightning/uiRecordApi';
import CONTACT_NAME from '@salesforce/schema/Contact.Name';

import getActiveProducts     from '@salesforce/apex/AlmaOrderEntryController.getActiveProducts';
import getContactIdFromUser  from '@salesforce/apex/AlmaOrderEntryController.getContactIdFromUser';
import createOrder           from '@salesforce/apex/AlmaOrderEntryController.createOrder';

const STEP_SELECTION    = 'selection';
const STEP_CONFIRMATION = 'confirmation';
const STEP_SUCCESS      = 'success';

export default class AlmaOrderEntry extends LightningElement {

    /** Contact record Id — provided automatically on a Lightning Record Page (internal).
     *  Null when used in Experience Cloud (external). */
    @api recordId;

    // ── State ──────────────────────────────────────────────────────────────────
    @track step        = STEP_SELECTION;
    @track contactId;
    @track contactName = '';
    @track allProducts = [];   // source of truth; mutated on every quantity change
    @track cartLines   = [];
    @track searchTerm  = '';
    @track orderNumber = '';
    @track isLoading   = false;
    @track errorMessage = '';

    // ── Wire: Contact name ─────────────────────────────────────────────────────
    // Fires whenever contactId is set (both internal and external contexts).
    @wire(getRecord, { recordId: '$contactId', fields: [CONTACT_NAME] })
    wiredContact({ data, error }) {
        if (data) {
            this.contactName = getFieldValue(data, CONTACT_NAME);
        } else if (error) {
            // Non-fatal: contact name will appear blank but order can still be placed.
            console.error('AlmaOrderEntry: error al obtener el contacto', error);
        }
    }

    // ── Wire: active products ──────────────────────────────────────────────────
    @wire(getActiveProducts)
    wiredProducts({ data, error }) {
        if (data) {
            this.allProducts = data.map(p => ({
                id               : p.Id,
                name             : p.Name,
                price            : p.Price__c      || 0,
                stock            : p.Stock__c      || 0,
                quantityMl       : p.Quantity_ml__c || '',
                inputQuantity    : 1,
                stockWarning     : false,
                stockWarningMessage: ''
            }));
        } else if (error) {
            this.errorMessage = 'No se pudieron cargar los productos. Recarga la página.';
        }
    }

    // ── Lifecycle ──────────────────────────────────────────────────────────────
    connectedCallback() {
        if (this.recordId) {
            // Internal (App Builder, Contact Record Page): recordId IS the Contact Id.
            this.contactId = this.recordId;
        } else {
            // External (Experience Cloud): resolve Contact from the logged-in community user.
            this.isLoading = true;
            getContactIdFromUser()
                .then(id => {
                    if (id) {
                        this.contactId = id;
                    } else {
                        this.errorMessage =
                            'No se encontró un contacto asociado a tu usuario. Contacta con el administrador.';
                    }
                })
                .catch(err => {
                    this.errorMessage =
                        'Error al identificar tu contacto: ' + this._extractMessage(err);
                })
                .finally(() => {
                    this.isLoading = false;
                });
        }
    }

    // ── Computed: filtered product list ────────────────────────────────────────
    get displayProducts() {
        const term = (this.searchTerm || '').toLowerCase().trim();
        return term
            ? this.allProducts.filter(p => p.name.toLowerCase().includes(term))
            : this.allProducts;
    }

    // ── Search ─────────────────────────────────────────────────────────────────
    handleSearchChange(event) {
        this.searchTerm = event.target.value;
    }

    // ── Quantity change ────────────────────────────────────────────────────────
    handleQuantityChange(event) {
        const productId = event.target.dataset.productid;
        const qty       = Math.max(1, Number(event.target.value) || 1);

        this.allProducts = this.allProducts.map(p => {
            if (p.id !== productId) return p;
            const warn = qty > p.stock;
            return {
                ...p,
                inputQuantity      : qty,
                stockWarning       : warn,
                stockWarningMessage: warn
                    ? `Stock insuficiente — disponible: ${p.stock}`
                    : ''
            };
        });
    }

    // ── Add to cart ────────────────────────────────────────────────────────────
    handleAddToCart(event) {
        const productId = event.currentTarget.dataset.productid;
        const product   = this.allProducts.find(p => p.id === productId);
        if (!product || product.inputQuantity < 1) return;

        const qty  = product.inputQuantity;
        const line = {
            productId  : product.id,
            productName: product.name,
            quantity   : qty,
            unitPrice  : product.price,
            lineTotal  : product.price * qty,
            stockWarning: product.stockWarning
        };

        const existingIdx = this.cartLines.findIndex(l => l.productId === productId);
        if (existingIdx >= 0) {
            this.cartLines = [
                ...this.cartLines.slice(0, existingIdx),
                line,
                ...this.cartLines.slice(existingIdx + 1)
            ];
        } else {
            this.cartLines = [...this.cartLines, line];
        }
    }

    // ── Remove from cart ───────────────────────────────────────────────────────
    handleRemoveFromCart(event) {
        const productId = event.currentTarget.dataset.productid;
        this.cartLines  = this.cartLines.filter(l => l.productId !== productId);
    }

    // ── Navigation ─────────────────────────────────────────────────────────────
    handleGoToConfirmation() {
        if (this.cartLines.length > 0) {
            this.errorMessage = '';
            this.step = STEP_CONFIRMATION;
        }
    }

    handleBackToSelection() {
        this.step = STEP_SELECTION;
    }

    // ── Confirm order ──────────────────────────────────────────────────────────
    handleConfirmOrder() {
        if (!this.contactId) {
            this.errorMessage = 'No se ha podido identificar el contacto. Recarga la página.';
            this.step = STEP_SELECTION;
            return;
        }

        this.isLoading    = true;
        this.errorMessage = '';

        const lines = this.cartLines.map(l => ({
            productId: l.productId,
            quantity : l.quantity,
            unitPrice: l.unitPrice
        }));

        createOrder({ contactId: this.contactId, lines })
            .then(name => {
                this.orderNumber = name;
                this.step        = STEP_SUCCESS;
            })
            .catch(err => {
                this.errorMessage = 'Error al crear el pedido: ' + this._extractMessage(err);
                this.step         = STEP_SELECTION;
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    // ── Reset ──────────────────────────────────────────────────────────────────
    handleReset() {
        this.step         = STEP_SELECTION;
        this.cartLines    = [];
        this.searchTerm   = '';
        this.orderNumber  = '';
        this.errorMessage = '';
        this.allProducts  = this.allProducts.map(p => ({
            ...p,
            inputQuantity      : 1,
            stockWarning       : false,
            stockWarningMessage: ''
        }));
    }

    // ── Getters ────────────────────────────────────────────────────────────────
    get isStepSelection()    { return this.step === STEP_SELECTION; }
    get isStepConfirmation() { return this.step === STEP_CONFIRMATION; }
    get isStepSuccess()      { return this.step === STEP_SUCCESS; }

    get hasCartLines() { return this.cartLines.length > 0; }
    get cartCount()    { return this.cartLines.length; }

    get orderTotal() {
        return this.cartLines.reduce((sum, l) => sum + (l.lineTotal || 0), 0);
    }

    get todayFormatted() {
        return new Date().toLocaleDateString('es-ES', {
            day  : 'numeric',
            month: 'long',
            year : 'numeric'
        });
    }

    // ── Private helpers ────────────────────────────────────────────────────────
    _extractMessage(err) {
        if (err && err.body && err.body.message) return err.body.message;
        if (err && err.message)                  return err.message;
        return 'Error desconocido';
    }
}
