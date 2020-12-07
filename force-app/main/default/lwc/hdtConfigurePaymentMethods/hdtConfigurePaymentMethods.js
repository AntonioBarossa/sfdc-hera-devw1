import { LightningElement, api } from 'lwc';

export default class hdtConfigurePaymentMethods extends LightningElement {
    @api saleRecord;
    @api accountId;
    selectedBillingProfile;

    handleNewBillingProfileEvent(){
        this.template.querySelector('c-hdt-manage-billing-profile').getBillingProfileData();
    }

    handleSelectedBillingProfileEvent(event){
        this.template.querySelector('c-hdt-apply-payment-method').enableApply();
        this.selectedBillingProfile = event.detail;
    }
}