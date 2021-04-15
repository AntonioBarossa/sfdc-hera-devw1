import { LightningElement,track,api,wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import PHONE_FIELD from '@salesforce/schema/Case.PhoneNumber__c';
import EMAIL_FIELD from '@salesforce/schema/Case.Email__c';
import ADDRESS_FIELD from '@salesforce/schema/Case.DeliveryAddress__c';
import ID_FIELD from '@salesforce/schema/Case.Id';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationFinishEvent,FlowNavigationBackEvent  } from 'lightning/flowSupport';
const FIELDS = ['Case.ContactMobile', 
                'Case.ContactEmail',
                'Case.DeliveryAddress__c',
                'Case.Email__c',
                'Case.PhoneNumber__c', 
                'Case.BillingProfile__c',
                'Case.Account.BillingStreetName__c',
                'Case.Account.BillingStreetNumber__c',
                'Case.Account.BillingCity',
                'Case.Account.BillingState',
                'Case.Account.BillingPostalCode',
                'Case.Account.BillingCountry',
                'Case.Account.BillingAddressFormula__c',
                'Case.BillingProfile__r.InvoicingStreetName__c',
                'Case.BillingProfile__r.InvoicingStreetNumber__c',
                'Case.BillingProfile__r.InvoicingStreetNumberExtension__c',
                'Case.BillingProfile__r.InvoicingCityCode__c',
                'Case.BillingProfile__r.InvoicingProvince__c',
                'Case.BillingProfile__r.InvoicingPostalCode__c',
                'Case.BillingProfile__r.InvoicingCountry__c',
                'Case.BillingProfile__r.InvoicingAddressFormula__c'];

export default class HdtDocumentSignatureManagerFlow extends LightningElement {
    @api processType;
    @api quoteType;
    @api recordId;
    @api accountId;
    @api source;
    @api outcome;
    @api availableActions = [];
    @api cancelCase;
    @api nextLabel;
    @api nextVariant;
    caseRecord;
    @track inputParams;
    @track enableNext = false;
    @track previewExecuted = false;


    @api
    get variantButton(){
        if(this.nextVariant != null && this.nextVariant !="" && this.nextVariant != "unedfined")
            return this.nextVariant;
        else 
            return "brand"
    }

    @api
    get labelButton(){
        if(this.nextLabel != null && this.nextLabel!="" && this.nextLabel != "unedfined")
            return this.nextLabel;
        else 
            return "Conferma Pratica"
    }

