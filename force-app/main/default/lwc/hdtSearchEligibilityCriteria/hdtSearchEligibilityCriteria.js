import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getRecords from  '@salesforce/apex/HDT_LC_EligibilityCriteriaController.getEligibilityCriteriaRecord';
import cloneRecord from  '@salesforce/apex/HDT_LC_EligibilityCriteriaController.cloneEligibilityCriteriaRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

//const columns = [
//    { label: 'Definizione', fieldName: 'Definition__c' },
//    { label: 'M', fieldName: 'M__c', type: 'boolean'},
//    { label: 'V', fieldName: 'V__c', type: 'boolean' },
//    { label: 'Tipo tariffa', fieldName: 'FareType__c'},
//    { label: 'Gruppo info', fieldName: 'InfoGroup__c'},
//    { label: 'Valore numerico', fieldName: 'NumericValue__c'},
//    { label: 'Flag', fieldName: 'Flag__c', type: 'boolean'},
//    { label: 'Codice prezzo', fieldName: 'PriceCode__c'},
//    { label: 'Stringa testuale', fieldName: 'StringValue__c'},
//    { label: 'Nome Tecn.', fieldName: 'Operand__c'}   
//];

export default class HdtSearchEligibilityCriteria extends NavigationMixin(LightningElement) {
    data = [];
    //columns = columns;
    detailFields = ['Version__c', 'ProductCode__c'];
    filter;
    showTable = false;
    showTree = false;

    @api productid;
    @api template;
    @track result = {show: false, message: ''};
    @track error = {show: false, message: ''};

    @track item = {
        selectedId: '',
        name: '',
        code: ''
    }

    @track selid;
    @track selectRecordName;

    @track spinnerObj = {
        spinner: false,
        spincss: ''
    };

    @track searchObj = {
        offertName: '',
        version: '',
        offertCode: ''
    }

    @track modalObj = {
        isVisible: false,
        header: '',
        body: '',
        operation: ''
    }

    @track product = {
        productId: '',
        template: 'TEMPLATE',
        version: 'VERSION',
        rateCategory: 'CATEGORY',
        productCode: 'PRODUCT CODE'
    };

    title = 'Comuni eleggibili';

    connectedCallback(){
        this.filter = 'Product__r.Template__c=\''+ this.template +'\'';
    }

    searchClick(event){
        console.log('### searchClick ###');

        if(this.item.selectedId == undefined || this.item.selectedId == ''){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Fai attenzione',
                    message: 'Non hai selezionato nessuna offerta da cercare',
                    variant: 'warning'
                }),
            );
            return;
        }

        this.spinnerObj.spinner = true;
        this.spinnerObj.spincss = 'loadingdata slds-text-heading_small';
        this.handleSearch(this.item.selectedId);
    }

    handleSearch(recId){
        console.log('# handleSearch #');

        getRecords({recordId: recId})
            .then(result => {
                console.log('# call result #');

                if(result){
                    console.log('# success #');

                    if(result.eligibleForAllCities){
                        this.showTree = false;
                    } else {
                        this.data = result.treeItemList;
                        this.showTree = true;

                        if(this.data.length===0){
                            this.showTree = false;
                            this.result.show = true;
                            this.showTable = false;
                            this.result.message = 'Non è stata trovata nessuna configurazione';
                        }
                    }


                    this.spinnerObj.spinner = false;
                    this.showTable = true;

                } else {
                    this.error.show = true;
                    this.error.message = 'An error occurred!';
                    this.spinnerObj.spinner = false;
                }
               
            }).catch(error => {
                this.error.show = true;
                this.error.message = error.body.message;
                this.spinnerObj.spinner = false;
            });
    }

    cloneData(event){
        console.log('### cloneData ###');
        this.spinnerObj.spinner = true;
        this.spinnerObj.spincss = 'savingdata slds-text-heading_small';
        this.handleClone(this.item.selectedId);
        
        setTimeout(() => {

        }, 2000);
        
    }

    handleClone(recId){
        console.log('# handleClone #');
 
        cloneRecord({recIdToClone: recId, productId: this.productid})
            .then(result => {
                console.log('# call result #');

                if(result){
                    console.log('# success #');
                    console.log('# Offer cloned id -> ' + result);
                    this.goToRecord(result, 'EligibilityCriteria__c');
                } else {
                    this.error.show = true;
                    this.error.message = 'An error occurred!';
                }
                this.spinnerObj.spinner = false;
            }).catch(error => {
                this.error.show = true;
                this.error.message = error.body.message;
                this.spinnerObj.spinner = false;
            });
    }

    goToRecord(recId, objName){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recId,
                objectApiName: objName,
                actionName: 'view'
            }
        });
    }

    closeSearch(event){
        console.log('### closeSearch ###');
        this.searchObj.offertName = '';
        this.searchObj.version = '';
        this.searchObj.offertCode = '';
        const goback = new CustomEvent("goback", {
            detail:  {prodId: this.productid}
        });

        // Dispatches the event.
        this.dispatchEvent(goback);
    }

    handleSelection(event){
        console.log('# handleSelection #');
        console.log('# from lookup: ' + event.detail.selectedId + ' - ' + event.detail.name + ' - ' + event.detail.code);

        if(event.detail.selectedId === undefined || event.detail.name === undefined){
            this.showTable = false;
            return;
        }

        this.item.selectedId = event.detail.selectedId;
        this.item.name = event.detail.code;

        this.searchClick();     

    }

    back(event){
        this.error.show = false;
    }

    modalResponse(event){
        if(event.detail.decision === 'conf'){
            this[event.detail.operation](event);
        }
        this.modalObj.isVisible = false;
    }

    openConfirmation(event){
        try {
            switch (event.target.name) {
                case 'cloneData':

                    if(this.item.selectedId == undefined || this.item.selectedId == ''){
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Fai attenzione',
                                message: 'Non hai selezionato nessuna offerta da clonare',
                                variant: 'warning'
                            }),
                        );
                        return;
                    }

                    this.modalObj.header = 'Clonare la configurazione';
                    this.modalObj.body = 'Questa configurazione verrà clonata. Vuoi confermare?';
                    break;
                case 'closeSearch':
                    this.modalObj.header = 'Chiudi la ricerca';
                    this.modalObj.body = 'Vuoi procedere?';
            }

            this.modalObj.isVisible = true;
            this.modalObj.operation = event.target.name;

        } catch(e){
            console.error('# Name => ' + e.name );
            console.error('# Message => ' + e.message );
            console.error('# Stack => ' + e.stack );
        }
    }

}