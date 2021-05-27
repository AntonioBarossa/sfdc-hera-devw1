import { LightningElement, track ,api, wire} from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import PHONE_PREFIX from '@salesforce/schema/Account.PhonePrefix__c';
import MOBILEPHONE_PREFIX from '@salesforce/schema/Account.MobilePhonePrefix__c';
import CUSTOM_MARKING from '@salesforce/schema/Account.CustomerMarking__c';
import CATEGORY from '@salesforce/schema/Account.Category__c';
import GENDER from '@salesforce/schema/Account.Gender__c';
import PROFESSION from '@salesforce/schema/Account.Profession__c';
import EDUCATIONALQUALIFICATION from '@salesforce/schema/Account.DegreeOfStudies__c';
import COMPANY_OWNER from '@salesforce/schema/Account.CompanyOwner__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getFromFiscalCode from '@salesforce/apex/HDT_UTL_CheckFiscalCodeTaxNumber.getDataFromFiscalCode';
import calculateFiscalCode from '@salesforce/apex/HDT_UTL_CalculateFiscalCode.calculateFiscalCode';
import insertAccount from '@salesforce/apex/HDT_LC_FormAccountResidenziale.insertAccount';
export default class HdtFormAccountResidenziale extends NavigationMixin(LightningElement) {


    @track spinner=false;
    @track errorMessage='';
    @track phonePrefixValue;
    @track phonePrefixOptions;
    @track mobilePhonePrefixValue;
    @track mobilePhonePrefixOptions;
    @track fiscalCode;
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
    showModal= true;
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
    
    @wire(getPicklistValues, {recordTypeId: '$RecordTypeId' ,fieldApiName: EDUCATIONALQUALIFICATION })
    educationalOptions;

    @wire(getPicklistValues, {recordTypeId: '$RecordTypeId' ,fieldApiName: COMPANY_OWNER })
    companyOwnerOptions;

    roleOptions=[
        { label: 'Titolare', value: 'Titolare' },
        { label: 'Legale rappresentante', value: 'Legale rappresentante' },
        { label: 'Amministratore condominio', value: 'Amministratore condominio' },
        { label: 'Dipendente azienda/collaboratore', value: 'Dipendente azienda/collaboratore' },
        { label: 'Contatto secondario', value: 'Contatto secondario' },
        { label: 'Delegato', value: 'Delegato' },
        { label: 'Azienda', value: 'Azienda' }
    ];

    closeModal() {
        this.showModal = false;
        window.history.back();
    }

