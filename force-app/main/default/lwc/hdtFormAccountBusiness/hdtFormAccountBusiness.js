import { LightningElement,track, api, wire} from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import CUSTOM_MARKING from '@salesforce/schema/Account.CustomerMarking__c';
import CATEGORY from '@salesforce/schema/Account.Category__c';
import PHONE_PREFIX from '@salesforce/schema/Account.PhonePrefix__c';
import MOBILEPHONE_PREFIX from '@salesforce/schema/Account.MobilePhonePrefix__c';
import GENDER from '@salesforce/schema/Account.Gender__c';
import PROFESSION from '@salesforce/schema/Account.Profession__c';
import EDUCATIONAL_QUALIFICATION from '@salesforce/schema/Account.DegreeOfStudies__c';
import LEGAL_FORM_TYPE from '@salesforce/schema/Account.LegalFormType__c';
import COMPANY_OWNER from '@salesforce/schema/Account.CompanyOwner__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getFromFiscalCode from '@salesforce/apex/HDT_UTL_CheckFiscalCodeTaxNumber.getDataFromFiscalCode';
import calculateFiscalCode from '@salesforce/apex/HDT_UTL_CalculateFiscalCode.calculateFiscalCode';
import insertAccount from '@salesforce/apex/HDT_LC_FormAccountBusiness.insertAccount';

export default class HdtFormAccountBusiness extends NavigationMixin(LightningElement) {

    @track showModal= true;
    @track spinner= false;
    @track markingValue;
    @track categoryValue;
    @track errorMessage='';
    @track phonePrefixValue;
    @track phonePrefixOptions;
    @track mobilePhonePrefixValue;
    @track mobilePhonePrefixOptions;
    @track makerequired= false;
    @track personFiscalCode;
    @track mobilephonePrefix2 = '+39';
    @track phonePrefixValue2 = '+39';

    gender;
    birthDate;
    birthPlace;
    currentObjectApiName = 'Account';
    accountAddress;
    fieldsToUpdate= {};
    isVerified= false;
    @api RecordTypeId;

    @wire(getPicklistValues, {recordTypeId: '$RecordTypeId' ,fieldApiName: PHONE_PREFIX })
    phonePrefixGetOptions({error, data}) {
        if (data) {
          if(data.defaultValue !=null){
            this.phonePrefixValue = data.defaultValue.value;
            this.phonePrefixOptions= data.values;
          }
        }
    };
    @wire(getPicklistValues, {recordTypeId: '$RecordTypeId' ,fieldApiName: MOBILEPHONE_PREFIX })
    mobilePhonePrefixGetOptions({error, data}) {
        if (data) {
          if(data.defaultValue !=null){
            this.mobilePhonePrefixValue = data.defaultValue.value;
            this.mobilePhonePrefixOptions= data.values;
          }
        }
    };

    @wire(getPicklistValues, {recordTypeId: '$RecordTypeId' ,fieldApiName: CUSTOM_MARKING })
    customerMarkingOptions;

    @wire(getPicklistValues, {recordTypeId: '$RecordTypeId' ,fieldApiName: CATEGORY })
    categoryOptions;

    @wire(getPicklistValues, {recordTypeId: '$RecordTypeId' ,fieldApiName: GENDER })
    genderOptions;

    @wire(getPicklistValues, {recordTypeId: '$RecordTypeId' ,fieldApiName: PROFESSION })
    professionOptions;

    @wire(getPicklistValues, {recordTypeId: '$RecordTypeId' ,fieldApiName: EDUCATIONAL_QUALIFICATION })
    educationalOptions;

    @wire(getPicklistValues, {recordTypeId: '$RecordTypeId' ,fieldApiName: LEGAL_FORM_TYPE })
    legalFormOptions;
    
    @wire(getPicklistValues, {recordTypeId: '$RecordTypeId' ,fieldApiName: COMPANY_OWNER })
    companyOwnerOptions;

