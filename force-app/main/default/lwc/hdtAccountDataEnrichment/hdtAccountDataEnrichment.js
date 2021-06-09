import { LightningElement, api } from 'lwc';
import callSap from '@salesforce/apexContinuation/HDT_LC_AccountDataEnrichment.startRequest';
import getTableConfig from '@salesforce/apex/HDT_LC_AccountDataEnrichment.getTableConfig';

export default class HdtAccountDataEnrichment extends LightningElement {
    data = [];
    columns;
    tableTitle;
    iconName;
    height1;

    showSecondTable;
    data2 = [];
    columns2;
    tableTitle2;
    iconName2;
    height2;

    showError = false;
    showErrorMessage = '';
    showSpinner = true;
    
    @api recordId;
    @api type;

    get showSocialBonusButton(){
        return this.type === 'socialBonus';
    }

    connectedCallback(){
        console.log('# type: ' + this.type);
        this.getConfiguration();
        this.backendCall();
    }

    getConfiguration(){
        console.log('# getConfiguration #');
    
        getTableConfig({recordId: this.recordId, type: this.type})

        .then(result => {

            console.log('# getTableConfig #');
 
            if(this.type != 'cmor'){
                this.tableTitle = result.tables[0].tableTitle;
                this.iconName = result.tables[0].iconName;
                this.columns = result.tables[0].columns;
                this.height1 = 'singleTable';
            } else {
                this.showSecondTable = true;
                this.tableTitle = result.tables[0].tableTitle;
                this.iconName = result.tables[0].iconName;
                this.columns = result.tables[0].columns;
                this.height1 = 'topTable';

                this.tableTitle2 = result.tables[1].tableTitle;
                this.iconName2 = result.tables[1].iconName;
                this.columns2 = result.tables[1].columns;
                this.height2 = 'bottomTable';
            }


        }).catch(error => {
            console.log('# error -> ' + error);
            this.showError = true;
            //{"status":500,"body":{"message":"No Customer Code!"},"headers":{}}
            this.showErrorMessage = error.body.message;
            this.showSpinner = false;
        });
    
    }

    backendCall(){
        console.log('# Get data from SAP #');
    
        callSap({recordId: this.recordId, type: this.type}).then(result => {
            console.log('# SAP result #');
            var obj = JSON.parse(result);
            console.log('# success: ' + obj.status);

            if(obj.status==='failed'){
                console.log('# SAP result failed #');
                this.showError = true;
                console.log('>>> ' + obj.errorDetails[0].code + ' - ' + obj.errorDetails[0].message);
                this.showErrorMessage = obj.errorDetails[0].message;
                this.showSpinner = false;            
            } else {
                if(this.type != 'cmor'){
                    this.data = obj.data.posizioni;
                } else {
                    this.showSecondTable = true;
                    this.data = obj.data.venditoreEntrante;
                    this.data2 = obj.data.venditoreUscente;
                }
            }

            this.showSpinner = false;
            
        }).catch(error => {
            //var obj = JSON.parse(error.body.message);
            this.showError = true;
            //var s = '';
            //obj.errorDetails.forEach(element => {
            //    s += element.code + ': ' + element.message;
            //});
            this.showErrorMessage = error.body.message;
            this.showSpinner = false;
        });
    
    }

    openKnowledgeArticle(){
        console.log('apertura articolo knowledge con importi bonus sociale');
    }

}