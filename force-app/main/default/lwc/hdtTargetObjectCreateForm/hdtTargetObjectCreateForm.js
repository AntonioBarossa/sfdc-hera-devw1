import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCustomSettings from '@salesforce/apex/HDT_LC_ServicePointCustomSettings.getCustomSettings';
import { getRecord } from 'lightning/uiRecordApi';

export default class HdtTargetObjectCreateForm extends LightningElement {
    @api recordtype;
    @api accountid;
    objectApiName = 'ServicePoint__c';
    fieldsData;
    @track fieldsDataObject = [];
    fieldsAddress;
    fieldsAddressReq;
    @track fieldsAddressObject = [];
    @track allFieldsObject = [];
    allFieldsData;
    allFieldsDataReq;
    fieldsWithError = [];
    @track allFieldsObject = [];
    fieldsReady = false;
    servicePointCode;
    servicePointId;
    newServicePointObject;
    fillFieldsDataDisabled = true;
    verifyFieldsAddressDisabled = true;
    fieldsDataReq;
    fieldsDataWithError = [];
    fieldsAddressWithError = [];
    @track submitedAddressFields;
    @track allSubmitedFields = {};
    get saveBtnDisabled(){
        if(this.fillFieldsDataDisabled == false 
            && this.verifyFieldsAddressDisabled == false){
            return false;
        } else {
            return true;
        }
    }

    handleVerifyFieldAddressDisabled(event){
        this.verifyFieldsAddressDisabled = event.detail;
    }

    toArray(fieldsDataRaw){
        let fieldsData = fieldsDataRaw.split(",");
        let fieldsDataFinal = [];

        for (var i = 0; i < fieldsData.length; i++) {
            if(fieldsData[i] != ''){
                fieldsDataFinal.push(fieldsData[i].trim());
            }
        }

        return fieldsDataFinal;
    }

    toObject(fieldsData, fieldsDataReq){

        let fieldsDataObject = [];

        fieldsData.forEach(element => {
            fieldsDataObject.push(
               {
                   fieldname: element,
                   required : fieldsDataReq.includes(element)
               }
           ) 
        });

        return fieldsDataObject;
    }

    connectedCallback(){
        getCustomSettings().then(data => {
            let fieldsDataRaw;
            let fieldsDataReqRaw;

            //get data fields
            switch(this.recordtype.label){
                case 'Elettrico':
                    fieldsDataRaw = data.FieldEle__c;
                    fieldsDataReqRaw = data.FieldRequiredEle__c;
                    break;
                case 'Gas':
                    fieldsDataRaw = data.FieldGas__c;
                    fieldsDataReqRaw = data.FieldRequiredGas__c;
            }

            this.fieldsData = this.toArray(fieldsDataRaw);
            this.fieldsDataReq = this.toArray(fieldsDataReqRaw);
            this.fieldsDataObject = this.toObject(this.fieldsData, this.fieldsDataReq);

            //get address fields
            this.fieldsAddress = this.toArray(data.fieldAddress__c);
            this.fieldsAddressReq = this.toArray(data.FieldRequiredAddress__c);
            this.fieldsAddressObject = this.toObject(this.fieldsAddress, this.fieldsAddressReq);
            
            //merge all fields together
            this.allFieldsData = this.fieldsData.concat(this.fieldsAddress);
            this.allFieldsDataReq = this.fieldsDataReq.concat(this.fieldsAddressReq);
            this.allFieldsObject = this.toObject(this.allFieldsData, this.allFieldsDataReq);

            //fields have been loaded
            this.fieldsReady = true;
        }).catch(error => {
            const toastErrorMessage = new ShowToastEvent({
                title: 'Error',
                message: error.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    handleFieldsDataChange(event){

        if(event.target.fieldName == 'ServicePointCode__c'){
            
            this.servicePointCode = event.target.value;
            if (this.servicePointCode.length > 13) {
                this.fillFieldsDataDisabled = false;
            } else {
                this.fillFieldsDataDisabled = true;
            }

        }

        this.allSubmitedFields[event.target.fieldName] = event.target.value;

    }

    handleDataFieldsFilling(){
        let inp = this.template.querySelectorAll(".fieldsData");

        inp.forEach(function(element){

            if(element.fieldName !="ServicePointCode__c"){
                element.value = 'testFill';
            }

        },this);
    }

    closeCreateTargetObjectModal(){
        this.dispatchEvent(new CustomEvent('closecreateform'));
    }

    getSubmitedAddressFields(event){
        this.submitedAddressFields = event.detail;
    }

    handleSubmit(event){
        event.preventDefault();
        const submitedFields = event.detail.fields;
        submitedFields.RecordTypeId = this.recordtype.value;
        submitedFields.Account__c = this.accountid;

        for (let [key, value] of Object.entries(this.submitedAddressFields)) {
            submitedFields[key] = value;
        }

     }

     handleSuccess(event){
        this.servicePointId = event.detail.id;
        this.closeCreateTargetObjectModal();
        const toastSuccessMessage = new ShowToastEvent({
            title: 'Success',
            message: 'Service Point created successfully',
            variant: 'success'
        });
        this.dispatchEvent(toastSuccessMessage);
     }

     save(){

        let validForm = true;

        this.allSubmitedFields.RecordTypeId = this.recordtype.value;
        this.allSubmitedFields.Account__c = this.accountid;
        for (let [key, value] of Object.entries(this.submitedAddressFields)) {
            this.allSubmitedFields[key] = value;
        }

        for(var i=0; i<this.fieldsDataReq.length; i++){
            
            let reqdata = this.allSubmitedFields[this.fieldsDataReq[i]];

            if( reqdata == undefined || reqdata == '' ){
                validForm = false;
                this.fieldsDataWithError.push(this.fieldsDataReq[i]);
            }
        }

        for(var i=0; i<this.fieldsAddressReq.length; i++){
            
            let reqaddr = this.allSubmitedFields[this.fieldsAddressReq[i]];

            if( reqaddr == undefined || reqaddr == '' ){
                validForm = false;
                this.fieldsAddressWithError.push(this.fieldsAddressReq[i]);
            }
        }
        
        if (validForm) {
            this.template.querySelector('lightning-record-edit-form').submit(submitedFields);
        } else {

            this.template.querySelector('c-hdt-target-object-address-fields').checkInvalidFields(this.fieldsAddressWithError);
            
            for(var i=0; i<this.fieldsDataWithError.length; i++){
            
                let dataName = "[data-name='"+this.fieldsDataWithError[i]+"']";
                let dataField = this.template.querySelector(dataName);
                dataField.reportValidity();
            }
            
        }
     }

}