    connectedCallback(){
        this.currentObjectApiName= 'Account';
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
                    //this.showError(errorMsg);
                    const event = new ShowToastEvent({
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
            if(this.accountAddress['Flag Verificato'] !=null){
                this.isVerified = this.accountAddress['Flag Verificato'];
            }
        }
    }

    handleSave(){
        console.log(this.RecordTypeId);

        let isValidated= true;
        let firstName =this.template.querySelector('[data-id="firstName"]');
        let lastName= this.template.querySelector('[data-id="lastName"]');
        this.fiscalCode= this.template.querySelector('[data-id="fiscalCode"]');
        let customerMarking =this.template.querySelector('[data-id="customerMarking"]');
        let category= this.template.querySelector('[data-id="category"]');
        let phonePrefix= this.template.querySelector('[data-id="phonePrefix"]');
        let mobilePhonePrefix= this.template.querySelector('[data-id="mobilePhonePrefix"]');
        let role= this.template.querySelector('[data-id="role"]');
        let companyOwner= this.template.querySelector('[data-id="companyOwner"]');
        // let settlDistrict= this.template.querySelector('[data-id="settlementDistrict"]');
        // let settlMunicipality= this.template.querySelector('[data-id="settlementMunicipality"]');
        // let settlAddress= this.template.querySelector('[data-id="settlementAddress"]');
        // let settlHouseNumber= this.template.querySelector('[data-id="settlementHouseNumber"]');
        // let settlPostalCode= this.template.querySelector('[data-id="settlementPostalCode"]');
        // let residenceDistrict= this.template.querySelector('[data-id="residenceDistrict"]');
        // let residencePostalCode= this.template.querySelector('[data-id="residencePostalCode"]');
        // let residenceMunicipality = this.template.querySelector('[data-id="residenceMunicipality"]');
        // let residenceAddress= this.template.querySelector('[data-id="residenceAddress"]');
        // let residenceHouseNumber= this.template.querySelector('[data-id="residenceHouseNumber"]');
        let mobilePhone= this.template.querySelector('[data-id="mobilePhone"]');
        let email= this.template.querySelector('[data-id="email"]');
        let phoneNumber= this.template.querySelector('[data-id="phoneNumber"]');
        let education=this.template.querySelector('[data-id="education"]');  
        let profession= this.template.querySelector('[data-id="profession"]');   
        this.gender=this.template.querySelector('[data-id="gender"]').value;
        this.birthDate=this.template.querySelector('[data-id="birthDate"]').value;
        this.birthPlace= this.template.querySelector('[data-id="birthPlace"]').value;
        this.spinner= true;
        let messageError= "Completare tutti i campi obbligatori !";
        var mailFormat = /^(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])$/;

        if(!firstName.reportValidity()){
            isValidated=false;
        } 
        if(!lastName.reportValidity()){
            isValidated=false;
        } 
        if(!this.fiscalCode.reportValidity()){
            isValidated=false;
        } 
        if(!category.reportValidity()){
            isValidated=false;
        } 
        if(!customerMarking.reportValidity()){
            isValidated=false;
        }
        if(!mobilePhonePrefix.reportValidity()){
            isValidated=false;
        }
        if(!phonePrefix.reportValidity()){
            isValidated=false;
        }
        if(!companyOwner.reportValidity()){
            isValidated=false;
        }
        
        // if(!settlDistrict.reportValidity()){
        //     isValidated=false;
        // } 
        // if(!residenceDistrict.reportValidity()){
        //     isValidated=false;
        // } 
        // if(!settlMunicipality.reportValidity()){
        //     isValidated=false;
        // } 
        // if(!residenceMunicipality.reportValidity()){
        //     isValidated=false;
        // } 
        // if(!settlAddress.reportValidity()){
        //     isValidated=false;
        // } 
        // if(!residenceAddress.reportValidity()){
        //     isValidated=false;
        // } 
        // if(!settlHouseNumber.reportValidity()){
        //     isValidated=false;
        // } 
        // if(!residenceHouseNumber.reportValidity()){
        //     isValidated=false;
        // }
        // if(!settlPostalCode.reportValidity()){
        //     isValidated=false;
        // }
        // if(!residencePostalCode.reportValidity()){
        //     isValidated=false;
        // }
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
                        
                        let acc= {
                            "firstName": firstName.value,
                            "lastName": lastName.value,
                            "fiscalCode": this.fiscalCode.value.replace(/ /g,""),
                            "phoneNumber": phoneNumber.value,
                            "mobilePhone" : mobilePhone.value,
                            "name": firstName.value+' '+lastName.value,
                            "email": email.value,
                            "birthplace": this.birthPlace,
                            "recordTypeId" : this.RecordTypeId,
                            "category" : category.value,
                            "customerMarking" : customerMarking.value,
                            "gender" : this.gender,
                            "education" : education.value,
                            "profession" : profession.value,
                            "role" : role.value,
                            "birthDate" : this.birthDate,
                            "companyOwner" : companyOwner.value ,
                            "phonePrefix" : phonePrefix.value ,
                            "mobilePhonePrefix" : mobilePhonePrefix.value   
                        };
                        insertAccount({
                            dataAccount : acc,
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
                }else{
                    let acc= {
                        "firstName": firstName.value,
                        "lastName": lastName.value,
                        "fiscalCode": this.fiscalCode.value.replace(/ /g,""),
                        "phoneNumber": phoneNumber.value,
                        "mobilePhone" : mobilePhone.value,
                        "name": lastName.value+' '+firstName.value,
                        "email": email.value,
                        "birthplace": this.birthPlace,
                        "recordTypeId" : this.RecordTypeId,
                        "category" : category.value,
                        "customerMarking" : customerMarking.value,
                        "gender" : this.gender,
                        "education" : education.value,
                        "profession" : profession.value,
                        "role" : role.value,
                        "birthDate" : this.birthDate,
                        "companyOwner" : companyOwner.value ,
                        "phonePrefix" : phonePrefix.value ,
                        "mobilePhonePrefix" : mobilePhonePrefix.value 
                    };
                    insertAccount({
                        dataAccount : acc,
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
                        this.dispatchEvent(event);
                        this.spinner=false;
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