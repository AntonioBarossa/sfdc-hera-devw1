import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCustomSettings from '@salesforce/apex/HDT_LC_ServicePointCustomSettings.getCustomSettings';
import getServicePoint from '@salesforce/apex/HDT_LC_ServicePoint.getServicePoint';

export default class HdtTargetObjectCreateForm extends LightningElement {
    @api recordtype;
    @api accountid;
    @api selectedservicepoint;

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
    fillFieldsDataDisabled = true;
    verifyFieldsAddressDisabled = true;
    fieldsDataReq;
    fieldsDataWithError = [];
    fieldsAddressWithError = [];
    @track submitedAddressFields;
    @track allSubmitedFields = {};
    hasDataBeenFilled = false;
    hasAddressBeenVerified = false;
    loading = false;
    recordTypeId;
    @track servicePointRetrievedData;
    fieldsDataRaw;
    fieldsDataReqRaw;
    customSettings;
    
    get saveBtnDisabled(){
        if(this.hasDataBeenFilled && this.hasAddressBeenVerified){
            return false;
        } else {
            return true;
        }
    }

    handleAddressVerification(event){
        this.hasAddressBeenVerified = event.detail;
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
            
           if(this.selectedservicepoint != undefined){

                fieldsDataObject.push(
                    {
                        fieldname: element,
                        required : fieldsDataReq.includes(element),
                        value: this.servicePointRetrievedData[element]
                    }
                ) 
            } else {
                fieldsDataObject.push(
                    {
                        fieldname: element,
                        required : fieldsDataReq.includes(element),
                        value: ''
                    }
                ) 
            }

        });

        

        return fieldsDataObject;
    }

    connectedCallback(){
        this.loading = true;
        
        getCustomSettings().then(data => {

            //get data fields
            switch(this.recordtype.label){
                case 'Elettrico':
                    this.fieldsDataRaw = data.FieldEle__c;
                    this.fieldsDataReqRaw = data.FieldRequiredEle__c;
                    break;
                case 'Gas':
                    this.fieldsDataRaw = data.FieldGas__c;
                    this.fieldsDataReqRaw = data.FieldRequiredGas__c;
            }

            if(this.selectedservicepoint != undefined){
                this.customSettings = data;

            let queryFields = this.fieldsDataRaw + ', ' + this.customSettings.fieldAddress__c;
            
            getServicePoint({code:this.selectedservicepoint['Codice POD/PDR'],fields: queryFields}).then(data =>{
                console.log(JSON.parse(JSON.stringify(data)));
                this.servicePointRetrievedData = data[0];

                this.fieldsData = this.toArray(this.fieldsDataRaw);
            this.fieldsDataReq = this.toArray(this.fieldsDataReqRaw);
            this.fieldsDataObject = this.toObject(this.fieldsData, this.fieldsDataReq);

                //get address fields
             this.fieldsAddress = this.toArray(this.customSettings.fieldAddress__c);
             this.fieldsAddressReq = this.toArray(this.customSettings.FieldRequiredAddress__c);
             this.fieldsAddressObject = this.toObject(this.fieldsAddress, this.fieldsAddressReq);
             
             //merge all fields together
             this.allFieldsData = this.fieldsData.concat(this.fieldsAddress);
             this.allFieldsDataReq = this.fieldsDataReq.concat(this.fieldsAddressReq);
             this.allFieldsObject = this.toObject(this.allFieldsData, this.allFieldsDataReq);
                
            }).catch(error => {
                const toastErrorMessage = new ShowToastEvent({
                    title: 'Error',
                    message: error.message,
                    variant: 'error'
                });
                this.dispatchEvent(toastErrorMessage);
            });
        } else {
            this.fieldsData = this.toArray(this.fieldsDataRaw);
            this.fieldsDataReq = this.toArray(this.fieldsDataReqRaw);
            this.fieldsDataObject = this.toObject(this.fieldsData, this.fieldsDataReq);

            //get address fields
            this.fieldsAddress = this.toArray(data.fieldAddress__c);
            this.fieldsAddressReq = this.toArray(data.FieldRequiredAddress__c);
            this.fieldsAddressObject = this.toObject(this.fieldsAddress, this.fieldsAddressReq);
            
            //merge all fields together
            this.allFieldsData = this.fieldsData.concat(this.fieldsAddress);
            this.allFieldsDataReq = this.fieldsDataReq.concat(this.fieldsAddressReq);
            this.allFieldsObject = this.toObject(this.allFieldsData, this.allFieldsDataReq);
        }
        
             
            

            //fields have been loaded
            this.fieldsReady = true;
            this.loading = false;
        }).catch(error => {
            this.loading = false;
            const toastErrorMessage = new ShowToastEvent({
                title: 'Error',
                message: error.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    renderedCallback(){
        if(this.fieldsReady){
            let accountField = this.template.querySelector('[data-name="Account__c"]');
            if(accountField != null || accountField != undefined){
                accountField.value = this.accountid;
            }

        }
    }

    disconnectedCallback(){
        this.fieldsReady = false;
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
        // let inp = this.template.querySelectorAll(".fieldsData");

        // if(this.servicePointRetrievedData != undefined){

        // inp.forEach(function(element){
            
        //     element.value = 'test';
        // });

        // }

        this.hasDataBeenFilled = true;
    }

    closeCreateTargetObjectModal(){
        this.dispatchEvent(new CustomEvent('closecreateform'));
    }

    getSubmitedAddressFields(event){
        this.submitedAddressFields = event.detail;
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
            this.loading = true;
            this.template.querySelector('lightning-record-edit-form').submit(this.allSubmitedFields);
        } else {

            this.template.querySelector('c-hdt-target-object-address-fields').checkInvalidFields(this.fieldsAddressWithError);
            
            for(var i=0; i<this.fieldsDataWithError.length; i++){
            
                let dataName = "[data-name='"+this.fieldsDataWithError[i]+"']";
                let dataField = this.template.querySelector(dataName);
                dataField.reportValidity();
            }
            
        }
    }

    handleSuccess(event){
        this.loading = false;
        this.closeCreateTargetObjectModal();
        this.servicePointId = event.detail.id;
        const toastSuccessMessage = new ShowToastEvent({
            title: 'Success',
            message: 'Service Point created successfully',
            variant: 'success'
        });
        this.dispatchEvent(toastSuccessMessage);
    }

}