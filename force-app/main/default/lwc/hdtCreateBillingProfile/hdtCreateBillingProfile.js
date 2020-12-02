import { LightningElement,api } from 'lwc';

export default class hdtCreateBillingProfile extends LightningElement {

    @api accountId;
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