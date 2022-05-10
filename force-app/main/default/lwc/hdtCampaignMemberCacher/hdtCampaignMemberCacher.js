import { LightningElement, api } from 'lwc';
import cachePush from '@salesforce/apex/HDT_LC_LeadConversionRedirect.cachePush';

export default class HdtCampaignMemberCacher extends LightningElement {
    @api recordId;

    async connectedCallback() {
        await cachePush({campaignMemberId: this.recordId});
    }
}