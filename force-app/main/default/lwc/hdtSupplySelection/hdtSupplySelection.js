import { LightningElement, api, track } from 'lwc';

export default class hdtSupplySelection extends LightningElement {
    @api processType;
    @api accountId;
    @api targetObject;
    @api addititionalParam;
    showCreateTargetObjectButton = false;
    selectedServicePoint;

    connectedCallback(){
        if(this.processType === undefined || this.processType === ''){
            this.showCreateTargetObjectButton = true;
        }
    }

    handleServicePointSelection(event){
        this.selectedServicePoint = event.detail;
    }
}