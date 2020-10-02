import { LightningElement } from 'lwc';

export default class HdtTargetObjectCreateForm extends LightningElement {

    closeCreateTargetObjectModal(){
        this.dispatchEvent(new CustomEvent('closecreateform'));
    }
}