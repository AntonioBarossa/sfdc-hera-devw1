import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import disableBotton from '@salesforce/apex/HDT_LC_ConfigurePaymentMethods.disableBotton';
export default class hdtConfigurePaymentMethods extends LightningElement {
    @api saleRecord;
    @api accountId;
    selectedBillingProfile = {};
    loading = false;
    currentStep = 4;
    isCloneButtonDisabled = true;

    get disabledInput(){
        let result = false;
        disableBotton({idAcc:this.accountId,sale:this.saleRecord}).then(data =>{
        if(data==true && this.saleRecord.CurrentStep__c != this.currentStep){

            result = true;
            this.isCloneButtonDisabled = true;
        }else {
            result = false;
        }
    });
        return result;
    }

    handleNewBillingProfileEvent(){
        this.selectedBillingProfile = {};
        this.template.querySelector('c-hdt-manage-billing-profile').getBillingProfileData();
    }

    handleSelectedBillingProfileEvent(event){
        this.selectedBillingProfile = {};
        this.template.querySelector('c-hdt-apply-payment-method').enableApply();
        this.isCloneButtonDisabled = false;
        this.selectedBillingProfile = event.detail;
    }

    handleCloneInit(){
        console.log('handleCloneInit: ', JSON.stringify(this.selectedBillingProfile));
        this.template.querySelector('c-hdt-create-billing-profile').handleCloneEvent(this.selectedBillingProfile.Id);
    }

}