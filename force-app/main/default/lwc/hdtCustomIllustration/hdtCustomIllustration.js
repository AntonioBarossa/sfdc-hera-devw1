import { LightningElement, api } from 'lwc';

export default class HdtCustomIllustration extends LightningElement {
    @api message;
    @api styleClass;
    @api size;
    illustrationSize = 'slds-illustration slds-illustration_large';

    connectedCallback(){
        if(this.size != undefined || this.size != null){
            this.illustrationSize = 'slds-illustration ' + this.size;
        }
    }

}