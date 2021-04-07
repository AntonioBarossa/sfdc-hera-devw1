import { LightningElement,api,track } from 'lwc';
import getConfiguration from '@salesforce/apex/HDT_LC_GenericRecordSelection.getConfiguration';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationFinishEvent,FlowNavigationBackEvent  } from 'lightning/flowSupport';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class HdtContractProfileSelectionFlow extends LightningElement {
    @api searchLabel;
    @api searchVariant;
    @api searchPlaceholder;
    @api results;
    @api accountId;
    @api selectionType;
    @api concatenate;
    
    @track queryParams;
    @track maxRow;
    @track showSelector;
    @track columns;

    getConfiguration(){
        getConfiguration({
            search: this.selectionType
            })
            .then(result => {
                var wiredResponse = JSON.parse(result);
                if(Object.keys(wiredResponse).length > 0){
                    console.log(wiredResponse[0]);
                    var accountFilter = 'AccountId =\''+this.accountId+'\'';
                    var filters;
                    if(wiredResponse[0].Where_Conditions__c != null && wiredResponse[0].Where_Conditions__c != "" && wiredResponse[0].Where_Conditions__c != "undefined"){
                        filters = accountFilter + ' AND ' + wiredResponse[0].Where_Conditions__c;
                    }else{
                        filters = accountFilter;
                    }
                    var params = '{"filters": "'+ filters +'","soslSearchTerm":"'+wiredResponse[0].Default_Search_Key__c +'", "objectName":"'+wiredResponse[0].sObject__c +'", "distinct":"'+wiredResponse[0].Distinct__c +'", "queryType":"'+wiredResponse[0].Query_Type__c +'", "fields":"'+wiredResponse[0].Fields__c+'"}';
                    this.queryParams = params;
                    this.maxRow = wiredResponse[0].Max_Rows__c;
                    this.columns = wiredResponse[0].Columns__c;
                    this.showSelector = true;
                }else{
                    console.log('No record');
                }            
            })
            .catch(error => {
                console.log('error ' + JSON.stringify(error));
            });
    }

    connectedCallback(){
        this.showSelector = false;
        this.getConfiguration();
    }

    handleRecordSelection(event){
        if (this.concatenate === true) {
            console.log('Concatenazione di tutti i codici contratto selezionati...');
            this.results = '';
            for (var selectedRow in event.detail.selectedRows) {
                this.results += event.detail.selectedRows[0].SAPContractCode__c + '; ';
            }
        } else {
            this.results = event.detail.selectedRows[0].Id;
        }
    }
   
    handleNext(event){
        if(this.results != null && this.results != "" && this.results != "undefined"){
            console.log('results: ' + this.results);
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }else{
            this.showMessage('Errore','Attenzione! Seleziona un Contratto prima di andare avanti','error');  

        }

    }
    handleCancell(event){
        
    }
    showMessage(title,message,variant){
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            }),
        );
    }
}