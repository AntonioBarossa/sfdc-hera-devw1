import { LightningElement, api } from 'lwc';

export default class hdtConfigurePaymentMethods extends LightningElement {
    @api saleRecord;
    @api accountId;
    selectedBillingProfile;
    disabledInput = false;
    disabledNext = false;
    hiddenEdit = true;

    handleNewBillingProfileEvent(){
        this.template.querySelector('c-hdt-manage-billing-profile').getBillingProfileData();
    }

    handleSelectedBillingProfileEvent(event){
        this.template.querySelector('c-hdt-apply-payment-method').enableApply();
        this.selectedBillingProfile = event.detail;
    }

    toggle(){
        this.disabledInput = !this.disabledInput;
        this.disabledNext = !this.disabledNext;
        this.hiddenEdit = !this.hiddenEdit;
    }

    handleNext(){
        this.toggle();
    }

    handleEdit(){
        this.toggle();
    }
}