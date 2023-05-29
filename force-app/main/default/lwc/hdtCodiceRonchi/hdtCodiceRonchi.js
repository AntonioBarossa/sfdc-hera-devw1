import { api } from 'lwc';
import HdtCodiceAteco from 'c/hdtCodiceAteco';
import saveAtecoRonchiCode from '@salesforce/apex/HDT_LC_CodiceAteco.saveAtecoRonchiCode';
import getAtecoMatrixList from '@salesforce/apex/HDT_LC_CodiceAteco.getAtecoMatrixList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class HdtCodiceRonchi extends HdtCodiceAteco {

    ronchiCode;
    ronchiSubcategory;
    ronchiDescription;
    @api order; 
    @api title;
    @api supplyCity;


    columns = [
        {label: 'Codice Comune', fieldName: 'AtecoCode__c', type: 'text'},
        {label: 'Comune', fieldName: 'City__c', type: 'text'},
        {label: 'Codice Istat/Ateco', fieldName: 'IstatCode__c', type: 'text'},
        {label: 'Categoria', fieldName: 'Category__c', type: 'text'},
        {label: 'Codice Ronchi', fieldName: 'RonchiCode__c', type: 'text'},
        {label: 'Sottocategoria Ronchi', fieldName: 'RonchiSubcategory__c', type: 'text'},
        {label: 'Descrizione Ronchi', fieldName: 'Type__c', type: 'text'}
    ];

    get options() {
        return [
            {label: 'Comune', value: 'CityRonchi'},
            {label: 'Codice Istat', value: 'IstatCodeAndCity'},
            {label: 'Codice Ronchi', value: 'RonchiCodeAndCity'}
        ];
    }

    getTableSelection(event){
        console.log('getTableSelection: ' + JSON.stringify(event.detail.selectedRows));
        let selectedRows = event.detail.selectedRows;
        this.selectedCode = selectedRows[0].AtecoCode__c;
        this.selectedIstatCode = selectedRows[0].IstatCode__c;
        this.ronchiCode = selectedRows[0].RonchiCode__c;
        this.ronchiSubcategory = selectedRows[0].RonchiSubcategory__c;
        this.ronchiDescription = selectedRows[0].Type__c;
        this.disabledSave = false;
    }

    searchPromise(){
        return getAtecoMatrixList({filterType: this.filterType, filterValue: this.searchInputValue, supplyCity : this.supplyCity });
    }

    handleSaveAtecoCode(){
        this.loading = true;
        saveAtecoRonchiCode({order: this.order, params: {atecoCode: this.selectedCode, istatCode: this.selectedIstatCode, ronchiCode: this.ronchiCode, ronchiSubcategory: this.ronchiSubcategory, ronchiDescription: this.ronchiDescription }}).then(data =>{
            this.loading = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Successo',
                message: 'Codice Ateco salvato con successo',
                variant: 'success',
            }));

            console.log('###Selected Code >>> ' + this.selectedCode)

            this.dispatchEvent(new CustomEvent('update_cod_ateco_details',{ detail: {
                isRonchi:true,
                atecoCode: this.selectedCode, 
                ronchiCode: this.ronchiCode, 
                ronchiSubcategory: this.ronchiSubcategory,
                istatCode : this.selectedIstatCode
            }}));

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
}