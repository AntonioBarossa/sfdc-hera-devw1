import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCustomSettings from '@salesforce/apex/HDT_LC_ServicePointCustomSettings.getCustomSettings';
import { getRecord } from 'lightning/uiRecordApi';

export default class HdtTargetObjectCreateForm extends LightningElement {
    @api recordtype;
    @api accountid;
    objectApiName = 'ServicePoint__c';
    fieldsData;
    fieldsAddress;
    fieldsReady = false;
    servicePointCode;
    servicePointId;
    newServicePointObject;
    fillFieldsDataDisabled = true;
    verifyFieldsAddressDisabled = true;
    get saveBtnDisabled(){
        if(this.fillFieldsDataDisabled == false 
            && this.verifyFieldsAddressDisabled == false){
            return false;
        } else {
            return true;
        }
    }

    connectedCallback(){
        getCustomSettings().then(data => {

            let fieldsDataRaw;
            let fieldsAddressRaw;

            //get data fields
            switch(this.recordtype.label){
                case 'Elettrico':
                    fieldsDataRaw = data.FieldEle__c;
                    break;
                case 'Gas':
                    fieldsDataRaw = data.FieldGas__c;
            }

            this.fieldsData = fieldsDataRaw.split(",");
            for (var i = 0; i < this.fieldsData.length; i++) {
                this.fieldsData[i] = this.fieldsData[i].trim();
            }

            //get address fields
            fieldsAddressRaw = data.fieldAddress__c;
            this.fieldsAddress = fieldsAddressRaw.split(",");
            for (var i = 0; i < this.fieldsAddress.length; i++) {
                this.fieldsAddress[i] = this.fieldsAddress[i].trim();
            }

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

    handleSubmit(event){
        event.preventDefault();
        const submitedFields = event.detail.fields;
        submitedFields.RecordTypeId = this.recordtype.value;
        submitedFields.Account__c = this.accountid;
        this.template.querySelector('lightning-record-edit-form').submit(submitedFields);
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
        const submitBtn = this.template.querySelector( ".hidden" );
   
        if(submitBtn){ 
            submitBtn.click();
        }
     }

}