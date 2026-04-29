import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import searchByName from '@salesforce/apex/RawMaterialSearchController.searchByName';

export default class RawMaterialForm extends NavigationMixin(LightningElement) {
    @track name = '';
    @track suggestions = [];
    @track showDropdown = false;
    @track nameError = '';

    _searchTimeout;

    disconnectedCallback() {
        clearTimeout(this._searchTimeout);
    }

    handleNameInput(event) {
        this.name = event.target.value;
        this.nameError = '';
        clearTimeout(this._searchTimeout);

        if (this.name.length < 4) {
            this.suggestions = [];
            this.showDropdown = false;
            return;
        }

        this._searchTimeout = setTimeout(() => {
            searchByName({ searchTerm: this.name })
                .then(data => {
                    this.suggestions = data;
                    this.showDropdown = data.length > 0;
                })
                .catch(() => {
                    this.showDropdown = false;
                });
        }, 300);
    }

    handleBlur() {
        setTimeout(() => {
            this.showDropdown = false;
        }, 200);
    }

    handleSelectExisting(event) {
        const recordId = event.currentTarget.dataset.id;
        this.dispatchEvent(new CloseActionScreenEvent());
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            }
        });
    }

    handleSubmit(event) {
        event.preventDefault();
        if (!this.name.trim()) {
            this.nameError = 'El nombre es obligatorio.';
            return;
        }
        const fields = event.detail.fields;
        fields.Name = this.name;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleSuccess() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}
