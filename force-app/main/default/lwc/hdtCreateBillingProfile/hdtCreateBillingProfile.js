import { LightningElement,api } from 'lwc';

export default class hdtCreateBillingProfile extends LightningElement {

    @api sale;
    @api accountId;
    @api disabledInput;
    showForm = false;
    recordId = '';

    @api
    handleCloneEvent(cloneId){
        console.log('handleCloneEvent: ', cloneId);
        this.showForm = true;
        this.recordId = cloneId;
    }

    handleCreateEvent(){
        this.recordId = '';
        this.showForm = true;
    }

    handleCancelEvent(){
        this.showForm = false;
    }

    handleNewBillingProfileEvent(){
        this.dispatchEvent(new CustomEvent('newbillingprofile'));
    }
}