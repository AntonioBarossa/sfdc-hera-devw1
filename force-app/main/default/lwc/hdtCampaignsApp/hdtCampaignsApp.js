import { LightningElement, api } from 'lwc';

export default class CampaignsApp extends LightningElement {
    @api objectApiName;
    @api recordId;
    handleEmitCampaignId(e) {
        console.log(e.detail.campaignId);
    }
}