    get ruoloOptions() {
        return [
            { label: 'Titolare', value: 'Titolare' },
            { label: 'Legale rappresentante', value: 'Legale rappresentante' },
            { label: 'Amministratore condominio', value: 'Amministratore condominio' },
            { label: 'Dipendente azienda/collaboratore', value: 'Dipendente azienda/collaboratore' },
            { label: 'Contatto secondario', value: 'Contatto secondario' },
            { label: 'Delegato', value: 'Delegato' },
            { label: 'Azienda', value: 'Azienda' }
            
        ];
    }
    closeModal() {
        this.showModal = false;
        window.history.back();
    }

    connectedCallback(){
        this.currentObjectApiName= 'Account';
    }

    handleChange(event){
        this.markingValue= event.detail.value;
        if(this.markingValue=='Ditta individuale'){
            this.template.querySelector('[data-id="showDiv"]').classList.add('slds-show');
            this.template.querySelector('[data-id="showDiv"]').classList.remove('slds-hide');
            this.template.querySelector('[data-id="hideBusinessName"]').classList.add('slds-hide');
            this.template.querySelector('[data-id="hideBusinessName"]').classList.remove('slds-show');
            this.makerequired= true;
        }else{
            this.template.querySelector('[data-id="showDiv"]').classList.add('slds-hide');
            this.template.querySelector('[data-id="showDiv"]').classList.remove('slds-show');
            this.template.querySelector('[data-id="hideBusinessName"]').classList.add('slds-show');
            this.template.querySelector('[data-id="hideBusinessName"]').classList.remove('slds-hide');
            this.makerequired= false;
            this.template.querySelector('[data-id="fiscalCode"]').classList.remove('slds-has-error');
        }
   }

