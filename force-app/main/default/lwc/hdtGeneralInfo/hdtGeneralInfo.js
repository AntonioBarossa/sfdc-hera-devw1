import { LightningElement, api } from 'lwc';

export default class HdtGeneralInfo extends LightningElement {
    @api saleRecord;
    disabledInput = false;
    disabledNext = false;
    hiddenEdit = true;

    toggle(){
        this.disabledInput = !this.disabledInput;
        this.disabledNext = !this.disabledNext;
        this.hiddenEdit = !this.hiddenEdit;
    }

    handleNext(){
        this.toggle();
    }

    handleEdit(){
        this.toggle();
    }
}