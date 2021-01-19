import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import controllerInit from '@salesforce/apex/HDT_LC_OrderDossierWizardSignature.controllerInit';
import next from '@salesforce/apex/HDT_LC_OrderDossierWizardSignature.next';

export default class hdtOrderDossierWizardSignature extends LightningElement {
    
    @api orderParentRecord;
    dataToSubmit = {};
    isDisabledSignedDate = true;
    disabledInput = false;
    loading = false;
    isMailVisible = false;
    isAddrVisible = false;
    primaryContactEmail = '';
    accountAddr = '';
    ordChildBpAddr = '';
    addressOptions = [];
    get mailClasses(){
        return this.isMailVisible ? 'slds-size_1-of-2 slds-show' : 'slds-size_1-of-2 slds-hide';
    }

    get addrClasses(){
        return this.isAddrVisible ? 'slds-size_1-of-2 slds-show' : 'slds-size_1-of-2 slds-hide';
    }

    get hiddenEdit(){
        let result = true;
        // if(this.saleRecord.CurrentStep__c <= this.currentStep){
        //     result = true;
        // } else if(this.saleRecord.CurrentStep__c > this.currentStep){
        //     result = false;
        // }

        return result;
    }

    get disabledNext(){
        let result = false;
        // if(this.saleRecord.CurrentStep__c != this.currentStep){
        //     result = true;
        // } else {
        //     result = false;
        // }

        return result;
    }

    // get disabledInput(){
        // let result = false;
        // if(this.saleRecord.CurrentStep__c != this.currentStep){
        //     result = true;
        // } else {
        //     result = false;
        // }

        // return result;
    // }

    outputFormatedAddress(address){

        let streetName = (address.streetName !== undefined && address.streetName !== '')  ? (address.streetName + ' ') : 'ok';
        let streetNumber = (address.streetNumber !== undefined && address.streetNumber !== '') ? (address.streetNumber + ' ') : '';
        let streetNumberExtension = (address.streetNumberExtension !== undefined && address.streetNumberExtension !== '') ? (address.streetNumberExtension + ', ') : '';
        let place = (address.place !== undefined && address.place !== '') ? (address.place + ' ') : '';
        let province = (address.province !== undefined && address.province !== '') ? (address.province + ', ') : '';
        let postalCode = (address.postalCode !== undefined && address.postalCode !== '') ? (address.postalCode + ' ') : '';
        let country = (address.country !== undefined && address.country !== '') ? address.country : '';

        return streetName + streetNumber + streetNumberExtension + place + province + postalCode + country;
    }

    handleDataCollection(event){
        let fieldName = event.target.fieldName;
        let fieldValue = event.target.value;

        this.dataToSubmit[fieldName] = fieldValue;

        if (fieldName === 'ContractSigned__c') {
            this.isDisabledSignedDate = !this.isDisabledSignedDate;
            this.disabledInput = !this.disabledInput;
        }

        if (fieldName === 'DocSendingMethod__c') {
            this.isMailVisible = (fieldValue === 'Mail');
            this.isAddrVisible = (fieldValue === 'Posta');
        }

        if (fieldName === 'SignatureMethod__c'){
            this.isMailVisible = (this.template.querySelector("[data-id='DocSendingMethod__c']").value === 'Mail');
            this.isAddrVisible = (this.template.querySelector("[data-id='DocSendingMethod__c']").value === 'Posta');
        }

        // if (fieldName === 'SignatureMethod__c' && (fieldValue === 'OTP' || fieldValue === 'Stampa')){
        //     this.isAddrVisible = (this.template.querySelector("[data-id='DocSendingMethod__c']").value === 'Posta');
        // }

    }

    handleNext(){
        this.loading = true;
        this.dataToSubmit['Id'] = this.orderParentRecord.Id;
        next({orderUpdates: this.dataToSubmit}).then(data =>{
            this.loading = false;
            
        }).catch(error => {
            this.loading = false;
            console.log(error.body.message);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.body.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    handleFormInit(){
        if (this.orderParentRecord.ContractSigned__c !== undefined) {
            this.isDisabledSignedDate = !this.orderParentRecord.ContractSigned__c;
            this.disabledInput = this.orderParentRecord.ContractSigned__c;
        }

        if (this.orderParentRecord.DocSendingMethod__c === 'Mail') {
            this.isMailVisible = true;
        }
    }

    handleControllerInit(){
        this.loading = true;
        controllerInit({orderParentId: this.orderParentRecord.Id, accountId: this.orderParentRecord.AccountId}).then(data =>{
            this.loading = false;
            this.primaryContactEmail = data.primaryContactEmail;
            this.ordChildBpAddr = data.ordChildList[0].BillingProfile__r;

            this.ordChildBpAddr = this.outputFormatedAddress({
                streetName: data.ordChildList[0].BillingProfile__r.InvoicingStreetName__c,
                streetNumber: data.ordChildList[0].BillingProfile__r.InvoicingStreetNumber__c,
                streetNumberExtension: data.ordChildList[0].BillingProfile__r.InvoicingStreetNumberExtension__c,
                place: data.ordChildList[0].BillingProfile__r.InvoicingPlace__c,
                province: data.ordChildList[0].BillingProfile__r.InvoicingProvince__c,
                postalCode: data.ordChildList[0].BillingProfile__r.InvoicingPostalCode__c,
                country: data.ordChildList[0].BillingProfile__r.InvoicingCountry__c
            });

            if (this.ordChildBpAddr !== '') {
                this.addressOptions.push({label: this.ordChildBpAddr, value: this.ordChildBpAddr});
            }

        }).catch(error => {
            this.loading = false;
            console.log(error.body.message);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.body.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    connectedCallback(){

        this.accountAddr = this.outputFormatedAddress({
            streetName: this.orderParentRecord.Account.BillingAddress.street,
            place: this.orderParentRecord.Account.BillingAddress.city,
            postalCode: this.orderParentRecord.Account.BillingAddress.postalCode,
            country: this.orderParentRecord.Account.BillingAddress.country
        });

        if (this.accountAddr !== '') {
            this.addressOptions.push({'label': this.accountAddr, 'value': this.accountAddr});
        }

        this.handleFormInit();
        this.handleControllerInit();
    }

}