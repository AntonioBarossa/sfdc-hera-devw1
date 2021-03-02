import { LightningElement, api } from 'lwc';

export default class CampaignsApp extends LightningElement {
    handleEmitCampaignId(e) {
        console.log(e.detail.campaignId);
    }
}