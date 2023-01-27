import { LightningElement,track, api, wire} from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CUSTOMERTYPE_FIELD from '@salesforce/schema/Account.CustomerType__c';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import COMPANY_FIELD from '@salesforce/schema/Contact.Company__c';
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
import getFromFiscalCode2 from '@salesforce/apex/HDT_UTL_CheckFiscalCodeTaxNumber.getDataFromFiscalCodeData';
import calculateFiscalCode from '@salesforce/apex/HDT_UTL_CalculateFiscalCode.calculateFiscalCode';
import insertAccount from '@salesforce/apex/HDT_LC_FormAccountBusiness.insertAccount';
import checkRole from '@salesforce/apex/HDT_UTL_Account.checkIsBackoffice';

const ERROR_VARIANT='error';
const SUCCESS_VARIANT='success';
const DISMISSABLE_VARIANT='dismissable';
export default class HdtFormAccountBusiness extends NavigationMixin(LightningElement) {

    @api showCompanyOwner = false;
    @track showModal= true;
    @track spinner= false;
    @track markingValue;
    @track categoryValue;
    @track errorMessage='';
    @api companyDefault;
    @track phonePrefixValue;
    @track phonePrefixOptions;
    @track mobilePhonePrefixValue;
    @track mobilePhonePrefixOptions;
    @track makerequired= false;
    @track personFiscalCode;
    @track mobilephonePrefix2 = '+39';
    @track phonePrefixValue2 = '+39';
    @api customerMarkingOptions = [];
    @api categoryOptions = [];
    @api customerData = [];
    @api categoryData = [];
    addressContactDetails=false;//HRAWRM-933 Start 08/11/2021
    disableToggleContactDetails=false;//HRAWRM-933 Start 08/11/2021
    requiredVat=true;
    requiredFiscalCode=false;
    customerType='Organizzazione';
    gender;
    birthDate;
    birthPlace;
    currentObjectApiName = 'Account';
    accountAddress;
    contactAddress;//HRAWRM-933 Start 08/11/2021
    fieldsToUpdate= {};
    fieldsToUpdateContact={};//HRAWRM-933 Start 08/11/2021
    isVerified= false;
    isVerified2= false;

    @api RecordTypeId;
    @track companyOptions;
    @track customerTypeOptions;

    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    contactInfo;
  

   
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

