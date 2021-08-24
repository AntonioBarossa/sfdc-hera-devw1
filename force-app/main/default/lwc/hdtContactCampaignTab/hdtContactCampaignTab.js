import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';


export default class HdtContactCampaignTab extends NavigationMixin(LightningElement) {
    @api campaignmember;
    @api redirect;
    @track currentId;
    genericRedirect(event){
        console.log('redirect : '+this.redirect);
        console.log(event.currentTarget.dataset.id);
        console.log(event.currentTarget.dataset.name);
        if (this.redirect=='true') {
            console.log('true')
          this.redirectfunction(event);
        }
        else{
            console.log('no redirect')
        }
 
    }
    redirectfunction(obj){
        
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: obj.currentTarget.dataset.id,
                    objectApiName: obj.currentTarget.dataset.name,
                    actionName: 'view'
                },
            });
    }
    
    
}