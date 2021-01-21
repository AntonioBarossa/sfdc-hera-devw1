import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCustomSettings from '@salesforce/apex/HDT_LC_ServicePointCustomSettings.getCustomSettings';
import getServicePoint from '@salesforce/apex/HDT_LC_TargetObjectCreateForm.getServicePoint';
import createServicePoint from '@salesforce/apex/HDT_LC_TargetObjectCreateForm.createServicePoint';
import confirmServicePoint from '@salesforce/apex/HDT_LC_TargetObjectCreateForm.confirmServicePoint';
import getInstanceWrapAddressObject from '@salesforce/apex/HDT_UTL_ServicePoint.getInstanceWrapAddressObject';

export default class HdtTargetObjectCreateForm extends LightningElement {
    @api recordtype;
    @api accountid;
    @api selectedservicepoint;
    @api wrapObjectInput= [];
    @api wrapAddressObject;
    @api sale;
    @api fieldsWrapObject=[];
    data;
    objectApiName = 'ServicePoint__c';
    fieldsData;
    @track fieldsDataObject = [];
    fieldsAddress;
    fieldsAddressReq;
    @api fieldsAddressObject = [];
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
    @api servicePointRetrievedData;
    fieldsDataRaw = '';
    fieldsDataReqRaw = '';
    customSettings;
    @track newServicePoint;
    validForm = true;
    verifyAddressDisabledOnUpdate = true;
    
    /**
     * Handle save button availability
     */
    get saveBtnDisabled(){
        console.log('HdtTargetObjectCreateForm - get saveBtnDisabled' + JSON.stringify(this.verifyAddressDisabledOnUpdate));
        if((this.selectedservicepoint != undefined && this.verifyAddressDisabledOnUpdate)
            || this.selectedservicepoint != undefined && !this.verifyAddressDisabledOnUpdate && this.hasAddressBeenVerified){
                console.log('saveBtnDisabled false');
            return false;
        } else {
            console.log('saveBtnDisabled true');
            return false;
        }
    }

    /**
     * Verify address data
     */
    handleAddressVerification(event){
        this.hasAddressBeenVerified = event.detail;
    }

    /**
     * Split string and create array of fields
     * @param {*} fieldsDataRaw 
     */
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

    /**
     * Form array of field objects
     * @param {*} fieldsData 
     * @param {*} fieldsDataReq 
     */
    toObject(fieldsData, fieldsDataReq){

        let fieldsDataObject = [];

        fieldsData.forEach(element => {
            
           if(this.selectedservicepoint != undefined){

                fieldsDataObject.push(
                    {
                        fieldname: element,
                        required : fieldsDataReq.includes(element),
                        value: this.servicePointRetrievedData[element],
                        disabled: element == 'ServicePointCode__c' ? true : false
                    }
                ) 
            } else {
                fieldsDataObject.push(
                    {
                        fieldname: element,
                        required : fieldsDataReq.includes(element),
                        value: '',
                        disabled: false
                    }
                ) 
            }

        });

        return fieldsDataObject;
    }

    toObjectAddressInit(data){

        let fieldsDataObject = [];
        console.log('');
        Object.keys(data).forEach(keys=> {
        
           

                fieldsDataObject.push(
                    {
                        fieldname: keys,
                        required : false,
                        value: '',
                        disabled: false
                    }
                ) 

        });

        return fieldsDataObject;
    }

    /**
     * Organize fields data
     */
    manageFields(){
        //get main data fields
        this.fieldsData = this.toArray(this.fieldsDataRaw);
        this.fieldsDataReq = this.toArray(this.fieldsDataReqRaw);
        this.fieldsDataObject = this.toObject(this.fieldsData, this.fieldsDataReq);

        //get address fields
        this.fieldsAddress = this.toArray(this.customSettings.FieldAddress__c);
        this.fieldsAddressReq = this.toArray(this.customSettings.FieldRequiredAddress__c);
        
        //merge all fields together
        this.allFieldsData = this.fieldsData.concat(this.fieldsAddress);
        this.allFieldsDataReq = this.fieldsDataReq.concat(this.fieldsAddressReq);
        this.allFieldsObject = this.toObject(this.allFieldsData, this.allFieldsDataReq);
    }

