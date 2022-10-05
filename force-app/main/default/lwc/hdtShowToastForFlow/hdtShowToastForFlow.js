import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { FlowNavigationNextEvent } from 'lightning/flowSupport';

export default class HdtShowToastForFlow extends LightningElement {

    @api title;
    @api message;
    @api variant;
    @api mode;


    showMessage(title, message, variant, mode) {
        //this.loading=0;
        const toastMessage = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(toastMessage);
    }

    connectedCallback(){

        this.showMessage(this.title, this.message, this.variant, this.mode);
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);

    }

}