    handleCalculation(){

        var isValidated= true;
        let firstName =this.template.querySelector('[data-id="firstName"]').value;
        let lastName= this.template.querySelector('[data-id="lastName"]').value;
        this.gender=this.template.querySelector('[data-id="gender"]').value;
        this.birthDate=this.template.querySelector('[data-id="birthDate"]').value;
        this.personFiscalCode= this.template.querySelector('[data-id="personFiscalCode"]');
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

                this.personFiscalCode.value= response;
                this.spinner=false;
            }).catch((errorMsg) => {
                this.showError(errorMsg);
                const event = new ShowToastEvent({
                    message: this.errorMessage,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
            });   
        }else{
            const event = new ShowToastEvent({
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
            if(this.accountAddress['Flag Verificato'] !=null){
                this.isVerified = this.accountAddress['Flag Verificato'];
            }
        }
    }

    handleSave(){

        let isValidated= true;
        let businessName =this.template.querySelector('[data-id="businessName"]');
        let vatNumber =this.template.querySelector('[data-id="vatNumber"]');
        this.personFiscalCode= this.template.querySelector('[data-id="personFiscalCode"]');
        let prefixPhoneNumber = this.phonePrefixValue2;
        let phoneNumber= this.template.querySelector('[data-id="phoneNumber"]');
        let prefixMobilePhoneNumber = this.mobilephonePrefix2;
        let mobilephoneNumber= this.template.querySelector('[data-id="mobilePhoneNumber"]');
        let contactPhoneNumber =this.template.querySelector('[data-id="contactPhoneNumber"]');
        let customerMarking =this.template.querySelector('[data-id="customerMarking"]');
        let category= this.template.querySelector('[data-id="category"]');
        let fiscalCode= this.template.querySelector('[data-id="fiscalCode"]');
        let email= this.template.querySelector('[data-id="email"]');
        let electronicMail= this.template.querySelector('[data-id="electronicMail"]');
        let companyOwner= this.template.querySelector('[data-id="companyOwner"]');
        let phonePrefix= this.template.querySelector('[data-id="phonePrefix"]');
        let mobilePhonePrefix= this.template.querySelector('[data-id="mobilePhonePrefix"]');
        // let address =this.template.querySelector('[data-id="address"]');
        // let location =this.template.querySelector('[data-id="location"]');
        // let myAddress =this.template.querySelector('[data-id="myAddress"]');
        let numberFax =this.template.querySelector('[data-id="numberFax"]');
        // let houseNumber =this.template.querySelector('[data-id="houseNumber"]');
        // let postalCode =this.template.querySelector('[data-id="postalCode"]');
        let firstName =this.template.querySelector('[data-id="firstName"]');
        let lastName= this.template.querySelector('[data-id="lastName"]');
        let mobilePhone= this.template.querySelector('[data-id="mobilePhone"]');
        let contactEmail= this.template.querySelector('[data-id="contactEmail"]');
        let legalForm= this.template.querySelector('[data-id="legalForm"]');
        let role=this.template.querySelector('[data-id="role"]');
        let contactElectronicMail= this.template.querySelector('[data-id="contactElectronicMail"]');
        let contactFax= this.template.querySelector('[data-id="contactFax"]');
        //let otherPhone= this.template.querySelector('[data-id="otherPhone"]');
        let firstIndividualName= this.template.querySelector('[data-id="firstIndividualName"]');
        let lastIndividualName= this.template.querySelector('[data-id="lastIndividualName"]');
        let education=this.template.querySelector('[data-id="education"]');  
        let profession= this.template.querySelector('[data-id="profession"]'); 
        this.gender=this.template.querySelector('[data-id="gender"]').value;
        this.birthDate=this.template.querySelector('[data-id="birthDate"]').value;
        this.birthPlace= this.template.querySelector('[data-id="birthPlace"]').value;
        this.spinner= true;
        let messageError= "Completare tutti i campi obbligatori !";
        var mailFormat = /^(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])$/;
        let dataAccount;
        if(this.markingValue === undefined || !this.markingValue=='AAS Ditta individuale'){
            if(!businessName.reportValidity()){
                isValidated=false;
            } 
        }
        if(!vatNumber.reportValidity()){
            isValidated=false;
        } 
        if(!this.personFiscalCode.reportValidity()){
            isValidated=false;
        }
        if(!category.reportValidity()){
            isValidated=false;
        }
        if(!companyOwner.reportValidity()){
            isValidated=false;
        }
        if(!mobilePhonePrefix.reportValidity()){
            isValidated=false;
        }
        if(!phonePrefix.reportValidity()){
            isValidated=false;
        }
        
        // if(!district.reportValidity()){
        //     isValidated=false;
        // }
        // if(!address.reportValidity()){
        //     isValidated=false;
        // }
        // if(!location.reportValidity()){
        //     isValidated=false;
        // }
        // if(!myAddress.reportValidity()){
        //     isValidated=false;
        // }
        // if(!numberFax.reportValidity()){
        //     isValidated=false;
        // }
        // if(!houseNumber.reportValidity()){
        //     isValidated=false;
        // }
        // if(!postalCode.reportValidity()){
        //     isValidated=false;
        // }
        if(!firstName.reportValidity()){
            isValidated=false;
        } 
        if(!lastName.reportValidity()){
            isValidated=false;
        } 
        if(!legalForm.reportValidity()){
            isValidated=false;
        }
        if(!phoneNumber.reportValidity() && !mobilephoneNumber.reportValidity() && !email.reportValidity()){
            isValidated=false;
        }
        if(!role.reportValidity()){
            isValidated=false;
        }
        if(!customerMarking.reportValidity()){
            isValidated=false;
        }
        if(this.markingValue=='AAS Ditta individuale'){
            if(!lastIndividualName.reportValidity()){
                isValidated=false;
            }

            if(!fiscalCode.reportValidity()){
                isValidated=false;
            }
        }

    
        if(!(mobilePhone.value=== undefined || mobilePhone.value.trim()==='')){
            if(mobilePhone.value.length<9 || mobilePhone.value.length > 12){
                isValidated=false;
                messageError=" Il numero di cellulare deve essere compreso tra le 9 e le 12 cifre!";
            }
        }
        if(!(contactPhoneNumber.value=== undefined || contactPhoneNumber.value.trim()==='')){
            if(contactPhoneNumber[0] != '0' && (contactPhoneNumber.value.length<6 || contactPhoneNumber.value.length > 11)){
                isValidated=false;
                messageError=" Il numero di telefono deve essere compreso tra le 6 e le 11 cifre ed iniziare per 0!";
            }
        }
        if(!(contactEmail.value=== undefined || contactEmail.value.trim()==='')){
            if(!mailFormat.test(contactEmail.value)){
                isValidated=false;
                messageError=" Formato email errato !";
            }
        }
        if(!(phoneNumber.value=== undefined || phoneNumber.value.trim()==='')){
            if(phoneNumber[0] != '0' && (phoneNumber.value.length<6 || phoneNumber.value.length > 11)){
                isValidated=false;
                messageError=" Il numero di telefono deve essere compreso tra le 6 e le 11 cifre ed iniziare per 0!";
            }
        }
        // if(!(otherPhone.value=== undefined || otherPhone.value.trim()==='')){
        //     if(otherPhone.value.length<10){
        //         isValidated=false;
        //         messageError=" Altro telefono non può essere meno di 10 cifre!";
        //     }
        // }
        if(!(electronicMail.value=== undefined || electronicMail.value.trim()==='')){
            if(!mailFormat.test(electronicMail.value)){
                isValidated=false;
                messageError=" Formato pec errato !";
            }
        }
        if((mobilePhone.value=== undefined || mobilePhone.value.trim()==='') && (contactEmail.value=== undefined || contactEmail.value.trim()==='')
        && (contactPhoneNumber.value=== undefined || contactPhoneNumber.value.trim()==='') && (contactElectronicMail.value=== undefined || contactElectronicMail.value.trim()==='') 
        && (contactFax.value=== undefined || contactFax.value.trim()=== '') ){
            if(isValidated){
                messageError=" Almeno un dato di contatto è obbligatorio!";
            }
            isValidated=false;
        }

        if(isValidated){
            this.accountAddress =this.template.querySelector("c-hdt-target-object-address-fields").handleAddressFields();
            this.getAccountAdress();
            if(this.isVerified){
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
                
                if(isEmpty){
                    getFromFiscalCode({
                        fiscalCodes : {'Account' : this.fiscalCode.value.replace(/ /g,"")}
                    }).then((response) => {
                        let fiscData= response.Account;
                        if(this.gender === undefined || this.gender.trim()===''){
                            this.gender= fiscData.gender;
                        }
                        if(this.birthDate === undefined || this.birthDate.trim()===''){
                            this.birthDate= fiscData.birthDate;
                        }
                        if(this.birthPlace === undefined || this.birthPlace.trim()===''){
                            this.birthPlace= fiscData.birthPlace;
                        }
                        dataAccount={
                            "businessName" : businessName.value,
                            "vatNumber" : vatNumber.value,
                            "fiscalCode" : fiscalCode.value.replace(/ /g,""),
                            "legalForm" : legalForm.value,
                            "customerMarking" : customerMarking.value,
                            "category" : category.value,
                            "firstIndividualName" : firstIndividualName.value,
                            "lastIndividualName" : lastIndividualName.value,
                            "prefixPhoneNumber" : prefixPhoneNumber,
                            "prefixMobilePhoneNumber" : prefixMobilePhoneNumber,
                            "mobilephoneNumber" : mobilephoneNumber.value,
                            "phoneNumber" : phoneNumber.value,
                            "email" : email.value,
                            "electronicMail" : electronicMail.value,
                            "numberFax" : numberFax.value,
                            "firstName" : firstName.value,
                            "gender" : this.gender,
                            "lastName" : lastName.value,
                            "birthDate" : this.birthDate,
                            "birthplace": this.birthPlace,
                            "personFiscalCode" : this.personFiscalCode.value.replace(/ /g,""),
                            "role" : role.value,
                            "mobilePhone" : mobilePhone.value,
                            "contactEmail" : contactEmail.value,
                            "contactPhoneNumber" : contactPhoneNumber.value,
                            "contactElectronicMail" : contactElectronicMail.value,
                            "contactFax" : contactFax.value,
                            "education" : education.value,
                            "profession" : profession.value,
                            "recordTypeId" : this.RecordTypeId,
                            "companyOwner" : companyOwner.value ,
                            "phonePrefix" : phonePrefix.value ,
                            "mobilePhonePrefix" : mobilePhonePrefix.value 
                        };
                        insertAccount({
                            dataAccount: dataAccount,
                            accountAddress: this.fieldsToUpdate
                        }).then((response) => {
                            const event = new ShowToastEvent({
                                message: 'Account '+response.FirstName__c +' '+ response.LastName__c+' has been created!',
                                variant: 'success',
                                mode: 'dismissable'
                            });
                            this.dispatchEvent(event);
                            this.showModal= false;
                            this[NavigationMixin.Navigate]({
                                type: 'standard__recordPage',
                                attributes: {
                                    recordId: response.Id,
                                    objectApiName: 'Account',
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
                            this.spinner=false;
                            this.dispatchEvent(event);
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
                }else{
                    console.log("*******PRI");
                    dataAccount={
                        "businessName" : businessName.value,
                        "vatNumber" : vatNumber.value,
                        "fiscalCode" : fiscalCode.value.replace(/ /g,""),
                        "legalForm" : legalForm.value,
                        "customerMarking" : customerMarking.value,
                        "category" : category.value,
                        "firstIndividualName" : firstIndividualName.value,
                        "lastIndividualName" : lastIndividualName.value,
                        "phoneNumber" : phoneNumber.value,
                        "email" : email.value,
                        "electronicMail" : electronicMail.value,
                        "numberFax" : numberFax.value,
                        "prefixPhoneNumber" : prefixPhoneNumber,
                        "prefixMobilePhoneNumber" : prefixMobilePhoneNumber,
                        "mobilephoneNumber" : mobilephoneNumber.value,
                        "firstName" : firstName.value,
                        "gender" : this.gender,
                        "lastName" : lastName.value,
                        "birthDate" : this.birthDate,
                        "birthplace": this.birthPlace,
                        "personFiscalCode" : this.personFiscalCode.value.replace(/ /g,""),
                        "role" : role.value,
                        "mobilePhone" : mobilePhone.value,
                        "contactEmail" : contactEmail.value,
                        "contactPhoneNumber" : contactPhoneNumber.value,
                        "contactElectronicMail" : contactElectronicMail.value,
                        "contactFax" : contactFax.value,
                        "education" : education.value,
                        "profession" : profession.value,
                        "recordTypeId" : this.RecordTypeId,
                        "companyOwner" : companyOwner.value ,
                        "phonePrefix" : phonePrefix.value ,
                        "mobilePhonePrefix" : mobilePhonePrefix.value 
                    };
                    console.log("*******DOP");
                    insertAccount({
                        dataAccount: dataAccount,
                        accountAddress: this.fieldsToUpdate
                    }).then((response) => {
                        const event = new ShowToastEvent({
                            message: 'Account '+response.FirstName__c +' '+ response.LastName__c+' has been created!',
                            variant: 'success',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(event);
                        this.showModal= false;
                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: response.Id,
                                objectApiName: 'Account',
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
                        this.spinner=false;
                        this.dispatchEvent(event);
                    });
                }  
            }else{
                const event = new ShowToastEvent({
                    message: " L\'indirizzo non è stato verificato! ",
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
                this.spinner=false;
            }
        }else{
            const event = new ShowToastEvent({
                message: messageError,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
            this.spinner=false;
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

    handleVatChange(event){
        let inputVal = event.target.value;
        if(!isFinite(inputVal)) {
        event.target.value = inputVal.toString().slice(0,-1);
    }
    }
}