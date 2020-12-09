import { LightningElement,api } from 'lwc';

export default class hdtCreateBillingProfile extends LightningElement {

    @api accountId;
    @api disabledInput;
    showForm = false;

    handleCreateEvent(){
        this.showForm = true;
    }

    handleCancelEvent(){
        this.showForm = false;
    }

    handleNewBillingProfileEvent(){
        this.dispatchEvent(new CustomEvent('newbillingprofile'));
    }
}