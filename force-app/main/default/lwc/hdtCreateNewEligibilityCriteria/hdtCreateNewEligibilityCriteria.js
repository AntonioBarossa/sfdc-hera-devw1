import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';

export default class HdtCreateNewEligibilityCriteria extends NavigationMixin(LightningElement) {

    @api productid;
    @api eligibilityId;
    showWelcom = true;
    showSearchOffer = false;
    showCreateOffer = false;
    template;

    connectedCallback(){
        console.log('#### productid > ' + this.productid + ' - ' + this.eligibilityId);

        if(this.eligibilityId != null && this.eligibilityId != '' && this.eligibilityId != undefined){
            this.showWelcom = false;
            this.showSearchOffer = false;
            this.showCreateOffer = true;
        }

    }

    @wire(getRecord, { recordId: '$productid', fields: ['Product2.Template__c'] })
    wiredProduct({ error, data }) {
        if (data) {
            console.log('#### template -> ' + data.fields.Template__c.value);
            this.template =  data.fields.Template__c.value;
        } else if (error) {
            for(var key in error){
                console.log('# Error -> ' + key + ' - ' + error[key]);
            }
            
        }
    }

    handleClick(event){
        console.log('### productid -> ' + this.productid);
    }

    closeModal(event){
        console.log('### Parent closeModal ###');
        console.log('### return to-> ' + this.productid);

        const goback = new CustomEvent('goback', {
            detail: {prodId: this.productid}
        });
        // Fire the custom event
        this.dispatchEvent(goback);
        this.eligibilityId = '';
        this.goToRecord(this.productid, 'Product2');

    }

    createNew(event){
        console.log('### Parent createNew ###');
        this.showWelcom = false;
        this.showCreateOffer = true;
    }

    search(event){
        console.log('### Parent search ###');
        this.showWelcom = false;
        this.showSearchOffer = true;
    }

    closeSearch(event){
        this.showWelcom = true;
        this.showSearchOffer = false;
        
        console.log('### return to-> ' + this.productid);
        //this.closeModal();
        this.eligibilityId = '';
        this.goToRecord(this.productid, 'Product2');

    }

    goToRecord(recId, objName){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recId,
                objectApiName: objName,
                actionName: 'view'
            }
        });
    }

}