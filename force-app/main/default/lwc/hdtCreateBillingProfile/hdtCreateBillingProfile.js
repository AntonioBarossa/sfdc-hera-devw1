import { LightningElement } from 'lwc';

export default class hdtCreateBillingProfile extends LightningElement {

    showForm = false;

    handleCreateEvent(){
        this.showForm = true;
    }

    handleCancelEvent(){
        this.showForm = false;
    }
}