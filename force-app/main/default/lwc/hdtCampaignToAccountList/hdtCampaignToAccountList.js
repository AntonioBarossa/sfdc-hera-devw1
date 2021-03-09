import { LightningElement, track, wire, api } from 'lwc';
import getAllCampaigns from '@salesforce/apex/HDT_LC_CampaignsController.getCampaigns';


const columns = [
    { label: 'Campagna', fieldName: 'Name' },
    { label: 'Stato', fieldName: 'Status' },
    { label: 'Canale', fieldName: 'Channel__c' },
    { label: 'Close Date', fieldName: 'EndDate', type: 'date' },
];
export default class PopoverContainer extends LightningElement {
    @api campaignType;
    @api objectApiName;
    @api entityId;
    @track allCampaigns = [];
    @track rowdata;
    @track isSale = false;
    @track selectedCampaignId = null;
    @track campaignsNumber = 0;
    @track listResults = false;
    @wire(getAllCampaigns, { id: '$entityId', objectName: '$objectApiName' }) campaigns({ error, data }) {
        if (error) {
            console.log(error);
        } else if (data) {
            if (data.length !== 0) {
                data.forEach(item => {
                    this.allCampaigns.push(item.Campaign);
                    this.campaignsNumber++;
                });
                this.rowdata = this.allCampaigns;
                this.listResults = true;
                
                //send visibility to parent component
                this.dispatchEvent(new CustomEvent('emitvisibility', {
                    detail: {
                        isVisible: this.listResults
                    }
                }));
            }
        }
    }
    columns = columns;
    connectedCallback() {
        this.isSale = this.campaignType == "sale" ? true : false;
    }

    handleRowSelection(event) {
        this.selectedCampaignId = event.target.selectedRows[0];

        //send selectedCampaignId to parent component
        this.dispatchEvent(new CustomEvent('emitcampaignid', {
            detail: {
                campaignId: this.selectedCampaignId
            }
        }));
    }

    openPopover(e) {
        const campaignId = e.currentTarget.dataset.id;
        const popoverObj = this.template.querySelector(`c-hdt-popover[data-id="${campaignId}"]`);
        if (popoverObj) {
            popoverObj.classList.remove('slds-hide');
        }
    }

    closePopover(e) {
        const campaignId = e.currentTarget.dataset.id;
        const popoverObj = this.template.querySelector(`c-hdt-popover[data-id="${campaignId}"]`);
        if (popoverObj) {
            popoverObj.classList.add('slds-hide');
        }
    }
}