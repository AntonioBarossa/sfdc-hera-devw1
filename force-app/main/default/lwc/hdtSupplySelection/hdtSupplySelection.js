import { LightningElement, api } from 'lwc';

export default class hdtSupplySelection extends LightningElement {
    @api processType;
    @api accountId;
    @api targetObject;
    @api addititionalParam;
    @api saleRecord;
    showCreateTargetObjectButton = false;
    selectedServicePoint;
    @api disabledInput;

    /**
     * Show create button when process is undefined
     */
    connectedCallback(){
        if(this.processType === undefined || this.processType === ''){
            this.showCreateTargetObjectButton = true;
        }
    }
    
    /**
     * Get selected service point
     */
    handleServicePointSelection(event){
        this.selectedServicePoint = event.detail;
        this.dispatchEvent(new CustomEvent('servicepointselectionflow', {
            detail: event.detail
        }));
    }

    /**
     * Dispatch the new created/updated service point to wizard
     */
    handleNewServicePoint(event){
        let newServicePoint = event.detail;
        this.dispatchEvent(new CustomEvent('newservicepoint', {detail: {newServicePoint}}));
    }

    /**
     * Dispatch confirmed service point
     */
    handleConfirmServicePoint(event){
        let servicePoint = event.detail;
        this.dispatchEvent(new CustomEvent('confirmservicepoint', {detail: servicePoint}));
    }

}