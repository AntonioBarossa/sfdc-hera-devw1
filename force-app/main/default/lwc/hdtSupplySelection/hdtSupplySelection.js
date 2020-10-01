import { LightningElement, api } from 'lwc';

export default class hdtSupplySelection extends LightningElement {
    @api processType;
    @api accountId;
    @api targetObject;
    @api addititionalParam;
    showCreateTargetObjectButton = false;

    connectedCallback(){
        if(this.processType === undefined || this.processType === ''){
            this.showCreateTargetObjectButton = true;
        }
    }
}