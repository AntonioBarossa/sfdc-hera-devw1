import { LightningElement, api } from 'lwc';

export default class hdtConfigurePaymentMethods extends LightningElement {
    @api accountId;

    handleNewBillingProfileEvent(){
        this.template.querySelector('c-hdt-manage-billing-profile').getBillingProfileData();
    }
}