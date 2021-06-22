import { LightningElement, api } from 'lwc';

export default class CampaignsApp extends LightningElement {
    @api objectApiName;
    @api recordId;
    @api campaignCategory;
    category = this.campaignCategory ? this.campaignCategory : 'Campagna CRM';
    channel = '';
    // categoryOutbound = 'Campagna Outbound';
    // channelOutbound = '';
    handleEmitCampaignId(e) {
        console.log(e.detail.campaignId);
    }
    connectedCallback() {
        console.log(this.objectApiName);
        console.log(this.recordId);
    }
}