    connectedCallback(){
        this.loading = true;
        
        getCustomSettings().then(data => {
            //get data fields based on recordtype label
            switch(this.recordtype.label){
                case 'Punto Elettrico':
                    this.fieldsDataRaw = (data.FieldGeneric__c == null || data.FieldGeneric__c == undefined ? data.FieldEle__c  : (data.FieldEle__c == null || data.FieldEle__c == null ? data.FieldGeneric__c  :  data.FieldGeneric__c + ',' + data.FieldEle__c ) );
                    //this.fieldsDataRaw +=','+ data.FieldEle__c;
                    this.fieldsDataReqRaw = (data.FieldGeneric__c == null || data.FieldGeneric__c == undefined ? data.FieldRequiredEle__c  : (data.FieldRequiredEle__c == null || data.FieldRequiredEle__c == null ? data.FieldGeneric__c  :  data.FieldGeneric__c + ',' + data.FieldRequiredEle__c ) );
                    break;
                case 'Punto Gas':
                    this.fieldsDataRaw = (data.FieldGeneric__c == null || data.FieldGeneric__c == undefined ? data.FieldGas__c  : (data.FieldGas__c == null || data.FieldGas__c == null ? data.FieldGeneric__c  :  data.FieldGeneric__c + ',' + data.FieldGas__c ) );
                    //this.fieldsDataRaw = undefined || null  ? this.fieldsDataRaw += data.FieldGas__c :  this.fieldsDataRaw +=','+ data.FieldGas__c;
                   // this.fieldsDataRaw += data.FieldGas__c;
                    this.fieldsDataReqRaw = (data.FieldGeneric__c == null || data.FieldGeneric__c == undefined ? data.FieldRequiredGas__c  : (data.FieldRequiredGas__c == null || data.FieldRequiredGas__c == null ? data.FieldGeneric__c  :  data.FieldGeneric__c + ',' + data.FieldRequiredGas__c ) );
            }

            this.customSettings = data;
            console.log(JSON.stringify(this.selectedservicepoint)+'********selectedServicePoint');
            if(this.selectedservicepoint != undefined){
                
                this.fieldsDataRaw = 'RecordTypeId, RecordType.Name, ' + data.FieldEle__c + ', ' + data.FieldGas__c+','+ data.FieldGeneric__c;
                this.fieldsDataReqRaw = data.FieldRequiredEle__c + ', ' + data.FieldRequiredGas__c+','+ data.FieldRequiredGeneric__c;

                let queryFields = [...new Set(this.toArray(this.fieldsDataRaw + ', ' + this.customSettings.FieldAddress__c))];
                console.log('queryFields*************'+JSON.stringify(queryFields) );
                getServicePoint({code:this.selectedservicepoint['Codice Punto'],fields: queryFields.join()}).then(data =>{
                    
                    this.servicePointRetrievedData = data[0];
                    console.log('servicePointRetriviedData: ******'+JSON.stringify(this.servicePointRetrievedData));
                    switch(this.servicePointRetrievedData.RecordType.Name){
                        case 'Punto Elettrico':
                            this.fieldsDataRaw = (this.customSettings.FieldGeneric__c == null || this.customSettings.FieldGeneric__c == undefined ? this.customSettings.FieldEle__c  : (this.customSettings.FieldEle__c == null || this.customSettings.FieldEle__c == null ? this.customSettings.FieldGeneric__c  :  this.customSettings.FieldGeneric__c + ',' + this.customSettings.FieldEle__c ) );

                           // this.fieldsDataRaw = this.customSettings.FieldEle__c;
                            this.fieldsDataReqRaw = (this.customSettings.FieldGeneric__c == null || this.customSettings.FieldGeneric__c == undefined ? this.customSettings.FieldRequiredEle__c  : (this.customSettings.FieldRequiredEle__c == null || this.customSettings.FieldRequiredEle__c == null ? this.customSettings.FieldGeneric__c  :  this.customSettings.FieldGeneric__c + ',' + this.customSettings.FieldRequiredEle__c ) );
                            break;
                        case 'Punto Gas':
                            this.fieldsDataRaw = (this.customSettings.FieldGeneric__c == null || this.customSettings.FieldGeneric__c == undefined ? this.customSettings.FieldGas__c  : (this.customSettings.FieldGas__c == null || this.customSettings.FieldGas__c == null ? this.customSettings.FieldGeneric__c  :  this.customSettings.FieldGeneric__c + ',' + this.customSettings.FieldGas__c ) );

                           // this.fieldsDataRaw = this.customSettings.FieldGas__c;
                            this.fieldsDataReqRaw =(this.customSettings.FieldGeneric__c == null || this.customSettings.FieldGeneric__c == undefined ? this.customSettings.FieldRequiredGas__c  : (this.customSettings.FieldRequiredGas__c == null || this.customSettings.FieldRequiredGas__c == null ? this.customSettings.FieldGeneric__c  :  this.customSettings.FieldGeneric__c + ',' + this.customSettings.FieldRequiredGas__c ) );
                    }
                    //this.template.querySelector('c-hdt-target-object-address-fields').connectedCallback();
                    this.manageFields();
                    this.template.querySelector("c-hdt-target-object-address-fields").getInstanceWrapObject(this.servicePointRetrievedData);
                }).catch(error => {
                    const toastErrorMessage = new ShowToastEvent({
                        title: 'Errore',
                        message: error.body.message,
                        variant: 'error'
                    });
                    this.dispatchEvent(toastErrorMessage);
                    console.log('error****'+error.body.message);
                });

            } else {
                console.log(this.selectedservicepoint+'selectedServicePoint');
                this.manageFields();
                console.log('fieldsData'+ this.fieldsAddress);
            }
            console.log('fieldsData'+ this.fieldsAddress);
            //fields have been loaded
            this.fieldsReady = true;
            this.loading = false;
        }).catch(error => {
            this.loading = false;
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    /**
     * Pre-fill Account__c field on render
     */
    renderedCallback(){
        if(this.fieldsReady){
            if(this.selectedservicepoint == undefined){
                let accountField = this.template.querySelector('[data-name="Account__c"]');
                if(accountField != null || accountField != undefined){
                    accountField.value = this.accountid;
                }
            }
        }
    }

    /**
     * Reset fields loading when closing modal
     */
    disconnectedCallback(){
        this.fieldsReady = false;
    }

    /**
     * Handle fill fields button availability
     * @param {*} fieldName
     * @param {*} fieldValue
     */
    handleFillFieldsButtonAvailability(fieldName, fieldValue){
        if(fieldName == 'ServicePointCode__c'){
            
            this.servicePointCode = fieldValue;
            if (this.servicePointCode.length > 13 && this.selectedservicepoint == undefined) {
                this.fillFieldsDataDisabled = false;
            } else {
                this.fillFieldsDataDisabled = true;
            }

        }
    }

    /**
     * Get fields value
     * @param {*} event 
     */
    handleFieldsDataChange(event){

        this.handleFillFieldsButtonAvailability(event.target.fieldName, event.target.value);

        this.allSubmitedFields[event.target.fieldName] = event.target.value;

        this.validForm = true;

    }

    /**
     * Handle main data fields filling request
     */
    handleDataFieldsFilling(){
        // let inp = this.template.querySelectorAll(".fieldsData");

        // if(this.servicePointRetrievedData != undefined){

        // inp.forEach(function(element){
            
        //     element.value = 'test';
        // });

        // }

        this.hasDataBeenFilled = true;
    }

    /**
     * Close create form
     */
    closeCreateTargetObjectModal(){
        this.dispatchEvent(new CustomEvent('closecreateform'));
    }

    /**
     * Get submited address fields values
     * @param {*} event 
     */
    getSubmitedAddressFields(event){
        this.submitedAddressFields = event.detail;
        this.validForm = true;
    }

    /**
     * Check validity before saving
     */
    validationChecks(){

        if(this.selectedservicepoint != undefined){
            if(Object.keys(this.allSubmitedFields).length != 0){
                for (var key in this.allSubmitedFields) {
                    this.servicePointRetrievedData[key] = this.allSubmitedFields[key];
                }
            }
            this.allSubmitedFields = this.servicePointRetrievedData;
        } else {
            this.allSubmitedFields.RecordTypeId = this.recordtype.value;
            this.allSubmitedFields.Account__c = this.accountid;
            this.allSubmitedFields.Name = this.servicePointCode;
        }

        if(this.submitedAddressFields != undefined){
            for (let [key, value] of Object.entries(this.submitedAddressFields)) {
                this.allSubmitedFields[key] = value;
            }
        }

        for(var i=0; i<this.fieldsDataReq.length; i++){
            
            let reqdata = this.allSubmitedFields[this.fieldsDataReq[i]];

            // if( reqdata == undefined || reqdata == '' ){
            //     this.validForm = false;
            //     this.fieldsDataWithError.push(this.fieldsDataReq[i]);
            // }
        }

        for(var i=0; i<this.fieldsAddressReq.length; i++){
            
            let reqaddr = this.allSubmitedFields[this.fieldsAddressReq[i]];

            // if( reqaddr == undefined || reqaddr == '' ){
            //     this.validForm = false;
            //     this.fieldsAddressWithError.push(this.fieldsAddressReq[i]);
            // }
        }
    }

    /**
     * Handle new record creation
     */
    save(){

        this.validationChecks();

        if (this.validForm) {

            this.loading = true;

            if(this.selectedservicepoint != undefined){
                this.confirm();
            } else {
                this.create();
            }

        } else {

            this.template.querySelector('c-hdt-target-object-address-fields').checkInvalidFields(this.fieldsAddressWithError);
            
            for(var i=0; i<this.fieldsDataWithError.length; i++){
            
                let dataName = "[data-name='"+this.fieldsDataWithError[i]+"']";
                let dataField = this.template.querySelector(dataName);
                dataField.reportValidity();
            }
            
        }
    }

    /**
     * Get form title
     */
    get formTitle(){
        if(this.selectedservicepoint != undefined){
            return 'Service Point: ' + this.selectedservicepoint['Codice Punto'];
        } else {
            return 'Service Point: ' + this.recordtype.label;
        }
    }

    /**
     * Get save button name
     */
    get saveButtonName(){
        if(this.selectedservicepoint != undefined){
            return 'Conferma';
        } else {
            return 'Salva';
        }
    }

    /**
     * Get verify address for update case
     * @param {*} event 
     */
    handleVerifyAddressOnUpdate(event){
        this.verifyAddressDisabledOnUpdate = event.detail;
    }

    /**
     * Create record
     */
    create(){
        createServicePoint({servicePoint: this.allSubmitedFields}).then(data =>{
            this.loading = false;
            this.closeCreateTargetObjectModal();
            this.servicePointId = data.id;
            this.newServicePoint = data;

            this.dispatchEvent(new CustomEvent('newservicepoint', {detail: this.newServicePoint}));
            this.dispatchEvent(new CustomEvent('confirmservicepoint', {detail: this.newServicePoint}));

            const toastSuccessMessage = new ShowToastEvent({
                title: 'Successo',
                message: 'Service Point creato con successo',
                variant: 'success'
            });
            this.dispatchEvent(toastSuccessMessage);
            
        }).catch(error => {
            this.loading = false;

            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.body.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    /**
     * Confirm record
     */
    confirm(){

        confirmServicePoint({servicePoint: this.allSubmitedFields, sale: this.sale}).then(data =>{
            this.loading = false;
            this.closeCreateTargetObjectModal();
            this.servicePointId = data.id;
            this.newServicePoint = data;

            this.dispatchEvent(new CustomEvent('newservicepoint', {detail: this.newServicePoint}));
            this.dispatchEvent(new CustomEvent('confirmservicepoint', {detail: this.newServicePoint}));
            
        }).catch(error => {
            this.loading = false;

            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.body.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }
}