import { LightningElement, track, api } from 'lwc';
import HdtCodiceRonchi from 'c/hdtCodiceRonchi';
import getAtecoMatrixList from '@salesforce/apex/HDT_LC_CodiceAteco.getAtecoMatrixList';
import getAtecoMatrixListIstatRonchi from '@salesforce/apex/HDT_LC_CodiceAteco.getAtecoMatrixListIstatRonchi';
import saveIstatRonchiCase from '@salesforce/apex/HDT_LC_CodiceAteco.saveIstatRonchiCase';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class HdtIstatRonchiForFlow extends HdtCodiceRonchi {

    ronchiCode;
    ronchiSubcategory;
    ronchiDescription;
    @track buttonLabel;
    @api caseRecord;
    @api title;
    @api supplyCity;

    columnsData = {
        Istat:[
            {label: 'Codice Comune', fieldName: 'AtecoCode__c', type: 'text'},
            {label: 'Comune', fieldName: 'City__c', type: 'text'},
            {label: 'Codice Istat', fieldName: 'IstatCode__c', type: 'text'},
            {label: 'Categoria', fieldName: 'Category__c', type: 'text'}
        ],
        Ronchi:[
            {label: 'Codice Comune', fieldName: 'AtecoCode__c', type: 'text'},
            {label: 'Comune', fieldName: 'City__c', type: 'text'},
            {label: 'Codice Ronchi', fieldName: 'RonchiCode__c', type: 'text'},
            {label: 'Sottocategoria Ronchi', fieldName: 'RonchiSubcategory__c', type: 'text'},
            {label: 'Descrizione Codice Ronchi', fieldName: 'Type__c', type: 'text'}
        ]
    }

    get options() {
        switch (this.title.toUpperCase()) {
            case 'ISTAT':
                return [
                    {label: 'Comune', value: 'City__c'},
                    {label: 'Codice Istat', value: 'IstatCode__c'}
                ];
                break;
            case 'RONCHI':
                return [
                    {label: 'Comune', value: 'CityRonchi'},
                    {label: 'Codice Istat', value: 'IstatCodeAndCity'},
                    {label: 'Codice Ronchi', value: 'RonchiCodeAndCity'}
                ];
                break;
            default:
                return [];
        }
    }

    constructor(){
        super();
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

    searchPromise(){
        switch (this.title.toUpperCase()) {
            case 'ISTAT':
                return getAtecoMatrixListIstatRonchi({filterType: this.filterType, filterValue: this.searchInputValue, whichCode : this.title });
                break;
            case 'RONCHI':
                return getAtecoMatrixList({filterType: this.filterType, filterValue: this.searchInputValue, supplyCity : this.supplyCity });
                break;
            default:
                return [];
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