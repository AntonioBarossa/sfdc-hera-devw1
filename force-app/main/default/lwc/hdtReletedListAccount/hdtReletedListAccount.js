import { LightningElement, track ,api, wire} from 'lwc';

import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import PHONE_PREFIX from '@salesforce/schema/Contact.PhonePrefix__c';
import MOBILEPHONE_PREFIX from '@salesforce/schema/Contact.MobilePhonePrefix__c';
import GENDER from '@salesforce/schema/Contact.Gender__c';
import PROFESSION from '@salesforce/schema/Contact.Profession__c';
import EDUCATIONALQUALIFICATION from '@salesforce/schema/Contact.DegreeOfStudies__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getFromFiscalCode from '@salesforce/apex/HDT_UTL_CheckFiscalCodeTaxNumber.getDataFromFiscalCodeData';

import calculateFiscalCode from '@salesforce/apex/HDT_UTL_CalculateFiscalCode.calculateFiscalCode';
import insertContact from '@salesforce/apex/HDT_LC_ReletedListAccount.insertContact';
import contactList from '@salesforce/apex/HDT_LC_ReletedListAccount.getContList';
// import getRecordTypeAccount from '@salesforce/apex/HDT_LC_ReletedListAccount.getRecordTypeAccount';
import {refreshApex} from '@salesforce/apex';

const columns = [
    { label: 'Nome', fieldName: 'Name' },
    { label: 'Titolo di studio', fieldName: 'DegreeOfStudies__c' },
    { label: 'Cellulare', fieldName: 'Phone', type: 'phone' },
    { label: 'Email', fieldName: 'Email', type: 'email' },
    { label: 'Dettagli' ,type: "button", initialWidth: 150,typeAttributes: {  
        label: 'Dettagli',
        title: 'Dettagli',  
        name:  'Dettagli',  
        value: 'Dettagli',  
        disabled: false,
        variant:'brand-outline',  
    }},
];
/**
 * Wire adapter for values for a picklist field.
 *
 * https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.reference_wire_adapters_picklist_values
 *
 * @param fieldApiName The picklist field's object-qualified API name.
 * @param recordTypeId The record type ID. Pass '012000000000000AAA' for the master record type.
 */
const VAR_RECORDTYPEID='012000000000000AAA';
export default class HdtReletedListAccount  extends NavigationMixin(LightningElement)  {
    @api recordId;
    @api showCompanyOwner = false;
    @track spinner;
    @track errorMessage='';
    @track phonePrefixValue;
    @track phonePrefixOptions;
    @track mobilePhonePrefixValue;
    @track mobilePhonePrefixOptions;
    @api companyDefault;
    @track fiscalCode;
    @api customerMarkingOptions = [];
    @api categoryOptions = [];
    @api customerData = [];
    @api categoryData = [];
    @api markingValue;
    @api categoryValue;
    disabled=false;
    currentObjectApiName = 'Account';
    settlementRegion;
    settlementDistrict;
    settlementMunicipality;
    settlementLocation;
    settlementAddress;
    settlementHouseNumber;
    settlementScale;
    settlementFloor;
    settlementIntern;
    settlementPostalCode;
    gender;
    birthDate;
    birthPlace;
    accountAddress;
    fieldsToUpdate= {};
    isVerified= false;
    showModal=false;
    error;
    columns = columns;
    contacts;
    recordType;
    
    buttonNew(){
        console.log('recordId :'+this.recordId);
        this.showModal=true;
        this.disabled=false;
    }
    closeModal() {
        this.showModal = false;
    }
    
    
    handleRowActions(event) {
        
        let row = event.detail.row;
        console.log(JSON.stringify('row '+ row.Id));
        this.openCurrentRecord(row.Id);
    }
    
