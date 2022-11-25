import { LightningElement, track, api } from 'lwc';
import HdtCodiceAteco from 'c/hdtCodiceAteco';
import getAtecoMatrixList from '@salesforce/apex/HDT_LC_CodiceAteco.getAtecoMatrixList';
import saveIstatRonchiCase from '@salesforce/apex/HDT_LC_CodiceAteco.saveIstatRonchiCase';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class HdtIstatRonchiForFlow extends HdtCodiceAteco {

    ronchiCode;
    ronchiSubcategory;
    ronchiDescription;
    @track buttonLabel;
    @api caseRecord;
    @api title;
    @track columns;

    columnsData = {
        Istat:[
            {label: 'Comune', fieldName: 'City__c', type: 'text'},
            {label: 'Codice Ateco', fieldName: 'AtecoCode__c', type: 'text'},
            {label: 'Codice Istat', fieldName: 'IstatCode__c', type: 'text'}
        ],
        Ronchi:[
            {label: 'Comune', fieldName: 'City__c', type: 'text'},
            {label: 'Codice Ronchi', fieldName: 'RonchiCode__c', type: 'text'},
            {label: 'Sottocategoria Ronchi', fieldName: 'RonchiSubcategory__c', type: 'text'},
            {label: 'Descrizione Codice Ronchi', fieldName: 'RonchiCodeDescription__c', type: 'text'}
        ]
    }

    constructor(){
        super();
    }

    getTableSelection(event){
        console.log('getTableSelection: ' + JSON.stringify(event.detail.selectedRows));
        let selectedRows = event.detail.selectedRows;
        this.selectedCode = selectedRows[0].AtecoCode__c;
        this.selectedIstatCode = selectedRows[0].IstatCode__c;
        this.ronchiCode = selectedRows[0].RonchiCode__c;
        this.ronchiSubcategory = selectedRows[0].RonchiSubcategory__c;
        this.ronchiDescription = selectedRows[0].RonchiDescription__c;
        this.disabledSave = false;
    }

    submitSearch(){
        this.loading = true;
        console.log('******:' + JSON.stringify(this.searchInputValue));
        getAtecoMatrixList({filterType: this.filterType, filterValue: this.searchInputValue, whichCode: this.title}).then(data =>{
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

    getParams(){
        if(this.title == 'Istat'){
            return {
                atecoCode: this.selectedCode, 
                istatCode: this.selectedIstatCode, 
            };
        }else if(this.title == 'Ronchi'){
            return {
                ronchiCode: this.ronchiCode, 
                ronchiSubcategory: this.ronchiSubcategory, 
                ronchiDescription: this.ronchiDescription       
            };
        }else{
            return {};
        }
    }

    handleSaveAtecoCode(){
        this.loading = true;
        saveIstatRonchiCase({caseRecord: this.caseRecord, whichCode: this.title, params: this.getParams()}).then(data =>{
            this.loading = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Successo',
                message: 'Codice '+this.title+' salvato con successo',
                variant: 'success',
            }));

            getRecordNotifyChange([{recordId:  this.caseRecord.Id}]);

            console.log('###Selected Code >>> ' + this.selectedCode)

            this.dispatchEvent(new CustomEvent('update_cod_ateco_details',{ detail: {
                atecoCode: this.selectedCode, 
                ronchiCode: this.ronchiCode,
                ronchiSubcategory: this.ronchiSubcategory,
                ronchiDescription: this.ronchiDescription
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

    connectedCallback(){
        this.columns = this.columnsData[this.title];
        this.buttonLabel = 'Cerca codice '+this.title;
    }

}