    inizializeInit(){
        checkRole({}).then((response) => {
            let key = '';
            if(response == 'HDT_BackOffice'){
                this.showCompanyOwner = false;
            }else if(response == 'HDT_FrontOffice_HERACOMM'){
                this.companyDefault = 'HERA COMM';
                this.companyPicklist(this.companyDefault);
                this.showCompanyOwner = true;
                key = this.customerData.controllerValues['HERA COMM'];
                //this.customerMarkingOptions = this.customerData.values.filter(opt => opt.validFor.includes(key));
            }else if(response == 'HDT_FrontOffice_Reseller'){
                this.companyDefault = 'Reseller';
                this.companyPicklist(this.companyDefault);
                this.showCompanyOwner = true;
                key = this.customerData.controllerValues['Reseller'];
                //this.customerMarkingOptions = this.customerData.values.filter(opt => opt.validFor.includes(key));
            }
            else if(response == 'HDT_FrontOffice_MMS'){
                this.companyDefault = 'MMS';
                this.companyPicklist(this.companyDefault);
                this.showCompanyOwner = true;
                key = this.customerData.controllerValues['MMS'];
                //this.customerMarkingOptions = this.customerData.values.filter(opt => opt.validFor.includes(key));
            }
            else if(response == 'HDT_FrontOffice_AAAEBT'){
                this.companyDefault = 'AAA-EBT';
                this.companyPicklist(this.companyDefault);
                this.showCompanyOwner = true;
                key = this.customerData.controllerValues['AAA-EBT'];
                //this.customerMarkingOptions = this.customerData.values.filter(opt => opt.validFor.includes(key));
            }
            else{
                this.companyDefault = 'HERA COMM';
                this.companyPicklist(this.companyDefault);
                this.showCompanyOwner = true;
                key = this.customerData.controllerValues['HERA COMM'];
                //this.customerMarkingOptions = this.customerData.values.filter(opt => opt.validFor.includes(key));
            }
            //this.filterMarkingOptions();
            this.customerMarkingOptions = this.customerData.values.filter(opt => opt.validFor.includes(key));
        });
    }

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
    @wire(getPicklistValues,{recordTypeId: '$RecordTypeId' ,fieldApiName: CUSTOMERTYPE_FIELD })
    customerTypeFunction({error, data}) {
        if (data){
            var customTypeOptions=[];
            this.customerTypeOptions = data;
            data.values.forEach(function callbackFn(element, index) {
                
             if(element.value!='Persona Fisica'){
                customTypeOptions.push(element);
            }
                
                
         })        
           this.customerTypeOptions=customTypeOptions;

        }
    };
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
            { label: 'Dipendente azienda/collaboratore', value: 'Dipendente azienda/collaboratore' }
        ];
    }
    closeModal() {
        this.showModal = false;
        window.history.back();
    }

    connectedCallback(){
        this.currentObjectApiName= 'Account';
    }
    //HRAWRM-933 Start 08/11/2021
    handleChangeRole(event){ 
        let currentRole=event.target.value;
        let toggleContact= this.template.querySelector('[data-id="toggleContactDetails"]');
        let requiredToggle=currentRole==='Amministratore condominio'?true:false;
        this.addressContactDetails=requiredToggle;
        this.disableToggleContactDetails=requiredToggle;
        toggleContact.checked=requiredToggle;
    }
    handleToggleContactDetails(event){
        this.addressContactDetails=event.target.checked;
    }
    //HRAWRM-933 End 08/11/2021
    handleCompanyOwnerChange(event) {
        
        let key = this.customerData.controllerValues[event.target.value];
        //this.filterMarkingOptions();
        this.companyPicklist(event.target.value);
        this.customerMarkingOptions = this.customerData.values.filter(opt => opt.validFor.includes(key));
        this.markingValue = '';
        this.categoryValue = '';
    }
    /* filterMarkingOptions(){
        var customMarkingOptions=[];
        this.customerMarkingOptions.forEach(function callbackFn(element, index) {
            var arrayToRemove=[];
            for (let i = 0; i < 20; i++) {
                arrayToRemove.push('D'+i+' -');
            }
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
    handleChange(event){
        this.markingValue= event.detail.value;
        let key = this.categoryData.controllerValues[event.target.value];
        this.categoryOptions = this.categoryData.values.filter(opt => opt.validFor.includes(key));
        this.categoryValue = '';
        if(this.markingValue=='Ditta individuale'){
        //    this.template.querySelector('[data-id="legalForm"]').value = 'Ditta individuale';
        //    this.template.querySelector('[data-id="legalForm"]').readOnly = true;
            this.template.querySelector('[data-id="showDiv"]').classList.add('slds-show');
            this.template.querySelector('[data-id="showDiv"]').classList.remove('slds-hide');
            this.template.querySelector('[data-id="showDiv2"]').classList.add('slds-show');
            this.template.querySelector('[data-id="showDiv2"]').classList.remove('slds-hide');
            this.template.querySelector('[data-id="hideBusinessName"]').classList.add('slds-hide');
            this.template.querySelector('[data-id="hideBusinessName"]').classList.remove('slds-show');
            this.template.querySelector('[data-id="hideBusinessName2"]').classList.add('slds-hide');
            this.template.querySelector('[data-id="hideBusinessName2"]').classList.remove('slds-show');
            this.customerType='Persona fisica';
            this.makerequired= true;
            this.requiredVat=true; //HRAWRM-776 07/10/2021
        }
        /* TK 938126C -- Associazione deve comportarsi come Azienda */
        else if(this.markingValue.includes("Condominio")/*||this.markingValue.includes('Associazione') */ ){
            this.requiredVat= false;
            this.makerequired=true;

        }//HRAWRM-776 07/10/2021
        else{
         //   this.template.querySelector('[data-id="legalForm"]').readOnly = false;
            this.template.querySelector('[data-id="showDiv"]').classList.add('slds-hide');
            this.template.querySelector('[data-id="showDiv"]').classList.remove('slds-show');
            this.template.querySelector('[data-id="showDiv2"]').classList.add('slds-hide');
            this.template.querySelector('[data-id="showDiv2"]').classList.remove('slds-show');
            this.template.querySelector('[data-id="hideBusinessName"]').classList.add('slds-show');
            this.template.querySelector('[data-id="hideBusinessName"]').classList.remove('slds-hide');
            this.template.querySelector('[data-id="hideBusinessName2"]').classList.add('slds-show');
            this.template.querySelector('[data-id="hideBusinessName2"]').classList.remove('slds-hide');
            this.makerequired= false;
            this.requiredVat=true;//HRAWRM-776 07/10/2021
            this.customerType='Organizzazione';

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
            if(response == null){
              //  this.showError(errorMsg);
                // const event = new ShowToastEvent({
                // message: 'Comune inserito NON presente a sistema',
                // variant: 'error',
                // mode: 'dismissable'
                // });
                // this.dispatchEvent(event);
                this.spinner=false;
                this.toastMessage('Comune inserito non presente a sistema',ERROR_VARIANT,DISMISSABLE_VARIANT);
            }
            else{
                this.personFiscalCode.value= response;
                this.spinner=false;
            }
            }).catch((errorMsg) => {
                this.showError(errorMsg);
                // const event = new ShowToastEvent({
                //     message: this.errorMessage,
                //     variant: 'error',
                //     mode: 'dismissable'
                // });
                // this.dispatchEvent(event);
                this.toastMessage(this.errorMessage,ERROR_VARIANT,DISMISSABLE_VARIANT);
            });   
        }
        else{
            // const event = new ShowToastEvent({
            //     message: 'Inserire le Informazioni Mancanti',
            //     variant: 'error',
            //     mode: 'dismissable'
            // });
            // this.dispatchEvent(event);
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
            if(this.accountAddress['Indirizzo Estero'] === true)
            {
                this.fieldsToUpdate['BillingAddressIsForeign__c'] = true;
                this.fieldsToUpdate['BillingIsAddressVerified__c'] = true;
                this.isVerified = true;
            }
        }
    }
    //HRAWRM-933 Start 08/11/2021
    getContactAdress(){

        if(this.contactAddress!= undefined){
    
            if(this.contactAddress['Via'] != null){
                this.fieldsToUpdateContact['MailingStreet'] = this.contactAddress['Via'];
                this.fieldsToUpdateContact['MailingStreetName__c'] = this.contactAddress['Via'];
            }
            if(this.contactAddress['Comune'] != null){
                this.fieldsToUpdateContact['MailingCity'] = this.contactAddress['Comune'];
            }
            if(this.contactAddress['CAP'] != null){
                this.fieldsToUpdateContact['MailingPostalCode'] = this.contactAddress['CAP'];
            }
            if(this.contactAddress['Stato'] != null){
                this.fieldsToUpdateContact['MailingCountry'] = this.contactAddress['Stato'];
            }
            if(this.contactAddress['Provincia'] != null){
                this.fieldsToUpdateContact['MailingState'] = this.contactAddress['Provincia'];
            }
            if(this.contactAddress['Codice Comune SAP'] != null){
                this.fieldsToUpdateContact['MailingCityCode__c'] = this.contactAddress['Codice Comune SAP'];
            }
            if(this.contactAddress['Codice Via Stradario SAP'] != null){
                this.fieldsToUpdateContact['MailingStreetCode__c'] = this.contactAddress['Codice Via Stradario SAP'];
            }
            if(this.contactAddress['Estens.Civico'] != null){
                this.fieldsToUpdateContact['MailingStreetNumberExtension__c'] = this.contactAddress['Estens.Civico'];
            }
            if(this.contactAddress['Civico'] != null){
                this.fieldsToUpdateContact['MailingStreetNumber__c'] = this.contactAddress['Civico'];
            }
            if(this.contactAddress['Localita'] != null){
                this.fieldsToUpdateContact['MailingPlace__c'] = this.contactAddress['Localita'];
            }
            if(this.contactAddress['Codice Localita'] != null){
                this.fieldsToUpdateContact['MailingPlaceCode__c'] = this.contactAddress['Codice Localita'];
            }
            if(this.contactAddress['Flag Verificato'] !=null){
                this.fieldsToUpdateContact['MailingIsAddressVerified__c'] = this.contactAddress['Flag Verificato'];
                this.isVerified2 = this.contactAddress['Flag Verificato'];
            }
            if(this.contactAddress['Indirizzo Estero'] === true)
            {
                this.fieldsToUpdateContact['MailingIsAddressVerified__c'] = true;
                this.isVerified2 = true;
            }
        }
    }
    //HRAWRM-933 End 08/11/2021

    handleSave(){

        var isValidated= true;
        var businessName =this.template.querySelector('[data-id="businessName"]');
        var vatNumber =this.template.querySelector('[data-id="vatNumber"]');
        this.personFiscalCode= this.template.querySelector('[data-id="personFiscalCode"]');
        let prefixPhoneNumber = this.template.querySelector('[data-id="phonePrefix2"]');
        let phoneNumber= this.template.querySelector('[data-id="phoneNumber"]');
        let prefixMobilePhoneNumber = this.template.querySelector('[data-id="mobilephonePrefix2"]');
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
        // let companyValue= this.template.querySelector('[data-id="SocietaSilos"]');
        
        let customerTypeValue=this.template.querySelector('[data-id="ClienteFinale"]').value===null?this.template.querySelector('[data-id="customerType"]').value:this.template.querySelector('[data-id="ClienteFinale"]').value;

        console.log('customerTypeValue --> '+customerTypeValue);

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
     //   let legalForm= this.template.querySelector('[data-id="legalForm"]');
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
        var messageError= "Completare tutti i campi obbligatori !";
        var mailFormat = /^(?:[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?\.)+[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[A-Za-z0-9-]*[A-Za-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])$/;
        var dataAccount;
        //var vatNumberValid = this.checkVATNumberMethod(vatNumber.value);

        


        //CAMPI IN UPPERCASE
        let businessNameToUC = '';
        let fiscalCodeToUC = '';
        let firstNameToUC = '';
        let lastNameToUC = '';
        let personFiscalCodeToUC = '';
        let birthPlaceToUC = '';
        let firstIndividualNameToUC = '';
        let lastIndividualNameToUC = '';
        if(businessName.value != null && businessName.value != undefined && businessName.value != '')
            businessNameToUC = businessName.value.toUpperCase();
        if(fiscalCode.value != null && fiscalCode.value != undefined && fiscalCode.value != '')
            fiscalCodeToUC = fiscalCode.value.toUpperCase();
        if(firstName.value != null && firstName.value != undefined && firstName.value != '')
            firstNameToUC = firstName.value.toUpperCase().trim();
        if(lastName.value != null && lastName.value != undefined && lastName.value != '')
            lastNameToUC = lastName.value.toUpperCase().trim();
        if(this.personFiscalCode.value != null && this.personFiscalCode.value != undefined && this.personFiscalCode.value != '')
            personFiscalCodeToUC = this.personFiscalCode.value.toUpperCase();
        if(this.birthPlace != null && this.birthPlace != undefined && this.birthPlace != '')
            birthPlaceToUC = this.birthPlace.toUpperCase();
        if(firstIndividualName.value != null && firstIndividualName.value != undefined && firstIndividualName.value != '')
            firstIndividualNameToUC = firstIndividualName.value.toUpperCase().trim();
        if(lastIndividualName.value != null && lastIndividualName.value != undefined && lastIndividualName.value != '')
            lastIndividualNameToUC = lastIndividualName.value.toUpperCase().trim();
        console.log('businessNameToUC --> '+businessNameToUC);
        console.log('fiscalCodeToUC --> '+fiscalCodeToUC);
        console.log('firstNameToUC --> '+firstNameToUC);
        console.log('lastNameToUC --> '+lastNameToUC);
        console.log('personFiscalCodeToUC --> '+personFiscalCodeToUC);
        console.log('birthPlaceToUC --> '+birthPlaceToUC);
        console.log('firstIndividualNameToUC --> '+firstIndividualNameToUC);
        console.log('lastIndividualNameToUC --> '+lastIndividualNameToUC);

        if ((this.markingValue.includes("Condominio")||this.markingValue.includes('Associazione')) && (fiscalCode.value== undefined||fiscalCode.value.trim()=='')) {
          
            if(!fiscalCode.reportValidity()){
                isValidated=false;
            }
           
        }
        if(this.markingValue === undefined || !this.markingValue=='Ditta individuale'){
            if(!businessName.reportValidity()){
                isValidated=false;
            } 
        }
        console.log("LOG1");
        if(!vatNumber.reportValidity()){
            isValidated=false;
        }
        if(!(vatNumber.value=== undefined || vatNumber.value.trim()==='')){
            if(vatNumber.value.length != 11){
                isValidated=false;
                messageError=" La Partita Iva deve essere lunga 11 cifre!";
            }
            //Check P.IVA Valido.
/*             if(vatNumberValid == false){
                isValidated=false;
                messageError=" La Partita Iva non è valida!";
            }
            else if(vatNumberValid == null){
                isValidated=false;
                messageError="Errore imprevisto nella Partita IVA!";
            } */
        }
        if(!this.personFiscalCode.reportValidity()){
            isValidated=false;
        }
        if(!(this.personFiscalCode.value=== undefined || this.personFiscalCode.value.trim()==='')){
            if(this.personFiscalCode.value.length != 16){
                isValidated=false;
                messageError=" il Codice Fiscale del Referente deve essere lungo 16 cifre!";
            }
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
        console.log("LOG2");
        if(!phonePrefix.reportValidity()){
            isValidated=false;
        }
        if(!firstName.reportValidity()){
            isValidated=false;
        } 
        if(!lastName.reportValidity()){
            isValidated=false;
        } 
        console.log("LOG3");
        if(!phoneNumber.reportValidity() && !mobilephoneNumber.reportValidity() && !email.reportValidity()){
            isValidated=false;
        }
        if(!role.reportValidity()){
            isValidated=false;
        }
        if(!customerMarking.reportValidity()){
            isValidated=false;
        }
        if(this.markingValue=='Ditta individuale'){
            if(!lastIndividualName.reportValidity()){
                isValidated=false;
            }

            if(!fiscalCode.reportValidity()){
                isValidated=false;
            }
            if(!(fiscalCode.value=== undefined || fiscalCode.value.trim()==='')){
                if(fiscalCode.value.length != 16){
                    isValidated=false;
                    messageError=" Il Codice fiscale deve essere lungo 16 cifre!";
                }
            }
        }

        // if(this.birthPlace == undefined || this.birthPlace == ''){
        //     isValidated = false;
        //     messageError=" Inserire il comune di nascita!";
        // }

        console.log("LOG4");
        if(!(mobilePhone.value=== undefined || mobilePhone.value.trim()==='')){
            if(mobilePhonePrefix.value == '+39'){
                if(mobilePhone.value[0] != '3' || mobilePhone.value.length<9 || mobilePhone.value.length > 10){
                    isValidated=false;
                    messageError=" Il numero di cellulare deve essere compreso tra le 9 e le 10 cifre e deve iniziare per 3!";
                }
            }
        }
        if(!(mobilephoneNumber.value=== undefined || mobilephoneNumber.value.trim()==='')){
            if(prefixMobilePhoneNumber.value == '+39'){
                if(mobilephoneNumber.value[0] != '3' || mobilephoneNumber.value.length<9 || mobilephoneNumber.value.length > 10){
                    isValidated=false;
                    messageError=" Il numero di cellulare deve essere compreso tra le 9 e le 10 cifre e deve iniziare per 3!";
                } 
            }           
        }
        if(!(contactPhoneNumber.value=== undefined || contactPhoneNumber.value.trim()==='')){
            if(contactPhoneNumber.value[0] != '0' || contactPhoneNumber.value.length<6 || contactPhoneNumber.value.length > 11){
                isValidated=false;
                messageError=" Il numero di telefono fisso deve essere compreso tra le 6 e le 11 cifre ed iniziare per 0!";
            }
        }
        if(!(contactEmail.value=== undefined || contactEmail.value.trim()==='')){
            if(!mailFormat.test(contactEmail.value)){
                isValidated=false;
                messageError=" Formato email errato !";
            }
        }
        console.log("LOG5");
        if(!(phoneNumber.value=== undefined || phoneNumber.value.trim()==='')){
            if(phoneNumber.value[0] != '0' || phoneNumber.value.length<6 || phoneNumber.value.length > 11){
                isValidated=false;
                messageError=" Il numero di telefono fisso deve essere compreso tra le 6 e le 11 cifre ed iniziare per 0!";
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
       if((mobilephoneNumber.value=== undefined || mobilephoneNumber.value.trim()==='')&&(email.value=== undefined || email.value.trim()==='')
        && (phoneNumber.value=== undefined || phoneNumber.value.trim()==='') && (electronicMail.value=== undefined || electronicMail.value.trim()==='') 
        && (numberFax.value=== undefined || numberFax.value.trim()=== '') ){
            if(isValidated){
                messageError=" Almeno un dato di contatto è obbligatorio!";
            }
            isValidated=false;
        }
        console.log("LOG6");
        if((mobilePhone.value=== undefined || mobilePhone.value.trim()==='')&&(contactEmail.value=== undefined || contactEmail.value.trim()==='')
        && (contactPhoneNumber.value=== undefined || contactPhoneNumber.value.trim()==='') && (contactElectronicMail.value=== undefined || contactElectronicMail.value.trim()==='') 
        && (contactFax.value=== undefined || contactFax.value.trim()=== '')){
            if(isValidated){
                messageError=" Almeno un dato di contatto è obbligatorio!";
            }
            isValidated=false;
        }
        console.log("LOG7");
       if(isValidated){
            console.log("LOG8");
            this.accountAddress =this.template.querySelector("c-hdt-target-object-address-fields").handleAddressFields();
            this.getAccountAdress();
            //HRAWRM-933 Start 08/11/2021
            if (this.addressContactDetails) {
                this.contactAddress =this.template.querySelector("c-hdt-target-object-address-fields-res").handleAddressFields();
                this.getContactAdress();
                if (this.isVerified2==false) {
                    this.isVerified=false;
                }
            }
            //HRAWRM-933 End 08/11/2021
            
            if(this.isVerified){
                console.log("LOG9");
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
                console.log("LOG10");
                if(isEmpty){
                    console.log("LOG11:" + this.personFiscalCode.value);
                    var prova = this.personFiscalCode.value;//.replace(/ /g,"");
                    console.log("LOG12:" + prova);
                    var keyCode= prova; //HRDTR-00_HRAWRM-761 28/09/2021

                    getFromFiscalCode2({
                        fiscalCodes : prova
                    }).then((response) => {
                        console.log("LOG12");
                        let fiscData= response;
                        if(this.gender === undefined || this.gender.trim()===''){
                            //this.gender= fiscData.gender;
                            this.gender=fiscData[keyCode].gender;//HRDTR-00_HRAWRM-761 28/09/2021
                        }
                        if(this.birthDate || this.birthDate.trim()==''){
                            //this.birthDate= fiscData.birthDate;
                            this.birthDate=fiscData[keyCode].birthDate;//HRDTR-00_HRAWRM-761 28/09/2021
                        }
                        if(this.birthPlace === undefined || this.birthPlace.trim()===''){
                           // this.birthPlace= fiscData.birthPlace;
                           this.birthPlace=fiscData[keyCode].birthPlace;//HRDTR-00_HRAWRM-761 28/09/2021
                           birthPlaceToUC = this.birthPlace.toUpperCase();

                        }
                        console.log("LOG13:");
                        console.log("LOG13:" + businessName.value);
                        
                        dataAccount={
                            "businessName" : businessNameToUC,
                            "vatNumber" : vatNumber.value,
                            "fiscalCode" : fiscalCodeToUC.replace(/ /g,""),
                          //  "legalForm" : legalForm.value,
                            "customerMarking" : customerMarking.value,
                            "category" : category.value,
                            "firstIndividualName" : firstIndividualNameToUC,
                            "lastIndividualName" : lastIndividualNameToUC,
                            "prefixPhoneNumber" : prefixPhoneNumber.value,
                            "prefixMobilePhoneNumber" : prefixMobilePhoneNumber.value,
                            "mobilephoneNumber" : mobilephoneNumber.value,
                            "phoneNumber" : phoneNumber.value,
                            "email" : email.value,
                            "electronicMail" : electronicMail.value,
                            "numberFax" : numberFax.value,
                            "firstName" : firstNameToUC,
                            "gender" : this.gender,
                            "lastName" : lastNameToUC,
                            "birthDate" : this.birthDate,
                            "birthplace": birthPlaceToUC,
                            "personFiscalCode" : personFiscalCodeToUC.replace(/ /g,""),
                            "role" : role.value,
                            "mobilePhone" : mobilePhone.value,
                            "contactEmail" : contactEmail.value,
                            "contactPhoneNumber" : contactPhoneNumber.value,
                            "contactElectronicMail" : contactElectronicMail.value,
                            "contactFax" : contactFax.value,
                            "education" : education.value,
                            "profession" : profession.value,
                            "recordTypeId" : this.RecordTypeId,
                            "companyOwner" : companyOwner.value,
                            // "company":companyValue.value,
                            "phonePrefix" : phonePrefix.value ,
                            "mobilePhonePrefix" : mobilePhonePrefix.value,
                            "customerTypeValue": customerTypeValue
                        };
                        console.log("LOG14");
                        insertAccount({
                            dataAccount: dataAccount,
                            accountAddress: this.fieldsToUpdate,
                            contactAddress: this.fieldsToUpdateContact //HRAWRM-933 Start 08/11/2021
                        }).then((response) => {
                            console.log("LOG15");
                            // const event = new ShowToastEvent({
                            //     message: 'Account creato con successo!', // ambiguita in caso si creano due account //? In accordo con lorenzo viene rimosso il Nome dell Account
                            //     variant: 'success',
                            //     mode: 'dismissable'
                            // });
                            // this.dispatchEvent(event);
                            this.spinner=false;
                            this.toastMessage('Account creato con successo!',SUCCESS_VARIANT,DISMISSABLE_VARIANT);

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
                            // const event = new ShowToastEvent({
                            //     message: this.errorMessage,
                            //     variant: 'error',
                            //     mode: 'dismissable'
                            // });
                            this.spinner=false;
                            this.toastMessage(this.errorMessage,ERROR_VARIANT,DISMISSABLE_VARIANT);

                            // this.dispatchEvent(event);
                        });
                    }).catch((errorMsg) => {
                        console.log("LOG12Error");
                        // const event = new ShowToastEvent({
                        //     message: 'Inserire un codice fiscale valido',
                        //     variant: 'error',
                        //     mode: 'dismissable'
                        // });
                        // this.dispatchEvent(event);
                        this.spinner=false;
                        this.toastMessage('Inserire un codice fiscale valido',ERROR_VARIANT,DISMISSABLE_VARIANT);

               
                    });
                }else{
                    var prova = this.personFiscalCode.value;//.replace(/ /g,"");
                    console.log("LOG12:" + prova);
                        
                    getFromFiscalCode2({
                        fiscalCodes : prova
                    }).then((response) => {
                    console.log("LOG16");
                    dataAccount={
                        "businessName" : businessNameToUC,
                        "vatNumber" : vatNumber.value,
                        "fiscalCode" : fiscalCodeToUC.replace(/ /g,""),
                      //  "legalForm" : legalForm.value,
                        "customerMarking" : customerMarking.value,
                        "category" : category.value,
                        "firstIndividualName" : firstIndividualNameToUC,
                        "lastIndividualName" : lastIndividualNameToUC,
                        "phoneNumber" : phoneNumber.value,
                        "email" : email.value,
                        "electronicMail" : electronicMail.value,
                        "numberFax" : numberFax.value,
                        "prefixPhoneNumber" : prefixPhoneNumber.value,
                        "prefixMobilePhoneNumber" : prefixMobilePhoneNumber.value,
                        "mobilephoneNumber" : mobilephoneNumber.value,
                        "firstName" : firstNameToUC,
                        "gender" : this.gender,
                        "lastName" : lastNameToUC,
                        "birthDate" : this.birthDate,
                        "birthplace": birthPlaceToUC,
                        "personFiscalCode" : personFiscalCodeToUC.replace(/ /g,""),
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
                        "mobilePhonePrefix" : mobilePhonePrefix.value,
                        // "company":companyValue.value,
                        "customerTypeValue": customerTypeValue
                    };
                    
                    console.log('customerTypeValue --> '+customerTypeValue);
                    console.log("*******DOP");
                    console.log("LOG17");
                    insertAccount({
                        dataAccount: dataAccount,
                        accountAddress: this.fieldsToUpdate,
                        contactAddress: this.fieldsToUpdateContact
                    }).then((response) => {
                        // const event = new ShowToastEvent({
                        //     message: 'Account creato con successo!', // ambiguita in caso si creano due account //? In accordo con lorenzo viene rimosso il Nome dell Account
                        //     variant: 'success',
                        //     mode: 'dismissable'
                        // });
                        // this.dispatchEvent(event);
                        this.spinner=false;
                        this.toastMessage('Account creato con successo!',SUCCESS_VARIANT,DISMISSABLE_VARIANT);

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
                        // const event = new ShowToastEvent({
                        //     message: this.errorMessage,
                        //     variant: 'error',
                        //     mode: 'dismissable'
                        // });
                        this.spinner=false;
                        // this.dispatchEvent(event);
                        this.toastMessage(this.errorMessage,ERROR_VARIANT,DISMISSABLE_VARIANT);

                    });
                }).catch((errorMsg) => {
                    console.log("LOG12Error");
                    // const event = new ShowToastEvent({
                    //     message: 'Inserire un codice fiscale valido',
                    //     variant: 'error',
                    //     mode: 'dismissable'
                    // });
                    // this.dispatchEvent(event);
                    this.spinner=false;
                    this.toastMessage('Inserire un codice fiscale valido',ERROR_VARIANT,DISMISSABLE_VARIANT);
                });
                } 
                 
            }else{
                console.log("LOG18");
                // const event = new ShowToastEvent({
                //     message: " L\'indirizzo non è stato verificato! ",
                //     variant: 'error',
                //     mode: 'dismissable'
                // });
                // this.dispatchEvent(event);
                this.spinner=false;
                this.toastMessage("L\'indirizzo non è stato verificato!",ERROR_VARIANT,DISMISSABLE_VARIANT);
            }
        }else{
            // const event = new ShowToastEvent({
            //     message: messageError,
            //     variant: 'error',
            //     mode: 'dismissable'
            // });
            // this.dispatchEvent(event);
            this.spinner=false;
            this.toastMessage(messageError,ERROR_VARIANT,DISMISSABLE_VARIANT);
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
    //HRAWRM-933 Start 08/11/2021
    toastMessage(myMessage,myVariant,myDismissable){
        const event = new ShowToastEvent({
            message:myMessage,
            variant: myVariant,
            mode: myDismissable
        });
        this.dispatchEvent(event);
    }    
    //HRAWRM-933 End 08/11/2021
    //commented 26/05/2022
    /* checkVATNumberMethod(vatNumberToCheck){

        const numeriPari = [];
        const numeriDispari = [];
        let countDispari = 0;
        let countPari = 0;
        let countResult = 0;
        const vatNumberList = vatNumberToCheck.split('');
        for(let indexPari = 1; indexPari<vatNumberList.length; indexPari = indexPari+2){
            numeriPari.push(vatNumberList[indexPari]);
        }
        for(let indexDispari = 0; indexDispari<vatNumberList.length; indexDispari = indexDispari+2){
            numeriDispari.push(vatNumberList[indexDispari]);
        }
        numeriDispari.forEach((sDispari) => {
            countDispari = countDispari + parseInt(sDispari);
        });
        numeriPari.forEach((sPari) => {
            let tmpPari = 0;
            tmpPari = parseInt(sPari) * 2;
            if(tmpPari > 9){
                tmpPari = tmpPari - 9;
            }
            countPari = countPari + tmpPari;
        });
        countResult = countDispari + countPari;
        if(countResult % 10 == 0){
            return true;
        }
        else{
            return false;
        }
    } */

    
}