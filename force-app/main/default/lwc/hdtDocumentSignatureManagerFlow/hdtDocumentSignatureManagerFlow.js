import { LightningElement,track,api,wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import PHONE_FIELD from '@salesforce/schema/Case.PhoneNumber__c';
import EMAIL_FIELD from '@salesforce/schema/Case.Email__c';
import ADDRESS_FIELD from '@salesforce/schema/Case.DeliveryAddress__c';
import ID_FIELD from '@salesforce/schema/Case.Id';
import MOD_FIRMA from '@salesforce/schema/Case.SignMode__c';
import MOD_INVIO from '@salesforce/schema/Case.SendMode__c';
import InvoicingPostalCode from '@salesforce/schema/Case.InvoicingPostalCode__c';
import InvoicingStreetNumber from '@salesforce/schema/Case.InvoicingStreetNumber__c';
import InvoicingCityCode from '@salesforce/schema/Case.InvoicingCityCode__c';
import InvoicingStreetCode from '@salesforce/schema/Case.InvoicingStreetCode__c';
import InvoicingCity from '@salesforce/schema/Case.InvoicingCity__c';
import InvoicingStreetNumberExtension from '@salesforce/schema/Case.InvoicingStreetNumberExtension__c';
import IsInvoicingVerified from '@salesforce/schema/Case.IsInvoicingVerified__c';
import InvoicingPlace from '@salesforce/schema/Case.InvoicingPlace__c';
import InvoicingStreetName from '@salesforce/schema/Case.InvoicingStreetName__c';
import InvoicingCountry from '@salesforce/schema/Case.InvoicingCountry__c';
import InvoicingStreetToponym from '@salesforce/schema/Case.InvoicingStreetToponym__c';
import InvoicingProvince from '@salesforce/schema/Case.InvoicingProvince__c';
import AddressFormula from '@salesforce/schema/Case.AddressFormula__c';
import sendDocumentFile from '@salesforce/apex/HDT_LC_DocumentSignatureManager.sendDocumentFile';

import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationFinishEvent,FlowNavigationBackEvent  } from 'lightning/flowSupport';
const FIELDS = ['Case.ContactMobile', 
                'Case.ContactEmail',
                'Case.DeliveryAddress__c',
                'Case.Email__c',
                'Case.PhoneNumber__c', 
                'Case.BillingProfile__c',
                'Case.SignMode__c',
                'Case.SendMode__c',
                'Case.Account.BillingStreetName__c',
                'Case.Account.BillingStreetNumber__c',
                'Case.Account.BillingCity',
                'Case.Account.BillingState',
                'Case.Account.BillingPostalCode',
                'Case.Account.BillingCountry',
                'Case.Account.BillingAddressFormula__c',
                'Case.Account.BillingCityCode__c',
                'Case.Account.BillingStreetNumberExtension__c',
                'Case.Account.BillingStreetCode__c',
                'Case.InvoicingPostalCode__c',
				'Case.InvoicingStreetNumber__c',
				'Case.InvoicingCityCode__c',
				'Case.InvoicingStreetCode__c',
				'Case.InvoicingCity__c',
				'Case.InvoicingStreetNumberExtension__c',
				'Case.IsInvoicingVerified__c',
				'Case.InvoicingPlace__c',
				'Case.InvoicingStreetName__c',
				'Case.InvoicingCountry__c',
				'Case.InvoicingStreetToponym__c',
                'Case.InvoicingProvince__c'];

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
                var cap='';
                var stato = '';
                var via='';
                var comune='';
                var provincia='';
                var civico='';
                var codiceComuneSAP='';
                var estensCivico='';
                var codiceViaStradarioSAP='';
                var flagForzato=false;
                var flagVerificato=false;

                var contactEmail = this.caseRecord.fields.ContactEmail.value;
                var caseEmail = this.caseRecord.fields.Email__c.value;
                if(caseEmail != null && caseEmail != '')
                    email = caseEmail;
                else
                    email = contactEmail;
                var contactPhone = this.caseRecord.fields.ContactMobile.value;
                var casePhone = this.caseRecord.fields.PhoneNumber__c.value;
                if(casePhone != null && casePhone != ''){
                    phone = casePhone;
                } else{
                    phone = contactPhone;
                }
                var completeAddress = '';
                var caseAddress = this.caseRecord.fields.DeliveryAddress__c.value;
                if(caseAddress != null && caseAddress != ''){
                    completeAddress = caseAddress;
                    stato = this.caseRecord.fields.InvoicingCountry__c.value;
                    provincia = this.caseRecord.fields.InvoicingProvince__c.value;
                    via  = this.caseRecord.fields.InvoicingStreetName__c.value;
                    cap = this.caseRecord.fields.InvoicingPostalCode__c.value;
                    comune  = this.caseRecord.fields.InvoicingCity__c.value;
                    civico  = this.caseRecord.fields.InvoicingStreetNumber__c.value;
                    codiceComuneSAP  = this.caseRecord.fields.InvoicingCityCode__c.value;
                    estensCivico = this.caseRecord.fields.InvoicingStreetNumberExtension__c.value;
                    codiceViaStradarioSAP  = this.caseRecord.fields.InvoicingStreetCode__c.value;
                    flagForzato  = false;
                    flagVerificato  = this.caseRecord.fields.IsInvoicingVerified__c.value
                } else if(this.caseRecord.fields.Account.value != null){
                    completeAddress = this.caseRecord.fields.Account.value.fields.BillingAddressFormula__c.value;
                    stato = this.caseRecord.fields.Account.value.fields.BillingCountry.value;
                    //provincia = this.caseRecord.fields.Account.value.fields..value;
                    via  = this.caseRecord.fields.Account.value.fields.BillingStreetName__c.value;
                    cap = this.caseRecord.fields.Account.value.fields.BillingPostalCode.value;
                    comune  = this.caseRecord.fields.Account.value.fields.BillingCity.value;
                    civico  = this.caseRecord.fields.Account.value.fields.BillingStreetNumber__c.value;
                    codiceComuneSAP  = this.caseRecord.fields.Account.value.fields.BillingCityCode__c.value;
                    estensCivico = this.caseRecord.fields.Account.value.fields.BillingStreetNumberExtension__c.value;
                    codiceViaStradarioSAP  = this.caseRecord.fields.Account.value.fields.BillingStreetCode__c.value;
                    flagForzato  = false;
                    flagVerificato  = true;
                }

                var inputParams = {
                    dataConfirmed:false,
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
                        Stato : stato,
                        Provincia : provincia,
                        Via  : via,
                        CAP : cap,
                        Comune  : comune,
                        Civico  : civico,
                        CodiceComuneSAP  : codiceComuneSAP,
                        EstensCivico : estensCivico,
                        CodiceViaStradarioSAP  : codiceViaStradarioSAP,
                        FlagForzato  : flagForzato,
                        FlagVerificato  : flagVerificato
                    },
                    sendMode:this.caseRecord.fields.SendMode__c.value,
                    signMode:this.caseRecord.fields.SignMode__c.value 
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
        
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        var resultWrapper = JSON.parse(event.detail);
        if(resultWrapper.dataConfirmed){
            var estensioneCivico = ((resultWrapper.addressWrapper.EstensCivico)? resultWrapper.addressWrapper.EstensCivico:'');
            var address = resultWrapper.addressWrapper.Via + ' ' + resultWrapper.addressWrapper.Civico + ' ' + estensioneCivico + ', ' + resultWrapper.addressWrapper.Comune + ' ' + resultWrapper.addressWrapper.Provincia + ', ' + resultWrapper.addressWrapper.CAP + ' ' +resultWrapper.addressWrapper.Stato;
            console.log('indirizzo completo ' +address);
            fields[PHONE_FIELD.fieldApiName] = resultWrapper.phone;
            fields[EMAIL_FIELD.fieldApiName] = resultWrapper.email;
            fields[ADDRESS_FIELD.fieldApiName] = address;
            fields[MOD_FIRMA.fieldApiName] = resultWrapper.signMode;
            fields[MOD_INVIO.fieldApiName] = resultWrapper.sendMode;
            fields[InvoicingPostalCode.fieldApiName] = resultWrapper.addressWrapper.CAP;
            fields[InvoicingStreetNumber.fieldApiName] = resultWrapper.addressWrapper.Civico;
            fields[InvoicingCityCode.fieldApiName] = resultWrapper.addressWrapper.CodiceComuneSAP;
            fields[InvoicingStreetCode.fieldApiName] = resultWrapper.addressWrapper.CodiceViaStradarioSAP;
            fields[InvoicingCity.fieldApiName] = resultWrapper.addressWrapper.Comune;
            fields[InvoicingStreetNumberExtension.fieldApiName] = resultWrapper.addressWrapper.EstensCivico;
            fields[IsInvoicingVerified.fieldApiName] = resultWrapper.addressWrapper['Flag Verificato'];
            //fields[InvoicingPlace.fieldApiName] = resultWrapper.addressWrapper.
            fields[InvoicingProvince.fieldApiName] = resultWrapper.addressWrapper.Provincia;
            fields[InvoicingCountry.fieldApiName] = resultWrapper.addressWrapper.Stato;
            //fields[InvoicingStreetToponym.fieldApiName] = resultWrapper.addressWrapper.
            fields[InvoicingStreetName.fieldApiName] = resultWrapper.addressWrapper.Via;

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
        }else{
            this.enableNext = false;
        }
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
                var formParams = {
                    archive:'Y'
                }
                sendDocumentFile({
                    recordId: this.recordId,
                    context: 'Case',
                    formParams: JSON.stringify(formParams)
                }).then(result => {});

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