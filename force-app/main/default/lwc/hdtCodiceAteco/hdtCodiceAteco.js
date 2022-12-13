import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAtecoMatrixList from '@salesforce/apex/HDT_LC_CodiceAteco.getAtecoMatrixList';
import saveAtecoCode from '@salesforce/apex/HDT_LC_CodiceAteco.saveAtecoCode';

export default class HdtCodiceAteco extends LightningElement {
    @api order; 
    @api title;
    @track buttonLabel;
    visible = false;
    filterType = '';
    disabledInput = true;
    submitButtonStatus = true;
    searchInputValue = null;
    loading = false;
    isTableVisible = false;
    showEmptyMessage = false;
    totalPages = 0;
    @track pages = [];
    currentPage = 0;
    @track tableData = [];
    columns = [
        {label: 'Codice Ateco', fieldName: 'AtecoCode__c', type: 'text'},
        {label: 'Comune', fieldName: 'City__c', type: 'text'},
        {label: 'Codice Istat', fieldName: 'IstatCode__c', type: 'text'},
        {label: 'Categoria', fieldName: 'Category__c', type: 'text'}
    ];
    selectedCode = '';
    disabledSave = true;
    selectedIstatCode = '';

    //handle modal open event
    handleOpenModal(){
        this.visible = true;
        this.filterType = '';
        this.disabledInput = true;
        this.submitButtonStatus = true;
        this.searchInputValue = null;
        this.isTableVisible = false;
        this.showEmptyMessage = false;
        this.selectedCode = '';
        this.selectedIstatCode = '';
        this.disabledSave = true;
    }

    //handle modal close event
    handleCloseModal() {
        this.visible = false;

    }

    get options() {
        return [
            {label: 'Comune', value: 'City__c'},
            {label: 'Codice Istat', value: 'IstatCode__c'}
        ];
    }

    handleSelection(event) {
        let selected = event.target.value;
        console.log('hdtCodiceAteco - handleSelection: ' + selected);
        this.disabledInput = false;
        this.filterType = selected;
    }

    /**
     * validate search input length
     */
     handleSearchInputKeyChange(event) {
        let searchInputValue = event.target.value;
        if (searchInputValue.length > 0) {
            this.submitButtonStatus = false;
        } else {
            this.submitButtonStatus = true;

        }
    }

    /**
     * get input value and also validate input value
     */
     searchAction(event) {
        this.submitButtonStatus = true;

        console.log('hdtCodiceAteco - searchAction: '+ event.target.value);

        if (event.target.value.length > 0) {
            this.submitButtonStatus = false;
            this.searchInputValue = event.target.value;
        }
    }

    submitSearch(){
        this.loading = true;
        console.log('******:' + JSON.stringify(this.searchInputValue));
        getAtecoMatrixList({filterType: this.filterType, filterValue: this.searchInputValue}).then(data =>{
            this.loading = false;
            this.isTableVisible = true;

            console.log('getAtecoMatrixList: ' + JSON.stringify(data));

            if(data.length > 0){
                this.showEmptyMessage = false;
                this.createTable(data);
            } else { 
                this.showEmptyMessage = true;
            }

        }).catch(error => {
            this.loading = false;

            let errorMessage = '';

            if (error.body.message !== undefined) {
                errorMessage = error.body.message;
            } else if(error.message !== undefined){
                errorMessage = error.message;
            } else if(error.body.pageErrors !== undefined){
                errorMessage = error.body.pageErrors[0].message;
            }

            console.log('Error: ', errorMessage);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: errorMessage,
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    //Pagination start
    createTable(data) {
        let i, j, temporary, chunk = 4;
        this.pages = [];
        for (i = 0, j = data.length; i < j; i += chunk) {
            temporary = data.slice(i, i + chunk);
            this.pages.push(temporary);
        }
        this.totalPages = this.pages.length;
        this.reLoadTable();
    }

    reLoadTable() {
        console.log('this.pages: ' + JSON.stringify(this.pages));
        this.tableData = this.pages[this.currentPage];
    }

    get showPaginationButtons(){
        return this.totalPages > 1;
    }

    get getCurrentPage() {
        if (this.totalPages===0){
            return 0;   
        } else {
            return this.currentPage + 1;
        }
    }

    nextPage() {
        if (this.currentPage < this.totalPages - 1) {
            this.currentPage++;
        }
        this.reLoadTable();
    }

    previousPage() {
        if (this.currentPage > 0){
            this.currentPage--;
        }
        this.reLoadTable();
    }
    //Pagination end

    getTableSelection(event){
        console.log('getTableSelection: ' + JSON.stringify(event.detail.selectedRows));
        let selectedRows = event.detail.selectedRows;
        this.selectedCode = selectedRows[0].AtecoCode__c;
        this.selectedIstatCode = selectedRows[0].IstatCode__c;
        this.disabledSave = false;
    }

    handleSaveAtecoCode(){
        this.loading = true;
        saveAtecoCode({order: this.order, params: {atecoCode: this.selectedCode, istatCode: this.selectedIstatCode}}).then(data =>{
            this.loading = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Successo',
                message: 'Codice Ateco salvato con successo',
                variant: 'success',
            }));

            console.log('###Selected Code >>> ' + this.selectedCode)

            this.dispatchEvent(new CustomEvent('update_cod_ateco_details',{
                detail: this.selectedCode
            }));

            this.handleCloseModal();

        }).catch(error => {
            this.loading = false;

            let errorMessage = '';

            if (error.body.message !== undefined) {
                errorMessage = error.body.message;
            } else if(error.message !== undefined){
                errorMessage = error.message;
            } else if(error.body.pageErrors !== undefined){
                errorMessage = error.body.pageErrors[0].message;
            }

            console.log('Error: ', errorMessage);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: errorMessage,
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    connectedCallback(){
        this.buttonLabel = 'Cerca codice ateco';
    }
}