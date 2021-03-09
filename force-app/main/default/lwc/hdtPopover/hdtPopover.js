import { LightningElement, api } from 'lwc';

export default class Popover extends LightningElement {
    @api campaignId;
    @api recordId;
    closeButton() {
        this.dispatchEvent(new CustomEvent('closepopover'));
    }
}