import { LightningElement,api,track } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationFinishEvent,FlowNavigationBackEvent  } from 'lightning/flowSupport';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getData from '@salesforce/apex/HDT_LC_AbiCodeSelector.getData';
const columns = [
    { label: 'Nome Banca', fieldName: 'BankName__c'},
    { label: 'Abi', fieldName: 'IbanABI__c' }
];  
export default class HdtAbiCodeSelector extends LightningElement {
    //buttons
    @api availableActions = [];
    @api saveButton;
    @api disabledSaveButton = false;
    @api cancelButton;
    @api previousButton;
    @api draftButton;
    @api labelSaveButton;
    @api labelDraftButton;
    @api labelPreviousButton;
    @api labelCancelButton;
    //Flow Outputs
    @api draft = false;
    @api cancel = false;
    @api abi='';
    data = [];
    columns = columns;
    isLoading = true;
    handlePrevious(){
        const navigateBackEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(navigateBackEvent);
    }
    connectedCallback(){
        this.isLoading = true;
        getData({searchString:''})
            .then(data => {
                console.log('Data -> ' + JSON.stringify(data) + ' ' + data);
                if(!data){
                    console.log('Inside No Record Condition')
                    this.isLoading = false;
                    const event = new ShowToastEvent({
                                title: 'Nessun Record',
                                message:
                                    'Modifica i parametri di ricerca.',
                            });
                            this.dispatchEvent(event);
                } else {
                    this.data = data;
                    this.isLoading = false;
                }
            })
            .catch(error => {
                console.log('Error In Retrievieng data -> ' + JSON.stringify(error));
            })
    }
    handleCustomSearch(event){
        const isEnterKey = event.keyCode === 13;
        if (isEnterKey) {
            let searchText = event.target.value;
            if(searchText.length<3 && searchText.length>0){
                const event = new ShowToastEvent({
                    title: 'Attenzione',
                    message:
                        'Inserisci almeno 3 caratteri oppure svuota il campo di ricerca e premi invio per ottenere tutte le banche',
                });
                this.dispatchEvent(event);
            }else{
                this.isLoading = true;
                getData({searchString:searchText})
                .then(data => {
                    console.log('Data -> ' + JSON.stringify(data) + ' ' + data);
                    if(!data){
                        console.log('Inside No Record Condition');
                        this.isLoading = false;
                        const event = new ShowToastEvent({
                                    title: 'Nessun Record',
                                    message:
                                        'Modifica i parametri di ricerca.',
                                });
                                this.dispatchEvent(event);
                    } else {
                        this.data = data;
                        this.isLoading = false;
                    }
                })
                .catch(error => {
                    console.log('Error In Retrievieng data -> ' + JSON.stringify(error));
                })
            }
        }
    }
    handleNext(event) {
        let dataTable = this.template.querySelector('lightning-datatable');
        let record = dataTable.getSelectedRows();
        if(record.length === 0){
            const event = new ShowToastEvent({
                title: 'Attenzione',
                message:
                    'Seleziona un ABI',
            });
            this.dispatchEvent(event);
        }else{
            console.log(record[0]);
            this.abi = record[0].IbanABI__c;
            if(event.currentTarget.name === 'draft'){
                this.draft = true;
                this.cancel = false;
            } else if(event.currentTarget.name === 'cancel'){
                this.cancel = true;
                this.draft = false;
            }
            console.log('checks done');
            if(this.availableActions.find(action => action === 'NEXT')){
                console.log('Inside Next Event');    
                const navigateNextEvent = new FlowNavigationNextEvent();
                this.dispatchEvent(navigateNextEvent);
            } else {
                console.log('Inside Finish Event');
                const navigateFinish = new FlowNavigationFinishEvent();
                this.dispatchEvent(navigateFinish);
            }
        }
    }
}