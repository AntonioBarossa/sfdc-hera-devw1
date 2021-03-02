import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class HdtNewCampaignSale extends NavigationMixin(LightningElement) {
    navigateToNewSale() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Sale__c',
                actionName: 'new'
            }
        });
    }
}