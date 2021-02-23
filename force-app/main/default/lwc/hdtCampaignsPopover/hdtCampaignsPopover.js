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
    @api objectName;
    @api entityId;
    @track allCampaigns = [];
    @track rowdata;
    @track isSale = false;
    @track isLayout = !this.isSale;
    @track selectedCampaignId = null;
    @track campaignsNumber = 0;
    @wire(getAllCampaigns, {id: '$entityId', objectName: '$objectName'}) campaigns({ error, data }) {
        if (error) {
            console.log(error);
        } else if (data) {
            data.forEach(item => {
                this.allCampaigns.push(item.Campaign);
                this.campaignsNumber++;
            });
            this.rowdata = this.allCampaigns;
            console.log(JSON.stringify(this.rowdata));
        }
    }
    columns = columns;
    connectedCallback() {
        this.isSale = this.campaignType == "sale" ? true : false;
        this.isLayout = !this.isSale;
    }

    handleRowSelection(event) {
        //handle single-selection
        var el = this.template.querySelector('lightning-datatable[data-id="campaignsDT"]');
        if (el.selectedRows.length > 1) {
            event.preventDefault();
            el.selectedRows = el.selectedRows.slice(1);
        }
        this.selectedCampaignId = el.selectedRows[0];

        console.log(this.selectedCampaignId);
        this.dispatchEvent(new CustomEvent('emitcampaignid', {detail:{
            campaignId: this.selectedCampaignId
        }}));
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