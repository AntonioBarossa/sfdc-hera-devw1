import {LightningElement, track} from 'lwc';
import getServicePointsByName from '@salesforce/apex/HDT_LC_AdvancedSearch.getServicePointsByName';
import {ShowToastEvent} from 'lightning/platformShowToastEvent'

export default class HdtAdvancedSearch extends LightningElement {

    @track
    filterInputWord = null;
    openmodel = false
    value = 'false';
    submitButtonStatus = true;
    searchInputValue = null;
    tableData = [];
    tableColumns = [];
    isLoaded = false;
    columns = [];
    originalData=null;

    connectedCallback() {}

    comboboxHandleChange(event) {
        this.value = event.detail.value;
    }

    handleFilterDataTable(event) {
        let val = event.target.value;
        this.tableData = this.originalData.filter(row => {
            if (row.ServicePointCode__c.startsWith(val)){
                return row;
            }
        });
    }

    get options() {
        return [
            {label: 'Select..', value: 'false'},
            {label: 'YES', value: 'true'},
            {label: 'NO', value: 'false'},
        ]
    }

    handleSearchInputKeyChange(event) {
        this.searchInputValue = event.target.value;
        if (this.searchInputValue.length > 4) {
            this.submitButtonStatus = false;
        } else {
            this.submitButtonStatus = true;
        }
    }

    closeModal() {
        this.openmodel = false
    }

    searchAction(event) {
        this.submitButtonStatus = true;
        if (event.target.value.length>4){
            this.submitButtonStatus = false;
            this.searchInputValue = event.target.value;
        }
    }

    formatTableHeaderColumns(rowData) {
        let columns = [];
        this.tableColumns=[];
        rowData.forEach(row => {
            let keys = Object.keys(row);
            columns = columns.concat(keys);
        });
        let columnsUniq = [...new Set(columns)];
        columnsUniq.splice(columnsUniq.indexOf('Id'), 1);
        columnsUniq.forEach(field => this.tableColumns.push({label: field, fieldName: field}));
    }

    submitSearch(event) {
        event.preventDefault();
        getServicePointsByName({code: this.searchInputValue}).then(data => {
            if (data.length > 0) {
                this.originalData = JSON.parse(JSON.stringify(data));
                this.formatTableHeaderColumns(data);
                this.submitButtonStatus = true;
                this.openmodel = true;
                this.tableData = data;
                this.isLoaded = true;
            } else {
                const event = ShowToastEvent({
                    title: 'Table Data',
                    message: 'No records was found',
                    variant: 'info'
                });
                this.dispatchEvent(event);
                this.tableData = data;
            }
        }).catch(error => {
            let option = {
                title: 'JavascriptError',
                message: error,
                variant: 'error'
            };
            if ('body' in error && 'message' in error.body) {
                option.message = error.body.message
            }
            const event = ShowToastEvent(option);
            this.dispatchEvent(event);
        });

    }
}