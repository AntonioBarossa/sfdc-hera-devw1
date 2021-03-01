import { LightningElement, wire, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import getExistingOffer from '@salesforce/apex/HDT_LC_OfferConfiguratorController.getExistingOffer';

export default class HdtCreateNewTechnicalOffer extends NavigationMixin(LightningElement) {

    showWelcom = false;
    showSearchOffer = false;
    showCreateOffer = false;
    @api productid;
    @track technicalOfferId;
    template;

    connectedCallback(){
        console.log('#### productid on lwc -> ' + this.productid);
        this.getExistingOfferId();
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

    getExistingOfferId(){
        console.log('# getExistingOfferId #');

        //this.spinnerObj.spinner = true;
        //this.spinnerObj.spincss = 'savingdata slds-text-heading_small';

        getExistingOffer({productId: this.productid})
        .then(result => {
            console.log('# getExistingOfferId success #');
            console.log('# resp -> ' + result.success);

            var toastObj = {
                title: '',
                message: '',
                variant: ''
            };

            if(result.success){
                console.log('# tecnicalOfferId success #');
                console.log('# result.offerIsPresent > ' + result.data.offerIsPresent + ' - result.tecnicalOfferId > ' + result.data.tecnicalOfferId);
            } else {
                console.log('# tecnicalOfferId not success #');
            }

            if(result.data.tecnicalOfferId != null && result.data.tecnicalOfferId != '' && result.data.tecnicalOfferId != undefined){
                this.technicalOfferId = result.data.tecnicalOfferId;
                this.showCreateOffer = true;
            } else {
                this.showWelcom = true;                
            }

        }).catch(error => {
            console.log('# tecnicalOfferId error #');
            console.log('# resp -> ' + result.message);
        });
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

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.productid,
                objectApiName: 'Product2',
                actionName: 'view'
            }
        });
        //this.showWelcom = false;
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
        this.closeModal();
        //this[NavigationMixin.Navigate]({
        //    type: 'standard__recordPage',
        //    attributes: {
        //        recordId: this.productid,
        //        objectApiName: 'Product2',
        //        actionName: 'view'
        //    }
        //});

    }

}
