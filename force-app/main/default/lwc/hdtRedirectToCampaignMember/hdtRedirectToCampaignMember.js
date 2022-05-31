import { LightningElement, wire, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import IsConverted from '@salesforce/schema/Lead.IsConverted';
import cachePop from '@salesforce/apex/HDT_LC_LeadConversionRedirect.cachePop';
import campaignMemberCached from '@salesforce/apex/HDT_LC_LeadConversionRedirect.campaignMemberCached';

export default class HdtRedirectToCampaignMember extends LightningElement {
    @api recordId;
    showButton;

    async connectedCallback() {
        this.showButton =  await campaignMemberCached();
    }

    @wire(getRecord, { recordId: '$recordId', fields: [IsConverted] })
    async conversionHandler({ error, data }) {
        if(error) {
            console.error(error);
        } if (data.fields.IsConverted.value) {
            this.handleRedirect();
        }
    }

    async handleRedirect() {
        let id = await cachePop();
        window.open("/HC/s/campaignmember/" + id, "_self");
    }
}