    openCurrentRecord(currentRowId) {
        console.log('openCurrentRecord');
        
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: currentRowId,
                objectApiName: 'Contact', // objectApiName is optional
                actionName: 'view'
            }
        });
    }
    
    @wire(getPicklistValues, { recordTypeId: VAR_RECORDTYPEID ,fieldApiName: PHONE_PREFIX })
    phonePrefixGetOptions({error, data}) {
        if (data) {
            if(data.defaultValue !=null){
                this.phonePrefixValue = data.defaultValue.value;
                this.phonePrefixOptions= data.values;
            }
        }
    };
    @wire(getPicklistValues, { recordTypeId: VAR_RECORDTYPEID ,fieldApiName: MOBILEPHONE_PREFIX })
    mobilePhonePrefixGetOptions({error, data}) {
        if (data) {
            if(data.defaultValue !=null){
                this.mobilePhonePrefixValue = data.defaultValue.value;
                this.mobilePhonePrefixOptions= data.values;
            }
        }
    };
    
    
    
    @wire(getPicklistValues, { recordTypeId: VAR_RECORDTYPEID ,fieldApiName: GENDER })
    genderOptions;
    
    @wire(getPicklistValues, { recordTypeId: VAR_RECORDTYPEID ,fieldApiName: PROFESSION })
    professionOptions;
    
    @wire(getPicklistValues, { recordTypeId: VAR_RECORDTYPEID ,fieldApiName: EDUCATIONALQUALIFICATION })
    educationalOptions;
    
    
    roleOptions=[
        { label: 'Titolare', value: 'Titolare' },
        { label: 'Familiare', value: 'Familiare' }
    ];
    handleCompanyOwnerChange(event) {
        console.log("***************CHANGE" + event.target.value);
        let key = this.customerData.controllerValues[event.target.value];
        this.customerMarkingOptions = this.customerData.values.filter(opt => opt.validFor.includes(key));
        this.markingValue = '';
        this.categoryValue = '';
    }
    handleCustomerChange(event) {
        let key = this.categoryData.controllerValues[event.target.value];
        this.categoryOptions = this.categoryData.values.filter(opt => opt.validFor.includes(key));
        this.categoryValue = '';
    }
    
    connectedCallback(){
        this.currentObjectApiName= 'Account';
        // this.getCurrentRecordType();
        this.getAllContact();
    }
    
    
    
    getAllContact(){
        contactList({ accountId: this.recordId } )
        .then(result => {
            console.log(JSON.stringify('result '+result));
            
            this.contacts = result;
        })
        .catch(error => {
            this.error = error;
        });
        return refreshApex(this.refreshTable);
        
        
    }
    // getCurrentRecordType(){
    //     getRecordTypeAccount({ accountId: this.recordId } )
    //     .then(result => {            
    //         this.recordType = result;
    //     })
    //     .catch(error => {
    //         this.error = error;
    //     });
    
    
    // }
    
    handleCalculation(){
        
        var isValidated= true;
        let firstName =this.template.querySelector('[data-id="firstName"]').value;
        let lastName= this.template.querySelector('[data-id="lastName"]').value;
        this.gender=this.template.querySelector('[data-id="gender"]').value;
        this.birthDate=this.template.querySelector('[data-id="birthDate"]').value;
        this.fiscalCode= this.template.querySelector('[data-id="fiscalCode"]');
        this.birthPlace=this.template.querySelector('[data-id="birthPlace"]').value;
        
        if(firstName=== undefined || firstName.trim()===''){
            isValidated= false;
        }
        if(lastName=== undefined || lastName.trim()===''){
            isValidated= false;
        }
        if(this.gender=== undefined || this.gender.trim()===''){
            isValidated= false;
        }
        if(this.birthDate=== undefined || this.birthDate.trim()===''){
            isValidated= false;
        }
        if(this.birthPlace=== undefined || this.birthPlace.trim()===''){
            isValidated= false;
        }
        if(isValidated){
            var information={
                firstName:firstName, 
                lastName:lastName, 
                gender: this.gender, 
                birthDate: this.birthDate, 
                birthPlace: this.birthPlace
            };
            calculateFiscalCode({infoData: information}).then((response) => {
                if(response == null){
                    const event = new onMyTost({
                        message: 'Comune inserito NON presente a sistema',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                }else{
                    this.fiscalCode.value= response;
                }
            }).catch((errorMsg) => { 
                this.showError(errorMsg);
                const event = new onMyTost({
                    message: this.errorMessage,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
            });            
        }else{
            const event = new onMyTost({
                message: 'Inserire le Informazioni Mancanti',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
        }
    }
    getAccountAdress(){
        
        if(this.accountAddress!= undefined){
            
            if(this.accountAddress['Via'] != null){
                this.fieldsToUpdate['BillingStreet'] = this.accountAddress['Via'];
                this.fieldsToUpdate['BillingStreetName__c'] = this.accountAddress['Via'];
            }
            if(this.accountAddress['Comune'] != null){
                this.fieldsToUpdate['BillingCity'] = this.accountAddress['Comune'];
            }
            if(this.accountAddress['CAP'] != null){
                this.fieldsToUpdate['BillingPostalCode'] = this.accountAddress['CAP'];
            }
            if(this.accountAddress['Stato'] != null){
                this.fieldsToUpdate['BillingCountry'] = this.accountAddress['Stato'];
            }
            if(this.accountAddress['Provincia'] != null){
                this.fieldsToUpdate['BillingState'] = this.accountAddress['Provincia'];
            }
            if(this.accountAddress['Codice Comune SAP'] != null){
                this.fieldsToUpdate['BillingCityCode__c'] = this.accountAddress['Codice Comune SAP'];
            }
            if(this.accountAddress['Codice Via Stradario SAP'] != null){
                this.fieldsToUpdate['BillingStreetCode__c'] = this.accountAddress['Codice Via Stradario SAP'];
            }
            if(this.accountAddress['Estens.Civico'] != null){
                this.fieldsToUpdate['BillingStreetNumberExtension__c'] = this.accountAddress['Estens.Civico'];
            }
            if(this.accountAddress['Civico'] != null){
                this.fieldsToUpdate['BillingStreetNumber__c'] = this.accountAddress['Civico'];
            }
            if(this.accountAddress['Localita'] != null){
                this.fieldsToUpdate['BillingPlace__c'] = this.accountAddress['Localita'];
            }
            if(this.accountAddress['Codice Localita'] != null){
                this.fieldsToUpdate['BillingPlaceCode__c'] = this.accountAddress['Codice Localita'];
            }
            if(this.accountAddress['Flag Verificato'] !=null){
                this.fieldsToUpdate['BillingIsAddressVerified__c'] = this.accountAddress['Flag Verificato'];
                this.isVerified = this.accountAddress['Flag Verificato'];
            }
        }
    }
    
    handleSave(){
        console.log('record id : '+ this.recordId);
        this.disabled=true;
        var isValidated=true;
        this.spinner=true;
        let firstName=this.template.querySelector('[data-id="firstName"]');
        let lastName=this.template.querySelector('[data-id="lastName"]');
        this.fiscalCode=this.template.querySelector('[data-id="fiscalCode"]');
        let phonePrefix=this.template.querySelector('[data-id="phonePrefix"]');
        let mobilePhonePrefix=this.template.querySelector('[data-id="mobilePhonePrefix"]');
        let role=this.template.querySelector('[data-id="role"]');
        let mobilePhone=this.template.querySelector('[data-id="mobilePhone"]');
        let email=this.template.querySelector('[data-id="email"]');
        let phoneNumber=this.template.querySelector('[data-id="phoneNumber"]');
        let education=this.template.querySelector('[data-id="education"]');  
        let profession= this.template.querySelector('[data-id="profession"]');   
        this.gender=this.template.querySelector('[data-id="gender"]').value;
        this.birthDate=this.template.querySelector('[data-id="birthDate"]').value;
        this.birthPlace=this.template.querySelector('[data-id="birthPlace"]').value;
        
        let messageError= "Completare tutti i campi obbligatori !";
        var mailFormat = /^(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])$/;
        if((mobilePhone.value=== undefined || mobilePhone.value.trim()==='') && (email.value=== undefined || email.value.trim()==='')
        && (phoneNumber.value=== undefined || phoneNumber.value.trim()==='')){
            if(isValidated){
                messageError=" Almeno un dato di contatto è obbligatorio!";
            }
            isValidated=false;
        }
        if(!(mobilePhone.value=== undefined || mobilePhone.value.trim()==='')){
            if(mobilePhone.value.length<9 || mobilePhone.value.length > 12){
                isValidated=false;
                messageError=" Il numero di cellulare deve essere compreso tra le 9 e le 12 cifre!";
            }
        }
        console.log('LENGTH:'+ this.fiscalcode + '-:' + this.fiscalCode.value.length);
        if(!(this.fiscalCode.value=== undefined || this.fiscalCode.value.trim()==='')){
            if(this.fiscalCode.value.length != 16){
                isValidated=false;
                messageError=" Il Codice fiscale deve essere lungo 16 cifre!";
            }
        }
        
        if(!(mobilePhone.value=== undefined || mobilePhone.value.trim()==='')){
            if(mobilePhone.value.length<9 || mobilePhone.value.length > 12){
                isValidated=false;
                messageError=" Il numero di cellulare deve essere compreso tra le 9 e le 12 cifre!";
            }
        }
        if(!(phoneNumber.value=== undefined || phoneNumber.value.trim()==='')){
            if(phoneNumber[0] != '0' && (phoneNumber.value.length<6 || phoneNumber.value.length > 11)){
                isValidated=false;
                messageError=" Il numero di telefono deve essere compreso tra le 6 e le 11 cifre ed iniziare per 0!";
            }
        }
        if(!(email.value=== undefined || email.value.trim()==='')){
            if(!mailFormat.test(email.value)){
                isValidated=false;
                messageError=" Formato email errato !";
            }
        }
        if(isValidated){
            console.log('validato');
            this.accountAddress =this.template.querySelector("c-hdt-target-object-address-fields").handleAddressFields();
            this.getAccountAdress();
            if(this.isVerified){
                console.log('è verificato');
                var isEmpty=false;
                if(this.gender === undefined || this.gender.trim()===''){
                    isEmpty= true;
                }
                if(this.birthDate === undefined || this.birthDate.trim()===''){
                    isEmpty= true;
                }
                if(this.birthPlace === undefined || this.birthPlace.trim()===''){
                    isEmpty= true;
                }
                console.log('isEmpty '+isEmpty);
                if(isEmpty){
                    getFromFiscalCode({
                        fiscalCodes : this.fiscalCode.value.replace(/ /g,"") }).then((response) => {
                            var fiscData= response;
                            console.log('fiscData ' +JSON.stringify(fiscData));
                            console.log('fiscalCode ' + this.fiscalCode.value);
                            var keyCode= this.fiscalCode.value;
                            console.log('fiscData[keyCode].gender' + fiscData[keyCode].gender);
                            if(!this.gender  || this.gender.trim()==='' ){
                                this.gender=fiscData[keyCode].gender;
                                console.log('gender : ' + this.gender);
                                //this.gender= fiscData.gender;
                            }
                            if(!this.birthDate || this.birthDate.trim()===''){
                                this.birthDate=fiscData[keyCode].birthDate;
                                console.log('birthDate : ' + this.birthDate);
                                
                                //this.birthDate= fiscData.birthDate;
                            }
                            if(!this.birthPlace || this.birthPlace.trim()===''){
                                this.birthPlace=fiscData[keyCode].birthPlace;
                                console.log('birthPlace : ' + this.birthPlace);
                                
                                //this.birthPlace= fiscData.birthPlace;
                            }
                            
                            let acc= {
                                "firstName": firstName.value,
                                "lastName": lastName.value,
                                "fiscalCode": this.fiscalCode.value.replace(/ /g,""),
                                "phoneNumber": phoneNumber.value,
                                "mobilePhone" : mobilePhone.value,
                                "name": firstName.value+' '+lastName.value,
                                "email": email.value,
                                "accountId" : this.recordId,
                                "birthplace": this.birthPlace,
                                "gender" : this.gender,
                                "education" : education.value,
                                "profession" : profession.value,
                                "role" : role.value,
                                "birthDate" : this.birthDate,
                                "phonePrefix" : phonePrefix.value ,
                                "mobilePhonePrefix" : mobilePhonePrefix.value,
                            }
                            console.log('acc : '+ acc);
                            
                            insertContact({
                                dataContact : acc,
                                contactAddress: this.fieldsToUpdate
                            }).then((response) => {
                                console.log(JSON.stringify(response));
                                const event = new ShowToastEvent({
                                    message: 'Contact  has been created!',
                                    variant: 'success',
                                    mode: 'dismissable'
                                });
                                this.dispatchEvent(event);
                                this.showModal= false;
                                this.dispatchEvent(event);
                                this.showModal= false;
                                this[NavigationMixin.Navigate]({
                                    type: 'standard__recordPage',
                                    attributes: {
                                        recordId: response.Id,
                                        objectApiName: 'Contact',
                                        actionName: 'view'
                                    }
                                });
                                
                            }).catch((errorMsg) => {
                                this.showError(errorMsg);
                                const event = new ShowToastEvent({
                                    message: this.errorMessage,
                                    variant: 'error',
                                    mode: 'dismissable'
                                });
                                this.dispatchEvent(event);
                                this.spinner=false;
                            });
                        }).catch((errorMsg) => {
                            const event = new ShowToastEvent({
                                message: 'Entra un valido codice fiscale!',
                                variant: 'error',
                                mode: 'dismissable'
                            });
                            this.dispatchEvent(event);
                            this.spinner=false;
                        });
                        
                    }
                    else{
                        console.log('è else');
                        let acc= {
                            "firstName": firstName.value,
                            "lastName": lastName.value,
                            "fiscalCode": this.fiscalCode.value.replace(/ /g,""),
                            "phoneNumber": phoneNumber.value,
                            "mobilePhone" : mobilePhone.value,
                            "name": firstName.value+' '+lastName.value,
                            "email": email.value,
                            "accountId" : this.recordId,
                            "birthplace": this.birthPlace,
                            "gender" : this.gender,
                            "education" : education.value,
                            "profession" : profession.value,
                            "role" : role.value,
                            "birthDate" : this.birthDate,
                            "phonePrefix" : phonePrefix.value ,
                            "mobilePhonePrefix" : mobilePhonePrefix.value,
                        }
                        console.log('acc : '+ acc);
                        insertContact({
                            dataContact : acc,
                            contactAddress: this.fieldsToUpdate
                        }).then((response) => {
                            console.log(JSON.stringify(response));
                            const event = new ShowToastEvent({
                                message: 'Contact  has been created!',
                                variant: 'success',
                                mode: 'dismissable'
                            });
                            this.dispatchEvent(event);
                            this.showModal= false;
                            this.dispatchEvent(event);
                            this.showModal= false;
                            this[NavigationMixin.Navigate]({
                                type: 'standard__recordPage',
                                attributes: {
                                    recordId: response.Id,
                                    objectApiName: 'Contact',
                                    actionName: 'view'
                                }
                            });
                            
                        }).catch((errorMsg) => {
                            this.showError(errorMsg);
                            const event = new ShowToastEvent({
                                message: this.errorMessage,
                                variant: 'error',
                                mode: 'dismissable'
                            });
                            this.dispatchEvent(event);
                            this.spinner=false;
                        });
                    }
                }
                else{
                    const event = new ShowToastEvent({
                        message: " L\'indirizzo non è stato verificato! ",
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                    this.spinner=false;
                }
                
            }
            else{
                const event = new ShowToastEvent({
                    message: messageError,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
                this.spinner=false;
            }
            
            
            
            
            
            
        }
        
        copyAddressHandler(event){
            let checkboxSelected= event.target.checked;
            if(checkboxSelected){
                
                let residenceRegion =this.template.querySelector('[data-id="residenceRegion"]');
                let residenceDistrict= this.template.querySelector('[data-id="residenceDistrict"]');
                let residenceMunicipality= this.template.querySelector('[data-id="residenceMunicipality"]');
                let residenceLocation= this.template.querySelector('[data-id="residenceLocation"]');
                let residenceAddress= this.template.querySelector('[data-id="residenceAddress"]');
                let residenceHouseNumber= this.template.querySelector('[data-id="residenceHouseNumber"]');
                let residenceScale= this.template.querySelector('[data-id="residenceScale"]');
                let residenceFloor= this.template.querySelector('[data-id="residenceFloor"]');
                let residenceIntern= this.template.querySelector('[data-id="residenceIntern"]');
                let residencePostalCode= this.template.querySelector('[data-id="residencePostalCode"]');
                this.settlementRegion= residenceRegion.value;
                this.settlementDistrict= residenceDistrict.value;
                this.settlementMunicipality= residenceMunicipality.value;
                this.settlementLocation= residenceLocation.value;
                this.settlementAddress= residenceAddress.value;
                this.settlementHouseNumber= residenceHouseNumber.value;
                this.settlementScale= residenceScale.value;
                this.settlementFloor= residenceFloor.value;
                this.settlementIntern= residenceIntern.value;
                this.settlementPostalCode= residencePostalCode.value;
            }
            
        }
        
        showError(error){
            this.errorMessage='';
            if(error.body.message){
                this.errorMessage= this.errorMessage+ ' '+ error.body.message;
            }else if(error.body.pageErrors){
                if(error.body.pageErrors.length>0){
                    for(var i=0;i <error.body.pageErrors.length;i++){
                        this.errorMessage= this.errorMessage+ ' '+ error.body.pageErrors[i].message;
                    }
                }
            }
            
        }
        
        
    }