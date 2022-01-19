import { LightningElement,api } from 'lwc';

export default class HdtAppointmentModal extends LightningElement {
    @api visible; //used to hide/show dialog
    @api title; //modal title
    @api message; //modal message
    @api labelName; // Name of label

    //handles button clicks
    handleClick(event){
        this.dispatchEvent(new CustomEvent('click'));
    }
}