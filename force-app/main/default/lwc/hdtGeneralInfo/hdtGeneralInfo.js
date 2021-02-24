import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateSale from '@salesforce/apex/HDT_LC_GeneralInfo.updateSale';
import getCurrentUserName from '@salesforce/apex/HDT_LC_GeneralInfo.getCurrentUserName';
import SBQQ__TermDiscountSchedule__c from '@salesforce/schema/Product2.SBQQ__TermDiscountSchedule__c';

export default class HdtGeneralInfo extends LightningElement {
    @api saleRecord = {};
    disabledInput = false;
    disabledNext = false;
    hiddenEdit = true;
    loading = false;
    dataToSubmit = {};
    currentStep = 1;
    nextStep = 2;
    currentUserName = '';
    @track isCampaignTableVisible = false;

    get isCampaignVisible(){
        return this.isCampaignTableVisible || this.saleRecord.Campaign__c !== undefined;
    }

    toggle(){
        this.disabledInput = !this.disabledInput;
        this.disabledNext = !this.disabledNext;
        this.hiddenEdit = !this.hiddenEdit;
    }

    handleDataCollection(event){
        this.dataToSubmit[event.target.fieldName] = event.target.value;
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