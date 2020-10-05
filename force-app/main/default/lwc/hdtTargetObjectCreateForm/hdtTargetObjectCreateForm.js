import { LightningElement, api } from 'lwc';

export default class HdtTargetObjectCreateForm extends LightningElement {
    @api recordtype;

    closeCreateTargetObjectModal(){
        this.dispatchEvent(new CustomEvent('closecreateform'));
    }
}