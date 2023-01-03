import { LightningElement, track ,api, wire} from 'lwc';

import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CONTACT_OBJECT from '@salesforce/schema/Contact';

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
import getRecordTypeAccount from '@salesforce/apex/HDT_LC_ReletedListAccount.getRecordTypeAccount';
import {refreshApex} from '@salesforce/apex';


const ERROR_VARIANT='error';
const SUCCESS_VARIANT='success';
const DISMISSABLE_VARIANT='dismissable';
export default class HdtReletedListAccount  extends NavigationMixin(LightningElement)  {
    @api recordId;
    @track numberOfContacts=0;
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
    disableToggleContactDetails=false;
    addressContactDetails = false;
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
   // columns = columns;
    contacts;
    recordType;
    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    contactInfo;

    buttonNew(){
        console.log('recordId :'+this.recordId);
        this.showModal=true;
        this.disabled=false;
    }
    closeModal() {
        this.showModal = false;
    }
    toastMessage(myMessage,myVariant,myDismissable){
        const event = new ShowToastEvent({
            message:myMessage,
            variant: myVariant,
            mode: myDismissable
        });
        this.dispatchEvent(event);
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
    //HRAWRM-853 Start 12/10/2021
    handleToggleContactDetails(event){
        this.addressContactDetails=event.target.checked;;
        if (!this.addressContactDetails) {
            this.isVerified=true;
        }
        else{
            this.isVerified=false;
        }

    }    //HRAWRM-853 End 12/10/2021
    handleChangeRole(event){ 
        let currentRole=event.target.value;
        let toggleContact= this.template.querySelector('[data-id="toggleContactDetails"]');
        let requiredToggle=currentRole==='Amministratore condominio'?true:false;
        this.addressContactDetails=requiredToggle;
        this.disableToggleContactDetails=requiredToggle;
        toggleContact.checked=requiredToggle;
        this.isVerified=this.addressContactDetails==true?false:true;
    }
    @wire(getPicklistValues, { recordTypeId: '$contactInfo.data.defaultRecordTypeId' ,fieldApiName: PHONE_PREFIX })
    phonePrefixGetOptions({error, data}) {
        if (data) {
            if(data.defaultValue !=null){
                this.phonePrefixValue = data.defaultValue.value;
                this.phonePrefixOptions= data.values;
            }
        }
    };
    @wire(getPicklistValues, { recordTypeId: '$contactInfo.data.defaultRecordTypeId' ,fieldApiName: MOBILEPHONE_PREFIX })
    mobilePhonePrefixGetOptions({error, data}) {
        if (data) {
            if(data.defaultValue !=null){
                this.mobilePhonePrefixValue = data.defaultValue.value;
                this.mobilePhonePrefixOptions= data.values;
            }
        }
    };
    
    
    
    @wire(getPicklistValues, { recordTypeId: '$contactInfo.data.defaultRecordTypeId' ,fieldApiName: GENDER })
    genderOptions;
    
    @wire(getPicklistValues, { recordTypeId: '$contactInfo.data.defaultRecordTypeId' ,fieldApiName: PROFESSION })
    professionOptions;
    
    @wire(getPicklistValues, { recordTypeId: '$contactInfo.data.defaultRecordTypeId' ,fieldApiName: EDUCATIONALQUALIFICATION })
    educationalOptions;
    
    
    @track roleOptions=[];
    roleOptionsBus= [
    { label: 'Titolare', value: 'Titolare' },
    { label: 'Legale rappresentante', value: 'Legale rappresentante' },
    { label: 'Amministratore condominio', value: 'Amministratore condominio' },
    { label: 'Dipendente azienda/collaboratore', value: 'Dipendente azienda/collaboratore' }];
    roleOptionsRes= [
        { label: 'Titolare', value: 'Titolare' },
        { label: 'Familiare', value: 'Familiare' },
    ];


    handleCompanyOwnerChange(event) {
        console.log("handleCompanyOwnerChange : " + event.target.value);
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
        this.getAllContact();
        this.getRoleByRecordType();
    }
    
    
    getRoleByRecordType(){
        getRecordTypeAccount({ accountId: this.recordId } )
        .then(result => {
            console.log(JSON.stringify('result '+result));
            if (result==='HDT_RT_Business') {
               this.roleOptions=this.roleOptionsBus;
            }
            else if(result==='HDT_RT_Residenziale'){
                this.roleOptions=this.roleOptionsRes;
            }
          
        })
        .catch(error => {
            this.error = error;
        });
    }
    getAllContact(){
        contactList({ accountId: this.recordId } )
        .then(result => {
            this.contacts =JSON.parse(result);  //HRAWRM-500 Start 04/10/2021
            this.numberOfContacts=this.contacts.length;
        })
        .catch(error => {
            this.error = error;
        });
        return refreshApex(this.refreshTable);
        
        
    }

    
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
                    this.toastMessage('Comune inserito non presente a sistema',ERROR_VARIANT,DISMISSABLE_VARIANT);
                }
                else{
                    this.fiscalCode.value= response;
                }
            }).catch((errorMsg) => { 
                this.showError(errorMsg);
                this.toastMessage(this.errorMessage,ERROR_VARIANT,DISMISSABLE_VARIANT);
            });            
        }
        else{
 
            this.toastMessage('Inserire le Informazioni Mancanti',ERROR_VARIANT,DISMISSABLE_VARIANT);
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
        var mailFormat = /^(?:[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?\.)+[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[A-Za-z0-9-]*[A-Za-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])$/;
        if((mobilePhone.value=== undefined || mobilePhone.value.trim()==='') && (email.value=== undefined || email.value.trim()==='')
        && (phoneNumber.value=== undefined || phoneNumber.value.trim()==='')){
            if(isValidated){
                messageError=" Almeno un dato di contatto è obbligatorio!";
            }
            isValidated=false;
        }
        if(!(mobilePhone.value=== undefined || mobilePhone.value.trim()==='')){
            if(mobilePhonePrefix.value == '+39'){
                if(mobilePhone.value[0] != '3' || mobilePhone.value.length<9 || mobilePhone.value.length > 12){
                    isValidated=false;
                    messageError=" Il numero di cellulare deve essere compreso tra le 9 e le 12 cifre ed iniziare per 3!";
                }
            }
        }
        if(!(this.fiscalCode.value=== undefined || this.fiscalCode.value.trim()==='')){
            if(this.fiscalCode.value.length != 16){
                isValidated=false;
                messageError=" Il Codice fiscale deve essere lungo 16 cifre!";
            }
        }
        if(!(phoneNumber.value=== undefined || phoneNumber.value.trim()==='')){
            if(phoneNumber.value[0] != '0' || phoneNumber.value.length<6 || phoneNumber.value.length > 11){
                isValidated=false;
                messageError=" Il numero di telefono fisso deve essere compreso tra le 6 e le 11 cifre ed iniziare per 0!";
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
            //HRAWRM-853 Start 12/10/2021

            if (this.addressContactDetails) {
                this.accountAddress =this.template.querySelector("c-hdt-target-object-address-fields").handleAddressFields();
                this.getAccountAdress();  
            }
            //HRAWRM-853 End 12/10/2021
            if(this.isVerified ){
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
                            }
                            if(!this.birthDate || this.birthDate.trim()===''){
                                this.birthDate=fiscData[keyCode].birthDate;
                                console.log('birthDate : ' + this.birthDate);
                            }
                            if(!this.birthPlace || this.birthPlace.trim()===''){
                                this.birthPlace=fiscData[keyCode].birthPlace;
                                console.log('birthPlace : ' + this.birthPlace);
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
                                this.toastMessage('Referente creato con successo!',SUCCESS_VARIANT,DISMISSABLE_VARIANT);
                                this.showModal= false;
                      
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
                                this. toastMessage(this.errorMessage,ERROR_VARIANT,DISMISSABLE_VARIANT);
                                this.spinner=false;
                            });
                        }).catch((errorMsg) => {
                            this.toastMessage('Inserire un codice fiscale valido',ERROR_VARIANT,DISMISSABLE_VARIANT);
                            this.spinner=false;
                        });
                        
                    }
                    else{
                        getFromFiscalCode({
                            fiscalCodes : this.fiscalCode.value.replace(/ /g,"") }).then((response) => {
           
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
                            this.toastMessage('Referente creato con successo!',SUCCESS_VARIANT,DISMISSABLE_VARIANT);
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
                            this.toastMessage(this.errorMessage,ERROR_VARIANT,DISMISSABLE_VARIANT);
                            this.spinner=false;
                        });
                    }).catch((errorMsg) => {
                        this.toastMessage('Inserire un codice fiscale valido',ERROR_VARIANT,DISMISSABLE_VARIANT);
                        this.spinner=false;
                    });
                    }
                }
                else{
                    this.toastMessage("L\'indirizzo non è stato verificato! ",ERROR_VARIANT,DISMISSABLE_VARIANT);
                    this.spinner=false;
                }
                
            }
            else{
                this.toastMessage(messageError,ERROR_VARIANT,DISMISSABLE_VARIANT);
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