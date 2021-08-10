import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';


export default class HdtContactTab extends NavigationMixin(LightningElement) {
    @api accountcontactrel;
    @track currentId;
    genericRedirect(event){
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