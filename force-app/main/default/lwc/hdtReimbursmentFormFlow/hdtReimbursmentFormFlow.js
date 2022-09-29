import { LightningElement, api, wire } from 'lwc';
import { FlowNavigationNextEvent, FlowNavigationBackEvent  } from 'lightning/flowSupport';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';

import { getSObjectValue } from '@salesforce/apex'; //??

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
    beneficiaryTypeRequired;
    beneficiaryAccountDisabled = false;
    newFiedValue = {};


    @wire(getRecord, { recordId: '$caseId', fields: FIELDS })
    getCaseRecord({data,error}){
        if(data){
            console.log('***Count 3***');
            console.log('Record data --> '+JSON.stringify(data));
            this.caseRecord = data;

            console.log('### caseId = ' + this.caseId);
            console.log('### Object Name = ' + this.objectName);
            
            // console.log('### this.caseRecord.Id = ' + this.caseRecord.fields[Id].value);
            console.log('### this.caseRecord.Id = ' + getFieldValue(this.caseRecord, ID));

            // console.log('### caseRecord.BeneficiaryAccount__c = ' + this.caseRecord.BeneficiaryAccount__c);
            console.log("### BENEFICIARY_ACCOUNT = " + getFieldValue(this.caseRecord, BENEFICIARY_ACCOUNT));

            console.log("### BENEFICIARY_ACCOUNT = " + getFieldValue(this.caseRecord, REFUND_METHOD));
            console.log("### BENEFICIARY_ACCOUNT = " + getFieldValue(this.caseRecord, ACCOUNTHOLDER_TYPEBENEFICIARY));
            
        }else if(error){
            console.error('ERROR => ', JSON.stringify(error));
        }
    }
    // caseRecord;

    // @wire(getRecord, { recordId: '5001x00000FfZkCAAV', fields: FIELDS })
    
    get optionsForRefundMethod__c(){
        if(this.optionsByCity){

            console.log("###");
            console.log("--> get optionsForRefundMethod__c()");
            console.log("### optionsByCity = " + JSON.stringify(this.optionsByCity));
            // console.log("### optionsByCity.beneficiaryTypes = " + JSON.stringify(this.optionsByCity.beneficiaryTypes));
            // console.log("### optionsByCity.beneficiaryTypes = " + this.optionsByCity.beneficiaryTypes);
            // console.log("### SupplyCity__c = " + this.caseRecord.SupplyCity__c);
            // console.log("### SupplyCity__c = " + JSON.stringify(this.caseRecord.SupplyCity__c));
            // console.log("### city = " + this.optionsByCity.city);
            // console.log("### city = " + JSON.stringify(this.optionsByCity.city));
            console.log("### caseRecord = " + JSON.stringify(this.caseRecord));
            // console.log("### caseRecord = " + this.caseRecord);

            this.optionsByCity.forEach(element => {
                console.log("###");
                console.log("### START ForEach Refund");
                console.log("### element.city = " + element.city);
                console.log("### SUPPLY_CITY = " + getFieldValue(this.caseRecord, SUPPLY_CITY));
                console.log("### caseRecord = " + this.caseRecord);
                // console.log("### SUPPLY_CITY 2 = " + JSON.stringify(SUPPLY_CITY));

                // if(element.city === JSON.stringify(SUPPLY_CITY)){

                if(element.city === getFieldValue(this.caseRecord, SUPPLY_CITY)){
                    console.log("###");
                    console.log("### START IF Refund");
                    console.log("### element.reimbursementTypes 1 = " + element.reimbursementTypes);
                    // console.log("### element.reimbursementTypes 2 = " + JSON.stringify(this.element.reimbursementTypes));

                    element.reimbursementTypes.forEach(curValue => this.finalListReimbursement.push({ label: curValue, value: curValue }));
                }
                // this.finalList = finalList;
            });
            console.log("### finalListReimbursement = " + JSON.stringify(this.finalListReimbursement));
            return this.finalListReimbursement;
        }
        else 
            console.log("### START Else 1");
            return [
                { label: 'Bonifico', value: 'Bonifico' },
                { label: 'Assegno', value: 'Assegno' },
                { label: 'Compensazione', value: 'Compensazione'}
            ];
    }
    get optionsForAccountholderTypeBeneficiary__c(){
        if(this.optionsByCity){
            console.log("###");
            console.log("--> get optionsForAccountholderTypeBeneficiary__c()");
            console.log("### optionsByCity = " + JSON.stringify(this.optionsByCity));
            this.optionsByCity.forEach(element => {

                console.log("###");
                console.log("### START ForEach Beneficiary");
                console.log("### element.city = " + element.city);
                console.log("### SUPPLY_CITY = " + getFieldValue(this.caseRecord, SUPPLY_CITY));
                console.log("### caseRecord = " + this.caseRecord);

                // let finalList = [];
                if(element.city === getFieldValue(this.caseRecord, SUPPLY_CITY)){
                    console.log("###");
                    console.log("### START IF Beneficiary");
                // if(element.city === this.caseRecord.SupplyCity__c){ //Vecchio
                    console.log("### element.beneficiaryTypes = " + element.beneficiaryTypes);

                    // element.beneficiaryTypes.forEach(curValue => finalList.push({ label: curValue, value: curValue })); //Vecchio

                    element.beneficiaryTypes.forEach(curValue => this.finalListBeneficiary.push({ label: curValue, value: curValue }));

                }
            });
            console.log("### finalListBeneficiary = " + JSON.stringify(this.finalListBeneficiary));
            return this.finalListBeneficiary;
        }
        else 
            return [
                { label: 'Stesso Sottoscrittore', value: 'Stesso Sottoscrittore' },
                { label: 'Erede', value: 'Erede' },
                { label: 'Beneficiario Alternativo', value: 'Beneficiario Alternativo'}
            ];
    }

    async getRimborsoOption() {
        this.optionsByCity = await getRimborsoOptionsByCity();
        console.log("### result = " + JSON.stringify( this.optionsByCity));
        // console.log("$caseId = " + $caseId);

        // (result => this.optionsByCity = result)
        // (error => this.showErrorToast('Error getting reimbursment options!', error.body.message));

        // console.log("### optionsByCity = "+this.optionsByCity);
        //console.log("### result = "+this.result);
        
        // console.log("### optionsByCity = " + JSON.stringify(this.optionsByCity));
        // console.log("### result = " + JSON.stringify(this.result));
    }

    connectedCallback(){
        console.log("###");
        console.log("### START connectedCallback 1");
        console.log("### caseId = " + this.caseId);
        // console.log("### objectApiName = " + this.objectApiName); // Stampa??

        this.getRimborsoOption();

        console.log("### END connectedCallback");
    }

    handleInputChange(event){
        const source = event.target.name;
    
        // this.caseRecord.fields[source].value = event.target.value;
        // this.newFiedValue[source] = event.target.value;
        
        if(source == "RefundMethod__c") {
            this.beneficiaryTypeRequired = event.target.value == "Assegno";
            //this.beneficiaryTypeRequired = "Assegno";
            this.beneficiaryAccountDisabled = false;
            if(event.target.value == "Compensazione"){
                this.beneficiaryAccountDisabled = true;
                //this.caseRecord.BeneficiaryAccount__c = null;
                if(this.template.querySelector('[field-name="BeneficiaryAccount__c"]')) this.template.querySelector('[field-name="BeneficiaryAccount__c"]').value = null;
            }
        }
    }

    handleNextButton(){
        const fields = {};        
        // fields.Id = this.caseRecord.Id;
        fields.Id = getFieldValue(this.caseRecord, ID);

        // fields.RefundMethod__c = this.caseRecord.RefundMethod__c;
        // fields.RefundMethod__c = getFieldValue(this.caseRecord, REFUND_METHOD);
        // fields.RefundMethod__c = this.newFiedValue['RefundMethod__c'];

        if(this.template.querySelector('[data-id="RefundMethod__c"]')) fields.RefundMethod__c = this.template.querySelector('[data-id="RefundMethod__c"]').value;

        // fields.AccountholderTypeBeneficiary__c = this.caseRecord.fields[AccountholderTypeBeneficiary__c].value;  
        // fields.AccountholderTypeBeneficiary__c = getFieldValue(this.caseRecord, ACCOUNTHOLDER_TYPEBENEFICIARY);
        // fields.AccountholderTypeBeneficiary__c = this.newFiedValue['AccountholderTypeBeneficiary__c'];

        if(this.template.querySelector('[data-id="AccountholderTypeBeneficiary__c"]')) fields.AccountholderTypeBeneficiary__c = this.template.querySelector('[data-id="AccountholderTypeBeneficiary__c"]').value;
        
        // if(this.template.querySelector('[field-name="BeneficiaryAccount__c"]')) fields.BeneficiaryAccount__c = this.template.querySelector('[field-name="BeneficiaryAccount__c"]').value;
        if(this.template.querySelector('[data-id="BeneficiaryAccount__c"]')) fields.BeneficiaryAccount__c = this.template.querySelector('[data-id="BeneficiaryAccount__c"]').value;
        const recordInput = { fields };

        this.cancelCase = false;
        this.saveInDraft = false;

        updateRecord(recordInput)
            .then(() => {
                this.goNext();
            })
            .catch(error => this.showErrorToast('Error creating record', error.body.message));
    }

    handleBackButton(){
        this.goBack();
    }

    handleCancelButton(){
        this.cancelCase = true;
        this.saveInDraft = false;
        this.goNext();
    }

    handleDraftButton(){
        this.cancelCase = false;
        this.saveInDraft = true;
        this.goNext();
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