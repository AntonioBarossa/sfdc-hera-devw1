import { api, LightningElement } from 'lwc';

export default class hdtApplyPaymentMethod extends LightningElement {
    
    @api sale;
    buttonDisabled = true;
    showApplyModal = false;
    @api selectedBillingProfile;
    @api disabledInput;

    get isApplyButtonDisabledFinal(){

        if(this.disabledInput){
            return true;
        } else {
            return this.buttonDisabled;
        }
    }

    @api
    enableApply(){
        this.buttonDisabled = false;
    }

    handleApplyClick(){
        this.showApplyModal = true;
    }

    handleCancelApplyEvent(){
        this.showApplyModal = false;
    }
}