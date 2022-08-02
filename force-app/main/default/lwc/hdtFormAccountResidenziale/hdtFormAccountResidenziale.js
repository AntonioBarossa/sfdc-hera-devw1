import { LightningElement, track ,api, wire} from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import COMPANY_FIELD from '@salesforce/schema/Contact.Company__c';
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
import getFromFiscalCode from '@salesforce/apex/HDT_UTL_CheckFiscalCodeTaxNumber.getDataFromFiscalCodeData';
import calculateFiscalCode from '@salesforce/apex/HDT_UTL_CalculateFiscalCode.calculateFiscalCode';
import insertAccount from '@salesforce/apex/HDT_LC_FormAccountResidenziale.insertAccount';
import checkRole from '@salesforce/apex/HDT_UTL_Account.checkIsBackoffice';


export default class HdtFormAccountResidenziale extends NavigationMixin(LightningElement) {
    
    @api showCompanyOwner = false;
    @track spinner=false;
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

    disableCopyAdd=true;
    disableCopyRes=true;
    customerType='Persona Fisica'
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
    valueCompany='';
    accountAddress;
    accountAddressRes;
    fieldsToUpdate= {};
    fieldsToUpdateRes= {};
    isVerified= false;
    isVerifiedShipping=false;
    showModal= true;
    @api RecordTypeId;

    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    contactInfo;
    @track companyOptions;
    
    
    @wire(getPicklistValues, { recordTypeId: '$contactInfo.data.defaultRecordTypeId', fieldApiName: COMPANY_FIELD })
    companyFieldInfo({ data, error }) {
        if (data) this.companyFieldData = data;
    }
    companyPicklist( comp) {
        let key = this.companyFieldData.controllerValues[comp];
        this.companyOptions = this.companyFieldData.values.filter(opt => opt.validFor.includes(key));
        var customCompanyOptions=[];
        this.companyOptions.forEach(function callbackFn(element, index) {
            if(element.value!='HC+HCM+EENE'){ 
                customCompanyOptions.push(element);
            }
        })
        
        this.companyOptions=customCompanyOptions;

    }
    
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
    customerGetMarkingOptions({error, data}) {
        if (data){
            try{
                this.customerData = {
                    "controllerValues" : data.controllerValues,
                    "values" : data.values.filter(element => !(new RegExp("D[0-9] - ").test(element.value)))
                };
            }catch(err){
                console.log('@@@@@@error ' + JSON.stringify(err));
            }
        }
    };
    
