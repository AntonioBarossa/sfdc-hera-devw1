import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class HdtNewCampaignSale extends NavigationMixin(LightningElement) {
    @api campaignId;
    @api recordId;
    @api campaignMemberId;

    navigateToNewSale() {
        console.log('campaignMemberId --> '+this.campaignMemberId);
        this[NavigationMixin.Navigate]({
            type: "standard__component",
            attributes: {
                componentName: "c__HDT_LCP_SellingWizard"
            },
            state: {
                c__accountId: this.recordId,
                c__campaignId: this.campaignId,
                c__campaignMemberId: this.campaignMemberId
            }
        });
    }
}