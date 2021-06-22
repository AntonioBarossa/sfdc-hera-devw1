import { LightningElement, api, track } from 'lwc';

export default class Popover extends LightningElement {
    @api campaignId;
    @api recordId;
    @api campaignMemberId;
    @api processType;
    @api caseCluster;
    @api caseType;
    @track showNewCaseButton;
    @track showNewSaleButton;

    statusUpdate() {
        this.dispatchEvent(new CustomEvent('statusupdate'));
    }

    connectedCallback() {
        switch (this.processType) {
            case 'Nuovo Caso':
                this.showNewCaseButton = true;
                break;
            case 'Nuova Vendita':
                this.showNewSaleButton = true;
                break;
            case 'Entrambi':
                this.showNewCaseButton = true;
                this.showNewSaleButton = true;
                break;

            default:
                break;
        }
    }
}