import { LightningElement,api,track,wire } from 'lwc';
import getConfiguration from '@salesforce/apex/HDT_LC_BillingProfileSelection.getConfiguration';
import createBpInSap from '@salesforce/apex/HDT_LC_BillingProfileSelection.handleNewBillingProfile';
import { getRecord } from 'lightning/uiRecordApi';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationFinishEvent,FlowNavigationBackEvent  } from 'lightning/flowSupport';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const FIELDS = ['Case.Id',
				'Case.Commodity__c'];
export default class HdtBillingProfileSelectionFlow extends LightningElement {
    @api searchLabel;
    @api searchVariant;
    @api searchPlaceholder;
    @api results;
    @api codiceCa;
    @api accountId;
    @api selectionType;
    @api cancelCase = false;
    //@frpanico 13/09 added variable to skip required selection (process "BP/CA errata categoria")
    @api nonReqSelection = false;
    @api enableNew = false;
    @track commodity;
    @api caseId;
    @track queryParams;
    @track maxRow;
    @track showSelector;
    @track columns;
    @track showModal = false;

    @wire(getRecord, { recordId: '$caseId', fields: FIELDS })
        wiredCase({ error, data }) {
            if (error) {
                let message = 'Unknown error';
                if (Array.isArray(error.body)) {
                    message = error.body.map(e => e.message).join(', ');
                } else if (typeof error.body.message === 'string') {
                    message = error.body.message;
                }
                console.log('data error ' +message);
            } else if (data) {
                console.log('data loaded');
                this.commodity = data.fields.Commodity__c.value;
            }
        }
    getConfiguration(){
        getConfiguration({
            search: this.selectionType
            })
            .then(result => {
                var wiredResponse = JSON.parse(result);
                if(Object.keys(wiredResponse).length > 0){
                    console.log(wiredResponse[0]);
                    var accountFilter = 'Account__c =\''+this.accountId+'\'';
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
        this.results = event.detail.selectedRows[0].Id;
    }
    handleNewBilling(event){
        console.log('event received' + event.detail);
        this.results = event.detail;
        if(this.commodity && (this.commodity==='Acqua' || this.commodity === 'Teleriscaldamento')){
            createBpInSap({
                billingId:this.results,
                accountId:this.accountId
            }).then(result=>{
                var response = JSON.parse(result);
                if(response.codiceContatto && response.codiceContatto != null && response.codiceContatto != 'undefined'){
                    this.codiceCa = response.codiceContatto;
                    this.handleNext();
                }else{
                    this.showMessage('Errore',response.commenti,'error');
                }
            }).catch(error => {
                console.log('error ' + JSON.stringify(error));
            });
        }else{
            this.handleNext();
        }
        //this.handleShowModal();
    }

    handleShowModal(){
        this.showModal = !this.showModal;
    }
   
    handleNext(event){
        if((this.results != null && this.results != "" && this.results != "undefined") || this.nonReqSelection === true){
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }else{
            this.showMessage('Errore','Attenzione! Seleziona un Billing Profile prima di andare avanti','error');  

        }

    }
    handleCancell(event){
        
        this.cancelCase = true;
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);

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