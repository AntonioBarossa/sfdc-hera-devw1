import { LightningElement,api,track } from 'lwc';
//import getConfiguration from '@salesforce/apex/HDT_LC_GenericRecordSelection.getConfiguration';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationFinishEvent,FlowNavigationBackEvent  } from 'lightning/flowSupport';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class HdtContactSelectionFlow extends LightningElement {
    @api searchLabel;
    @api searchVariant;
    @api searchPlaceholder;
    @api results;
    @api accountId;
    @api selectionType;
    @api showDraftButton;
    @api showBackButton;
    @api showCancelButton;
    @api nextLabel;
    @api saveDraft;
    @api cancelCase;
    @api showAdministrators;
    @api showSolContacts;
    @api availableActions = [];
    
    @track queryParams;
    @track maxRow;
    @track showSelector;
    @track columns;

/*     getConfiguration(){
        getConfiguration({
            search: this.selectionType
            })
            .then(result => {
                var wiredResponse = JSON.parse(result);
                if(Object.keys(wiredResponse).length > 0){
                    console.log(wiredResponse[0]);
                    var accountFilter = 'AccountId =\''+this.accountId+'\''; // AccountId from AccountContactRelation junction object
                    var filters;
                    if(wiredResponse[0].Where_Conditions__c != null && wiredResponse[0].Where_Conditions__c != "" && wiredResponse[0].Where_Conditions__c != "undefined"){
                        filters = accountFilter + ' AND ' + wiredResponse[0].Where_Conditions__c;
                    }else{
                        filters = accountFilter;
                    }
                    var params = '{"filters": "'+ filters + '", "objectName":"'+wiredResponse[0].sObject__c +'", "fields":"'+wiredResponse[0].Fields__c + '", "queryType":"'+wiredResponse[0].Query_Type__c + '", "distinct":"'+ wiredResponse[0].Distinct__c+'"}';
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
    } */

    connectedCallback(){
        //this.showSelector = false;
        //this.getConfiguration();
        this.showSelector = true;
        this.maxRow = 1;
    }

    handleRecordSelection(event){
        this.results = event.detail.selectedRows[0].Id;
    }
   
    handleNavigation(event){

        const action = event.detail;
        console.log('handleNavigation ' + action);

        if(action === 'next' || action === 'draft' || action === 'save'){
            this.saveDraft = action === 'draft'; 
            if(this.results != null && this.results != "" && this.results != "undefined"){
                console.log('results: ' + this.results);
                if(this.availableActions.find(action => action === 'NEXT')){
                    const navigateNextEvent = new FlowNavigationNextEvent();
                    this.dispatchEvent(navigateNextEvent);
                } else {
                    const navigateFinish = new FlowNavigationFinishEvent();
                    this.dispatchEvent(navigateFinish);
                }
            }else{
                this.showMessage('Errore','Attenzione! Seleziona un Contatto prima di andare avanti','error');  
            }
        } else if(action === 'previous'){
            const navigateBackEvent = new FlowNavigationBackEvent();
            this.dispatchEvent(navigateBackEvent);
        } else if(action === 'cancel'){
            this.cancelCase = true;
            if(this.availableActions.find(action => action === 'NEXT')){
                const navigateNextEvent = new FlowNavigationNextEvent();
                this.dispatchEvent(navigateNextEvent);
            } else {
                const navigateFinish = new FlowNavigationFinishEvent();
                this.dispatchEvent(navigateFinish);
            }
        }
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