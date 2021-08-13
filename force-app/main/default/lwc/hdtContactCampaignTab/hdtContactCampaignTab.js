import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';


export default class HdtContactCampaignTab extends NavigationMixin(LightningElement) {
    @api campaignmember;
    @api noredirect=false;
    @track currentId;
    genericRedirect(event){
        if (!noRedirect) {
            console.log(event.currentTarget.dataset.id);
            console.log(event.currentTarget.dataset.name);
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: event.currentTarget.dataset.id,
                    objectApiName: event.currentTarget.dataset.name,
                    actionName: 'view'
                },
            });
        }
        
        
        
        
    }
}