    connectedCallback(){
        //updateRecord({fields: { Id: this.recordId }});
    }
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
        wiredCase({ error, data }) {
            if (error) {
                
                let message = 'Unknown error';
                if (Array.isArray(error.body)) {
                    message = error.body.map(e => e.message).join(', ');
                } else if (typeof error.body.message === 'string') {
                    message = error.body.message;
                }
                console.log('data error ' + message);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading Case',
                        message,
                        variant: 'error',
                    }),
                );
            } else if (data) {
                console.log('data loaded');
                this.caseRecord = data;
                console.log(JSON.stringify(this.caseRecord.fields));
                var email = '';
                var phone = '';
                var contactEmail = this.caseRecord.fields.ContactEmail.value;
                var caseEmail = this.caseRecord.fields.Email__c.value;
                if(caseEmail != null && caseEmail != '')
                    email = caseEmail;
                else
                    email = contactEmail;
                var contactPhone = this.caseRecord.fields.ContactMobile.value;
                var casePhone = this.caseRecord.fields.PhoneNumber__c.value;
                console.log('casePhone ' + casePhone);
                console.log('contactPhone ' + contactPhone);
                if(casePhone != null && casePhone != ''){
                    phone = casePhone;
                } else{
                    phone = contactPhone;
                }
                    

                var BillingProfile__c = this.caseRecord.fields.BillingProfile__c.value;
                var billingAddress = '';
                var accountAddress = '';
                var completeAddress = '';
                var caseAddress = this.caseRecord.fields.DeliveryAddress__c.value;
                if(caseAddress != null && caseAddress != ''){
                    completeAddress = caseAddress;
                }else if(this.caseRecord.fields.BillingProfile__r.value != null){
                    completeAddress = this.caseRecord.fields.BillingProfile__r.value.fields.InvoicingAddressFormula__c.value;
                } else if(this.caseRecord.fields.Account.value != null){
                    completeAddress = this.caseRecord.fields.Account.value.fields.BillingAddressFormula__c.value;
                }

                var inputParams = {
                    context:'Case',
                    recordId:this.recordId,
                    processType:this.processType,
                    source : this.source,
                    phone : phone,
                    email : email,
                    accountId : this.accountId,
                    quoteType : this.quoteType,
                    addressWrapper : {
                        completeAddress : completeAddress,
                        Stato : '',
                        Provincia : '',
                        Via  : '',
                        CAP : '',
                        Comune  : '',
                        Civico  : '',
                        CodiceComuneSAP  : '',
                        EstensCivico : '',
                        CodiceViaStradarioSAP  : '',
                        FlagForzato  : '',
                        FlagVerificato  : ''
                    },
                    sendMode:'',
                    signMode:'' 
                }
                this.inputParams = JSON.stringify(inputParams);
                console.log(this.inputParams);
            }
        }
    handlePreviewExecuted(event){
        this.previewExecuted = true;
    }
    handleConfirmData(event){
        console.log('dati confermati ' + event.detail);
         // Create the recordInput object
         const fields = {};
         fields[ID_FIELD.fieldApiName] = this.recordId;
         console.log('result ' + event.detail);
         var resultWrapper = JSON.parse(event.detail);
         console.log('telefono ' + resultWrapper.phone);
         fields[PHONE_FIELD.fieldApiName] = resultWrapper.phone;
         fields[EMAIL_FIELD.fieldApiName] = resultWrapper.email;
         fields[ADDRESS_FIELD.fieldApiName] = resultWrapper.addressWrapper.completeAddress;

         const recordInput = { fields };

         updateRecord(recordInput)
             .then(() => {
                 // Display fresh data in the form
                 console.log('Record aggiornato');
                 return refreshApex(this.wiredCase);
             })
             .catch(error => {
                 console.log('Errore in aggiornamento');
                 this.dispatchEvent(
                     new ShowToastEvent({
                         title: 'Error creating record',
                         message: error.body.message,
                         variant: 'error'
                     })
                 );
             });
        this.enableNext = true;
    }

    handleGoNext() {

        if(this.enableNext){
            if((!this.previewExecuted && this.quoteType.localeCompare('Analitico') != 0)){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Errore',
                        message:'Attenzione! Devi effettuare la preview del documento prima di poter procedere con il Conferma Pratica.',
                        variant: 'error',
                    }),
                );
            }else{
                this.cancelCase = false;

                if(this.availableActions.find(action => action === 'NEXT')){

                    const navigateNextEvent = new FlowNavigationNextEvent();

                    this.dispatchEvent(navigateNextEvent);

                } else {

                    const navigateFinish = new FlowNavigationFinishEvent();

                    this.dispatchEvent(navigateFinish);
                }
            }
        }else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Errore',
                    message:'Attenzione! Devi confermare i dati prima di poter procedere con il Conferma Pratica.',
                    variant: 'error',
                }),
            );
        }

    }

    handleCancel(){

        if(this.availableActions.find(action => action === 'NEXT')){

            this.cancelCase = true;

            const navigateNextEvent = new FlowNavigationNextEvent();

            this.dispatchEvent(navigateNextEvent);

        } else {

            const navigateFinish = new FlowNavigationFinishEvent();

            this.dispatchEvent(navigateFinish);
        }

    }

    handleGoBack(){

        const navigateBackEvent = new FlowNavigationBackEvent();

        this.dispatchEvent(navigateBackEvent);

    }
}