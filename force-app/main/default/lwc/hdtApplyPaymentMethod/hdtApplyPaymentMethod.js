import { api, LightningElement } from 'lwc';

export default class hdtApplyPaymentMethod extends LightningElement {
    
    @api sale;
    showApplyModal = false;
    @api selectedBillingProfile;
    @api disabledInput;


    @api
    enableApply(){
        this.disabledInput = false;
    }

    @api
    disableApply(){
        this.disabledInput = true;
    }

    handleApplyClick(){
        this.showApplyModal = true;
    }

    handleCancelApplyEvent(){
        this.showApplyModal = false;
    }
}