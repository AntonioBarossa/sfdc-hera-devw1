import { LightningElement, track, wire, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
import getAllCampaigns from '@salesforce/apex/HDT_LC_CampaignsController.getCampaigns';


const columns = [
    { label: 'Campagna', fieldName: 'Name' },
    { label: 'Stato', fieldName: 'Status' },
    { label: 'Canale', fieldName: 'Channel__c' },
    { label: 'Close Date', fieldName: 'EndDate', type: 'date' },
];
export default class PopoverContainer extends NavigationMixin(LightningElement) {
    @api campaignType;
    @api objectApiName;
    @api entityId;
    @api campaignCategory;
    @api campaignChannel;
    @track allCampaigns = [];
    @track rowdata;
    @track isSale = false;
    @track selectedCampaignId = null;
    @track campaignsNumber = 0;
    @track listResults = false;
    @track campaignsResult = [];

    @wire(getAllCampaigns, { id: '$entityId', objectName: '$objectApiName', category: '$campaignCategory', channel: '$campaignChannel' }) campaigns(result) {
        this.campaignsResult = result;
        this.allCampaigns = [];
        this.campaignsNumber = 0;
        if (result.error) {
            console.log(error);
        } else if (result.data) {
            if (result.data.length !== 0) {
                result.data.forEach(item => {
                    this.allCampaigns.push(item);
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

    handleCampaignsUpdate() {
        refreshApex(this.campaignsResult);
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

    redirectToCampaign(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.getAttribute("data-id"),
                objectApiName: 'CampaignMember',
                actionName: 'view'
            },
        });
    }
}