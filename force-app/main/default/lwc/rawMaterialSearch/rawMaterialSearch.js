import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import searchByName from '@salesforce/apex/RawMaterialSearchController.searchByName';

export default class RawMaterialSearch extends NavigationMixin(LightningElement) {
    @track searchTerm = '';
    @track results = [];
    @track isLoading = false;
    @track hasSearched = false;

    _searchTimeout;

    get hasResults() {
        return this.hasSearched && this.results.length > 0;
    }

    get noResults() {
        return this.hasSearched && !this.isLoading && this.results.length === 0 && this.searchTerm.length >= 2;
    }

    disconnectedCallback() {
        clearTimeout(this._searchTimeout);
    }

    handleSearch(event) {
        this.searchTerm = event.target.value;
        clearTimeout(this._searchTimeout);

        if (this.searchTerm.length < 2) {
            this.results = [];
            this.hasSearched = false;
            return;
        }

        this.isLoading = true;
        this._searchTimeout = setTimeout(() => {
            searchByName({ searchTerm: this.searchTerm })
                .then(data => {
                    this.results = data;
                    this.hasSearched = true;
                    this.isLoading = false;
                })
                .catch(() => {
                    this.isLoading = false;
                });
        }, 300);
    }

    handleNavigate(event) {
        event.preventDefault();
        const recordId = event.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            }
        });
    }
}