    @wire(getPicklistValues, {recordTypeId: '$RecordTypeId' ,fieldApiName: CATEGORY })
    categoryGetOptions({error, data}) {
        if (data){
            this.categoryData = data;
            this.inizializeInit();
        }
    };
    
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
        { label: 'Familiare', value: 'Familiare' }
    ];
    handleCompanyOwnerChange(event) {
        console.log("***************CHANGE" + event.target.value);
        let key = this.customerData.controllerValues[event.target.value];
        //this.filterMarkingOptions();
        //let customerMarkingOptionsPreCheck = this.customerData.values.filter(opt => opt.validFor.includes(key));
        //this.filterMarkingOptions(customerMarkingOptionsPreCheck);
        this.companyPicklist( event.target.value);
        this.customerMarkingOptions = this.customerData.values.filter(opt => opt.validFor.includes(key));
        this.markingValue = '';
        this.categoryValue = '';
        
    }
    //filterMarkingOptions(){
    /* filterMarkingOptions(customerMarkingOptionsPreCheck){
        console.log("@@@@Option Marcatura Cliente " + JSON.stringify(customerMarkingOptionsPreCheck));
        var customMarkingOptions=[];
        //this.customerMarkingOptions.forEach(function callbackFn(element, index) {
        customerMarkingOptionsPreCheck.forEach(function callbackFn(element, index) {
            var arrayToRemove=[];
            for (let i = 0; i < 20; i++) {
                arrayToRemove.push('D'+i+' -');
            }
            console.log(JSON.stringify(element.value));
            var startSubString=element.value;
            startSubString=element.label.substring(0, 4);            
            if(!arrayToRemove.includes(startSubString)){ 
                customMarkingOptions.push(element);
            }
        })
        
        this.customerMarkingOptions=customMarkingOptions;
    } */
    handleCustomerChange(event) {
        let key = this.categoryData.controllerValues[event.target.value];
        this.categoryOptions = this.categoryData.values.filter(opt => opt.validFor.includes(key));
        this.categoryValue = '';
        
        
    }
    closeModal() {
        this.showModal = false;
        window.history.back();
    }
    
    inizializeInit(){
        checkRole({}).then((response) => {
            //let customerMarkingOptionsPreCheck = [];
            let key = '';
            if(response == 'HDT_BackOffice'){
                this.showCompanyOwner = false;
            }else if(response == 'HDT_FrontOffice_HERA_COMM'){
                this.companyDefault = 'HERA COMM';
                this.showCompanyOwner = true;
                key = this.customerData.controllerValues['HERA COMM'];
                //this.customerMarkingOptions = this.customerData.values.filter(opt => opt.validFor.includes(key));
                //customerMarkingOptionsPreCheck = this.customerData.values.filter(opt => opt.validFor.includes(key));
                this.companyPicklist(this.companyDefault);
                
            }else if(response == 'HDT_FrontOffice_Reseller'){
                this.companyDefault = 'Reseller';
                this.showCompanyOwner = true;
                key = this.customerData.controllerValues['Reseller'];
                //this.customerMarkingOptions = this.customerData.values.filter(opt => opt.validFor.includes(key));
                //customerMarkingOptionsPreCheck = this.customerData.values.filter(opt => opt.validFor.includes(key));
                this.companyPicklist(this.companyDefault);
            }
            else if(response == 'HDT_FrontOffice_MMS'){
                this.companyDefault = 'MMS';
                this.showCompanyOwner = true;
                key = this.customerData.controllerValues['MMS'];
                //this.customerMarkingOptions = this.customerData.values.filter(opt => opt.validFor.includes(key));
                //customerMarkingOptionsPreCheck = this.customerData.values.filter(opt => opt.validFor.includes(key));
                this.companyPicklist(this.companyDefault);
                
            }
            else if(response == 'HDT_FrontOffice_AAAEBT'){
                this.companyDefault = 'AAA-EBT';
                this.showCompanyOwner = true;
                key = this.customerData.controllerValues['AAA-EBT'];
                //this.customerMarkingOptions = this.customerData.values.filter(opt => opt.validFor.includes(key));
                //customerMarkingOptionsPreCheck = this.customerData.values.filter(opt => opt.validFor.includes(key));
                this.companyPicklist(this.companyDefault);
                
                
            }
            else{
                this.companyDefault = 'HERA COMM';
                this.showCompanyOwner = true;
                key = this.customerData.controllerValues['HERA COMM'];
                //this.customerMarkingOptions = this.customerData.values.filter(opt => opt.validFor.includes(key));
                //customerMarkingOptionsPreCheck = this.customerData.values.filter(opt => opt.validFor.includes(key));
                this.companyPicklist(this.companyDefault);
                
            }
            this.customerMarkingOptions = this.customerData.values.filter(opt => opt.validFor.includes(key));
            //this.filterMarkingOptions();
            //this.filterMarkingOptions(customerMarkingOptionsPreCheck);

        });
    }
    
    connectedCallback(){
        this.currentObjectApiName= 'Account';
    }
    passToParent(event){
            this.disableCopyAdd=!event.detail;
            this.disableCopyRes=true;
    }
    
    handleCopyAddRes(event){
     let copy=event.target.checked;
        this.disableCopyRes=!copy;
        console.log('disableCopyRes '+this.disableCopyRes);
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
    /**Residenza */
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
            if(this.accountAddress['Indirizzo Estero'] === true)
            {
                this.fieldsToUpdate['BillingAddressIsForeign__c'] = true;
                this.fieldsToUpdate['BillingIsAddressVerified__c'] = true;
                this.isVerified = true;
            }
            console.log('### Indirizzo Residenza >>> ' + JSON.stringify(this.accountAddress));
            console.log('### Residenza Verificato >>> ' + this.isVerified);
            console.log('### Residenza Estero ' + this.accountAddress["Indirizzo Estero"]);
        }
    }
    /**Dcomicilio */
    getAccountAdressRes(){
        
        if(this.accountAddressRes!= undefined){
            console.log( this.accountAddressRes['Via']);
            if(this.accountAddressRes['Via'] != null){
                this.fieldsToUpdateRes['ShippingStreet'] = this.accountAddressRes['Via'];
               // this.fieldsToUpdateRes['ShippingStreet'] = this.accountAddressRes['Via'];
            }
            if(this.accountAddressRes['Comune'] != null){
                this.fieldsToUpdateRes['ShippingCity'] = this.accountAddressRes['Comune'];
            }
            if(this.accountAddressRes['CAP'] != null){
                this.fieldsToUpdateRes['ShippingPostalCode'] = this.accountAddressRes['CAP'];
            }
            if(this.accountAddressRes['Stato'] != null){
                this.fieldsToUpdateRes['ShippingCountry'] = this.accountAddressRes['Stato'];
            }
            if(this.accountAddressRes['Provincia'] != null){
                this.fieldsToUpdateRes['ShippingState'] = this.accountAddressRes['Provincia'];
            }
            if(this.accountAddressRes['Codice Comune SAP'] != null){
                this.fieldsToUpdateRes['ShippingCityCode__c'] = this.accountAddressRes['Codice Comune SAP'];
            }
            if(this.accountAddressRes['Codice Via Stradario SAP'] != null){
                this.fieldsToUpdateRes['ShippingStreetCode__c'] = this.accountAddressRes['Codice Via Stradario SAP'];
            }
            if(this.accountAddressRes['Estens.Civico'] != null){
                this.fieldsToUpdateRes['ShippingStreetNumberExtension__c'] = this.accountAddressRes['Estens.Civico'];
            }
            if(this.accountAddressRes['Civico'] != null){
                this.fieldsToUpdateRes['ShippingStreetNumber__c'] = this.accountAddressRes['Civico'];
            }
            if(this.accountAddressRes['Localita'] != null){
                this.fieldsToUpdateRes['ShippingPlace__c'] = this.accountAddressRes['Localita'];
            }
            if(this.accountAddressRes['Codice Localita'] != null){
                this.fieldsToUpdateRes['ShippingPlace__c'] = this.accountAddressRes['Codice Localita'];
            }
            if(this.accountAddressRes['Flag Verificato'] !=null){
                this.fieldsToUpdateRes['ShippingIsAddressVerified__c'] = this.accountAddressRes['Flag Verificato'];
                this.isVerifiedShipping = this.accountAddressRes['Flag Verificato'];
            }
            if(this.accountAddressRes['Indirizzo Estero'] === true)
            {
                this.fieldsToUpdateRes['ShippingAddressIsForeign__c'] = true;
                this.fieldsToUpdateRes['ShippingIsAddressVerified__c'] = true;
                this.isVerifiedShipping = true;
            }
            console.log('### Indirizzo Domicilio >>> ' + JSON.stringify(this.fieldsToUpdateRes));
            console.log('### Domicilio Verificato >>> ' + this.isVerifiedShipping);
            console.log('### Domicilio Estero >>> ' + this.accountAddressRes['Indirizzo Estero'])
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
        // let companyValue= this.template.querySelector('[data-id="SocietaSilos"]');
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
        let comNascita = this.template.querySelector('[data-id="birthPlace"]');
        this.spinner= true;
        let messageError= "Completare tutti i campi obbligatori !";
        var mailFormat = /^(?:[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?\.)+[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[A-Za-z0-9-]*[A-Za-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])$/;
        
        //CAMPI IN UPPERCASE
        let firstNameToUC = '';
        let lastNameToUC = '';
        let fiscalCodeToUC = '';
        let birthPlaceToUC = '';
        if(firstName.value != null && firstName.value != undefined && firstName.value != '')
            firstNameToUC = firstName.value.toUpperCase();
        if(lastName.value != null && lastName.value != undefined && lastName.value != '')
            lastNameToUC = lastName.value.toUpperCase();
        if(this.fiscalCode.value != null && this.fiscalCode.value != undefined && this.fiscalCode.value != '')
            fiscalCodeToUC = this.fiscalCode.value.toUpperCase();
        if(this.birthPlace != null && this.birthPlace != undefined && this.birthPlace != '')
            birthPlaceToUC = this.birthPlace.toUpperCase();

        console.log('firstNameToUC --> '+firstNameToUC);
        console.log('lastNameToUC --> '+lastNameToUC);
        console.log('fiscalCodeToUC --> '+fiscalCodeToUC);
        console.log('birthPlaceToUC --> '+birthPlaceToUC);


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
        // if(!comNascita.reportValidity()){
        //     isValidated=false;
        // }
        
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
        console.log('LENGTH:'+ this.fiscalcode + '-:' + this.fiscalCode.value.length);
        if(!(this.fiscalCode.value=== undefined || this.fiscalCode.value.trim()==='')){
            if(this.fiscalCode.value.length != 16){
                isValidated=false;
                messageError=" Il Codice fiscale deve essere lungo 16 cifre!";
            }
        }
        
        if(!(mobilePhone.value=== undefined || mobilePhone.value.trim()==='')){
            if(mobilePhone.value.length<9 || mobilePhone.value.length > 10){
                isValidated=false;
                messageError=" Il numero di cellulare deve essere compreso tra le 9 e le 10 cifre!";
            }
            if( String(mobilePhone.value).charAt(0)!='3' ){
                isValidated=false;
                messageError=" Il numero di cellulare deve iniziare con il numero 3!";
            }
        }
        if(!(phoneNumber.value=== undefined || phoneNumber.value.trim()==='')){
            if(phoneNumber[0] != '0' && (phoneNumber.value.length<6 || phoneNumber.value.length > 11)){
                isValidated=false;
                messageError=" Il numero di telefono deve essere compreso tra le 6 e le 11 cifre ed iniziare per 0!";
            }
            if( String(phoneNumber.value).charAt(0)!='0'){
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
            this.accountAddressRes =this.template.querySelector("c-hdt-target-object-address-fields").handleAddressFields();
            console.log('accountAddressRes : '+ JSON.stringify(this.accountAddressRes));
            this.getAccountAdressRes();
            if (!this.disableCopyRes) {
                this.accountAddress=this.accountAddressRes;    
              }
              else{
                  this.accountAddress=[];
                  this.accountAddress =this.template.querySelector("c-hdt-target-object-address-fields-res").handleAddressFields();
                  
              }
            this.getAccountAdress();
            if(this.isVerified && this.isVerifiedShipping ){
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
                        fiscalCodes : this.fiscalCode.value.replace(/ /g,"")
                    }).then((response) => {
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
                            birthPlaceToUC = this.birthPlace.toUpperCase();
                            console.log('birthPlace : ' + this.birthPlace);
                            
                            //this.birthPlace= fiscData.birthPlace;
                        }
                        
                        let acc= {
                            "firstName": firstNameToUC,
                            "lastName": lastNameToUC,
                            "fiscalCode": fiscalCodeToUC.replace(/ /g,""),
                            "phoneNumber": phoneNumber.value,
                            "mobilePhone" : mobilePhone.value,
                            "name": firstNameToUC.trim()+' '+lastNameToUC,
                            "email": email.value,
                            "birthplace": birthPlaceToUC,
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
                            "mobilePhonePrefix" : mobilePhonePrefix.value, 
                            // "company":companyValue.value,
                            "customerType":this.customerType,
                        };
                        insertAccount({
                            dataAccount : acc,
                            accountAddress: this.fieldsToUpdate,
                            accountAddressRes: this.fieldsToUpdateRes
                        }).then((response) => {
                            const event = new ShowToastEvent({
                                message: 'Account '+response.FirstName__c +' '+ response.LastName__c+' creato con successo!',
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
                            message: 'Inserire un codice fiscale valido',
                            variant: 'error',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(event);
                        this.spinner=false;
                    });
                }else{
                    getFromFiscalCode({
                        fiscalCodes : this.fiscalCode.value.replace(/ /g,"")
                    }).then((response) => {
                    let acc= {
                        "firstName": firstNameToUC,
                        "lastName": lastNameToUC,
                        "fiscalCode": fiscalCodeToUC.replace(/ /g,""),
                        "phoneNumber": phoneNumber.value,
                        "mobilePhone" : mobilePhone.value,
                        "name": firstName.value.trim()+' '+lastName.value,
                        "email": email.value,
                        "birthplace": birthPlaceToUC,
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
                        "mobilePhonePrefix" : mobilePhonePrefix.value,
                        // "company":companyValue.value,
                        "customerType":this.customerType,
                        
                    };
                    insertAccount({
                        dataAccount : acc,
                        accountAddress: this.fieldsToUpdate,
                        accountAddressRes: this.fieldsToUpdateRes

                    }).then((response) => {
                        const event = new ShowToastEvent({
                            message: 'Account '+response.FirstName__c +' '+ response.LastName__c+' creato con successo!',
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
                        message: 'Inserire un codice fiscale valido',
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