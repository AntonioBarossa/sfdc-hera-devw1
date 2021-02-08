import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class hdtChildOrderProcessHeader extends LightningElement {
    @api order;
    title = '';

    connectedCallback(){
        this.title = 'Order ' + this.order.OrderNumber;
    }
}