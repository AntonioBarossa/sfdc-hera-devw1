import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateSale from '@salesforce/apex/HDT_LC_GeneralInfo.updateSale';
import getCurrentUserName from '@salesforce/apex/HDT_LC_GeneralInfo.getCurrentUserName';
import getSaleContactRole from '@salesforce/apex/HDT_LC_GeneralInfo.getSaleContactRole';
export default class HdtGeneralInfo extends LightningElement {
    @api saleRecord = {};
    @api campaignId;
    disabledInput = false;
    disabledNext = false;
    hiddenEdit = true;
    loading = false;
    dataToSubmit = {};
    currentStep = 1;
    nextStep = 2;
    currentUserName = '';
    saleContactRoles = '';
    @track isCampaignTableVisible = false;

    get isCampaignVisible(){
        return this.isCampaignTableVisible || this.saleRecord.Campaign__c !== undefined;
    }

    get isCampaignInputVisible(){
        return this.disabledInput || (this.campaignId !== '' && this.campaignId !== undefined);
    }

    toggle(){
        this.disabledInput = !this.disabledInput;
        this.disabledNext = !this.disabledNext;
        this.hiddenEdit = !this.hiddenEdit;
    }

    handleDataCollection(event){
        this.dataToSubmit[event.target.fieldName] = event.target.value;

        if(event.target.fieldName === 'SalesContact__c'){
            this.saleContactRoles = '';
            getSaleContactRole({accountId: this.saleRecord.Account__c, contactId: event.target.value}).then(data =>{

                if(data[0].Roles !== undefined){
                    this.saleContactRoles = data[0].Roles;
                    this.template.querySelector('[data-name="SalesContactRole__c"]').value = this.saleContactRoles;
                    this.dataToSubmit['SalesContactRole__c'] = this.saleContactRoles;
                } else {
                    this.saleContactRoles = '';
                    this.template.querySelector('[data-name="SalesContactRole__c"]').value = this.saleContactRoles;
                    this.dataToSubmit['SalesContactRole__c'] = this.saleContactRoles;
                }

            }).catch(error => {
                console.log(error.body.message);
                const toastErrorMessage = new ShowToastEvent({
                    title: 'Errore',
                    message: error.body.message,
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(toastErrorMessage);
            });
        }
    }

    initDataToSubmit(){
        this.dataToSubmit['Id'] = this.saleRecord.Id;
        this.dataToSubmit['CurrentStep__c'] = this.nextStep;
    }

    handleEmitCampaignIdEvent(event){
        this.dataToSubmit['Campaign__c'] = event.detail.campaignId;
    }

    handleCampaignVisibility(event){
        this.isCampaignTableVisible = event.detail.isVisible;
    }

    updateSaleRecord(saleData){
        this.loading = true;
        updateSale({sale: saleData}).then(data =>{
            this.loading = false;
            this.dispatchEvent(new CustomEvent('saleupdate'));
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

    setUserName(){
        this.loading = true;
        getCurrentUserName().then(data =>{
            this.loading = false;
            this.currentUserName = data;

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

    handleNext(){
        this.updateSaleRecord(this.dataToSubmit);
        this.toggle();
    }

    handleEdit(){
        this.updateSaleRecord({Id: this.saleRecord.Id, CurrentStep__c: this.currentStep});
        this.toggle();
    }

    connectedCallback(){
        console.log('hdtGeneralInfo - connectedCallback - campaignId: ', this.campaignId);

        //Set CreatedBy of Sale on component mount
        if(this.saleRecord.CreatedBy__c === '' || this.saleRecord.CreatedBy__c === null || this.saleRecord.CreatedBy__c === undefined) {
            this.setUserName();
        } else {
            this.currentUserName = this.saleRecord.CreatedBy__c;
        }

        this.initDataToSubmit();
        if(this.saleRecord.CurrentStep__c != this.currentStep){
            this.toggle();
        }
    }
}