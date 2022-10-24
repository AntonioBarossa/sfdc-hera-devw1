import { LightningElement, api, wire } from 'lwc';
import { FlowNavigationNextEvent, FlowNavigationBackEvent  } from 'lightning/flowSupport';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';

import ID from '@salesforce/schema/Case.Id';

import SUPPLY_CITY from '@salesforce/schema/Case.SupplyCity__c';
import REFUND_METHOD from '@salesforce/schema/Case.RefundMethod__c';
import ACCOUNTHOLDER_TYPEBENEFICIARY from '@salesforce/schema/Case.AccountholderTypeBeneficiary__c';
import BENEFICIARY_ACCOUNT from '@salesforce/schema/Case.BeneficiaryAccount__c';

import getRimborsoOptionsByCity from '@salesforce/apex/HDT_LC_TariReimbursmentFormFlow.getRimborsoOptionsByCity';

// const FIELDS = [
//     "SupplyCity__c",         				// basato su lista comuni
//     "RefundMethod__c",         				// basato su comune selezionato
//     "AccountholderTypeBeneficiary__c",    	// basato su comune selezionato; obbligatorio se RefundMethod__c == "Assegno"
//     "BeneficiaryAccount__c"         		// sbiancato + readonly se RefundMethod__c == "Compensazione"
// ];

const FIELDS = [
    ID,
    SUPPLY_CITY,         				// basato su lista comuni
    REFUND_METHOD,         				// basato su comune selezionato
    ACCOUNTHOLDER_TYPEBENEFICIARY,    	// basato su comune selezionato; obbligatorio se RefundMethod__c == "Assegno"
    BENEFICIARY_ACCOUNT         		// sbiancato + readonly se RefundMethod__c == "Compensazione"
];

export default class HdtReimbursmentFormFlow extends LightningElement {

    @api caseId;
    //@api objectName; // Aggiunto dopo

    @api saveInDraft;
    @api cancelCase;

    caseRecord;
    finalListReimbursement = [];
    finalListBeneficiary = [];
    optionsByCity;
    beneficiaryTypeRequired = false;
    beneficiaryAccountDisabled = false;
    showBeneficiaryInput = false;
    optionsForRefundMethod__c = [];
    optionsForAccountholderTypeBeneficiary__c=[];
    showForm = false;
    refoundDefaultVal;
    holderDefaultVal;


    @wire(getRecord, { recordId: '$caseId', fields: FIELDS })
    getCaseRecord(response) {
        this._getRecordResponse = response;
        let error = response && response.error;
        let data = response && response.data;
        if(data){
            console.log('Record data --> '+JSON.stringify(data));
            this.caseRecord = data;

            console.log("### BENEFICIARY_ACCOUNT = " + getFieldValue(this.caseRecord, BENEFICIARY_ACCOUNT));
            console.log("### BENEFICIARY_ACCOUNT = " + getFieldValue(this.caseRecord, REFUND_METHOD));
            console.log("### BENEFICIARY_ACCOUNT = " + getFieldValue(this.caseRecord, ACCOUNTHOLDER_TYPEBENEFICIARY));
            
            let beneficiaryType = getFieldValue(this.caseRecord, ACCOUNTHOLDER_TYPEBENEFICIARY);
            if(['Erede', 'Beneficiario Alternativo'].includes(beneficiaryType)) this.showBeneficiaryInput = true;

            this.getRimborsoOptions();
            
        }else if(error){
            console.error('ERROR => ', JSON.stringify(error));
        }
    }

