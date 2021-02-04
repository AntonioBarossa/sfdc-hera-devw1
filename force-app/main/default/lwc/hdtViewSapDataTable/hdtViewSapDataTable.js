import { LightningElement, api } from 'lwc';
import callMulesoft from '@salesforce/apexContinuation/HDT_LC_ViewSapDataTableCtrl.startRequest';
import getTableConfig from '@salesforce/apex/HDT_LC_ViewSapDataTableCtrl.getTableConfig';

export default class HdtViewSapDataTable extends LightningElement {
    data = [];
    columns;
    tableTitle;
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
            this.tableTitle = result.tableTitle;
            this.columns = result.columns;
        }).catch(error => {
            console.log('# error -> ' + error);
        });
    
    }

    backendCall(){
        console.log('# Get data from Mulesoft #');
    
        callMulesoft({recordId: this.recordId, type: this.type})

        .then(result => {
            console.log('# Mulesoft result #');

            var obj = JSON.parse(result);

            console.log('# success: ' + obj.status);
            this.data = obj.data;
            
        }).catch(error => {
            console.log('# error -> ' + error);
        });
    
    }

}