import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class hdtChildOrderProcessHeader extends LightningElement {
    @api order;
    title = '';
    isAccountResidential = false;

    connectedCallback(){
        this.title = 'Order ' + this.order.OrderNumber;
        this.isAccountResidential = this.order.Account.RecordType.DeveloperName === 'HDT_RT_Residenziale';
    }
}