    async getRimborsoOptions() {
        this.optionsByCity = await getRimborsoOptionsByCity();

        console.log("### getRimborsoOptions result", JSON.stringify( this.optionsByCity));

        if(this.optionsByCity){
            let refoundOptFinalList = [];
            let holderOptFinalList = [];
            this.optionsByCity.forEach(element => {
                console.log("### element.city = " + element.city);
                if(element.city === getFieldValue(this.caseRecord, SUPPLY_CITY)){
                    console.log("### city found", element.reimbursementTypes, element.beneficiaryTypes);
                    element.reimbursementTypes.forEach(curValue => refoundOptFinalList.push({ label: curValue, value: curValue }));
                    element.beneficiaryTypes.forEach(curValue => holderOptFinalList.push({ label: curValue, value: curValue }));
                }
            });
            this.optionsForRefundMethod__c = refoundOptFinalList;
            this.optionsForAccountholderTypeBeneficiary__c = holderOptFinalList;
        }
        else{
            this.optionsForRefundMethod__c = [
                { label: 'Bonifico', value: 'Bonifico' },
                { label: 'Assegno', value: 'Assegno' },
                { label: 'Compensazione', value: 'Compensazione'}
            ];            
            this.optionsForAccountholderTypeBeneficiary__c = [
                { label: 'Stesso Sottoscrittore', value: 'Stesso Sottoscrittore' },
                { label: 'Erede', value: 'Erede' },
                { label: 'Beneficiario Alternativo', value: 'Beneficiario Alternativo'}
            ];
        }
        console.log('optionsForRefundMethod__c', this.optionsForRefundMethod__c);
        console.log('optionsForAccountholderTypeBeneficiary__c', this.optionsForAccountholderTypeBeneficiary__c);

        this.refoundDefaultVal = getFieldValue(this.caseRecord, REFUND_METHOD);
        this.holderDefaultVal = getFieldValue(this.caseRecord, ACCOUNTHOLDER_TYPEBENEFICIARY);

        if(this.refoundDefaultVal == "Assegno") this.beneficiaryTypeRequired = true;
        if(this.refoundDefaultVal == "Compensazione") this.beneficiaryAccountDisabled = true;
        if(['Erede', 'Beneficiario Alternativo'].includes(this.holderDefaultVal)) this.showBeneficiaryInput = true;

        this.showForm = true;
    }

    handleInputChange(event){
        const source = event.target.name;
        
        if(source == "RefundMethod__c") {
            this.beneficiaryTypeRequired = event.target.value == "Assegno";
            
            this.beneficiaryAccountDisabled = false;
            if(event.target.value == "Compensazione"){
                this.beneficiaryAccountDisabled = true;
                
                if(this.template.querySelector('[field-name="BeneficiaryAccount__c"]')) this.template.querySelector('[field-name="BeneficiaryAccount__c"]').value = null;
            }
        }
        else if(source == "AccountholderTypeBeneficiary__c"){
            this.showBeneficiaryInput = ['Erede', 'Beneficiario Alternativo'].includes(event.target.value);
        }
    }

    saveRecordAndGoNext(){
        const fields = {};
        fields.Id = getFieldValue(this.caseRecord, ID);
        if(this.template.querySelector('[data-id="RefundMethod__c"]')) fields.RefundMethod__c = this.template.querySelector('[data-id="RefundMethod__c"]').value;
        if(this.template.querySelector('[data-id="AccountholderTypeBeneficiary__c"]')) fields.AccountholderTypeBeneficiary__c = this.template.querySelector('[data-id="AccountholderTypeBeneficiary__c"]').value;
        if(this.template.querySelector('[data-id="BeneficiaryAccount__c"]')) fields.BeneficiaryAccount__c = this.template.querySelector('[data-id="BeneficiaryAccount__c"]').value;
        const recordInput = { fields };

        if( !fields.RefundMethod__c || fields.RefundMethod__c == ""){
            this.showErrorToast('Attenzione!', 'Selezionare un Tipo Rimborso prima di proseguire.');
            return;
        }
        if( fields.RefundMethod__c == "Assegno" && (!fields.AccountholderTypeBeneficiary__c || fields.AccountholderTypeBeneficiary__c == "")){
            this.showErrorToast('Attenzione!', 'Selezionare un Tipo Beneficiario prima di proseguire.');
            return;
        }


        updateRecord(recordInput)
            .then(() => {
                this.goNext();
            })
            .catch(error => this.showErrorToast('Error updating record', error.body.message));
    }

    handleNextButton(){
        this.cancelCase = false;
        this.saveInDraft = false;
        this.saveRecordAndGoNext();
    }

    handleDraftButton(){
        this.cancelCase = false;
        this.saveInDraft = true;
        this.saveRecordAndGoNext();
    }

    handleCancelButton(){
        this.cancelCase = true;
        this.saveInDraft = false;
        this.goNext();
    }

    handleBackButton(){
        this.goBack();
    }

    goNext(){
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
    }
    
    goBack(){
        const navigateBackEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(navigateBackEvent);
    }
    
    showErrorToast(t, m){
        this.dispatchEvent(
            new ShowToastEvent({
                title: t,
                message: m,
                variant: 'error'
            })
        );
    }
}