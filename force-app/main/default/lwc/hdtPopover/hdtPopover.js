import { LightningElement } from 'lwc';

export default class Popover extends LightningElement {
    closeButton() {
        this.dispatchEvent(new CustomEvent('closepopover'));
    }
}