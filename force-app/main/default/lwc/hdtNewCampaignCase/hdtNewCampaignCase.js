import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class HdtNewCampaignCase extends NavigationMixin(LightningElement) {
    navigateToNewCase() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Case',
                actionName: 'new'
            }
        });
        console.log('newCase');
    }
}