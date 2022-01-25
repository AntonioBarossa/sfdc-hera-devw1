import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import disableBotton from '@salesforce/apex/HDT_LC_ConfigurePaymentMethods.disableBotton';
import disableMyButtons from '@salesforce/apex/HDT_LC_ConfigurePaymentMethods.disableMyButtons';
export default class hdtConfigurePaymentMethods extends LightningElement {
    @api saleRecord;
    @api accountId;
    selectedBillingProfile = {};
    loading = false;
    currentStep = 4;
    isCloneButtonDisabled = true;
    disabledInput;
    myInput;


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

    @api 
    getDisabledInput(mySale){
        let result;
        disableMyButtons({mySale}).then(data =>{
            if(data==true){
                this.template.querySelector('c-hdt-create-billing-profile').disableCreate();
                this.template.querySelector('c-hdt-apply-payment-method').disableApply();
                this.template.querySelector('c-hdt-manage-billing-profile').disableManage();
                this.isCloneButtonDisabled = true;
                result = true;
            }else{
                result = false;
            }
        });
    }

    handleNewBillingProfileEvent(){
        this.selectedBillingProfile = {};
        this.template.querySelector('c-hdt-manage-billing-profile').getBillingProfileData();
    }

    handleSelectedBillingProfileEvent(event){
        this.selectedBillingProfile = {};
        this.isCloneButtonDisabled = false;
        this.getDisabledInput(this.saleRecord);
        console.log('*********'+this.disabledInput);
        this.selectedBillingProfile = event.detail;
    }

    handleCloneInit(){
        console.log('handleCloneInit: ', JSON.stringify(this.selectedBillingProfile));
        this.template.querySelector('c-hdt-create-billing-profile').handleCloneEvent(this.selectedBillingProfile.Id);
    }

}