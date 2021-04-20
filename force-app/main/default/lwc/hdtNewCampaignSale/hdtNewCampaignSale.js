import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class HdtNewCampaignSale extends NavigationMixin(LightningElement) {
    @api campaignId;
    @api recordId;

    navigateToNewSale() {
        this[NavigationMixin.Navigate]({
            type: "standard__component",
            attributes: {
                componentName: "c__HDT_LCP_SellingWizard"
            },
            state: {
                c__accountId: this.recordId,
                c__campaignId: this.campaignId,
            }
        });
    }
}