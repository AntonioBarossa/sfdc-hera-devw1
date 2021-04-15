import { LightningElement, api } from 'lwc';

export default class CampaignsApp extends LightningElement {
    @api objectApiName;
    @api recordId;
    category = 'Campagna CRM';
    channel = '';
    categoryOutbound = 'Campagna Outbound';
    channelOutbound = '';
    handleEmitCampaignId(e) {
        console.log(e.detail.campaignId);
    }
}