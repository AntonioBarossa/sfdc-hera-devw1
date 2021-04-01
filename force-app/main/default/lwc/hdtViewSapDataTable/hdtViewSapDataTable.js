import { LightningElement, api } from 'lwc';
import callSap from '@salesforce/apexContinuation/HDT_LC_ViewSapDataTableCtrl.startRequest';
import getTableConfig from '@salesforce/apex/HDT_LC_ViewSapDataTableCtrl.getTableConfig';

export default class HdtViewSapDataTable extends LightningElement {
    data = [];
    columns;
    tableTitle;
    iconName;

    showSecondTable;
    data2 = [];
    columns2;
    tableTitle2;
    iconName2;

    showError = false;
    showErrorMessage = '';
    showSpinner = true;
    
    @api recordId;
    @api type;

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
            } else {
                this.showSecondTable = true;
                this.tableTitle = result.tables[0].tableTitle;
                this.iconName = result.tables[0].iconName;
                this.columns = result.tables[0].columns;

                this.tableTitle2 = result.tables[1].tableTitle;
                this.iconName2 = result.tables[1].iconName;
                this.columns2 = result.tables[1].columns;
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

            if(this.type != 'cmor'){
                this.data = obj.data;
            } else {
                this.showSecondTable = true;
                this.data = obj.dataSellIn;
                this.data2 = obj.dataSellOut;
            }

            this.showSpinner = false;
            
        }).catch(error => {
            console.error('# error -> ' + error);
            this.showError = true;
            this.showErrorMessage = error.body.message;
            this.showSpinner = false;
        });
    
    }

}