import { LightningElement, api } from 'lwc';

export default class hdtSupplySelection extends LightningElement {
    @api processType;
    @api accountId;
    @api targetObject;
    @api addititionalParam;
    @api saleRecord;
    showCreateTargetObjectButton = false;
    selectedServicePoint;

    /**
     * Show create button when process is undefined
     */
    connectedCallback(){
        console.log('hdtSupplySelection: ' + JSON.stringify(this.saleRecord));
        if(this.processType === undefined || this.processType === ''){
            this.showCreateTargetObjectButton = true;
        }
    }
    
    /**
     * Get selected service point
     */
    handleServicePointSelection(event){
        this.selectedServicePoint = event.detail;
    }

    /**
     * Dispatch the new created service point to wizard
     */
    handleNewServicePoint(event){
        let newServicePoint = event.detail;
        this.dispatchEvent(new CustomEvent('newservicepoint', {detail: {newServicePoint}}));
    }
}