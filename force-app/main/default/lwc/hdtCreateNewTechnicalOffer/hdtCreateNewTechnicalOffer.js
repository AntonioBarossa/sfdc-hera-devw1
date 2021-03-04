import { LightningElement, wire, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import getExistingOffer from '@salesforce/apex/HDT_LC_OfferConfiguratorController.getExistingOffer';

export default class HdtCreateNewTechnicalOffer extends NavigationMixin(LightningElement) {

    showWelcom = false;
    showSearchOffer = false;
    showCreateOffer = false;
    showTable = false;
    @api productid;
    @track technicalOfferId;
    template;

    @track rtObj = {
        id:'',
        label: '',
        value: ''
    };

    @track selectionObj = {
        enableCreate: false,
        hasRecords: false,
        records: []
    };


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
                console.log('# getExistingOffer success #');
                console.log('# offerIsPresent > ' + result.data.offerIsPresent);
                
                if(result.data.offerIsPresent){

                    switch (result.data.tecnicalOfferId.length) {
                        case 1:
                            this.selectionObj.enableCreate = true;
                            break;
                        case 2:
                            this.selectionObj.enableCreate = false;
                    }

                    result.data.tecnicalOfferId.forEach(id => {
                        console.log('>>> id: ' + id);
                        this.selectionObj.records.push(id);
                    });

                    this.selectionObj.hasRecords = true;
                    console.log('>>> ' + this.selectionObj.records.length);

                } else {
                    this.selectionObj.enableCreate = true;
                    this.selectionObj.hasRecords = false;
                }

                this.showWelcom = true;

               //if(result.data.tecnicalOfferId != null && result.data.tecnicalOfferId != '' && result.data.tecnicalOfferId != undefined){
               //    this.technicalOfferId = result.data.tecnicalOfferId;
               //    this.showCreateOffer = true;
               //} else {
               //    this.showWelcom = true;                
               //}

            } else {
                console.log('# tecnicalOfferId not success #');
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
        //this.showTable = true;
    }

    search(event){
        console.log('### Parent search ###');
        this.showWelcom = false;
        this.showSearchOffer = true;
        //this.showTable = true;
    }

    selectoffer(event){
        console.log('### Parent selectoffer ###');
        var techOffId = event.detail;
        console.log('>>> ' + techOffId);
        this.technicalOfferId = techOffId;
        this.showCreateOffer = true;
        this.showWelcom = false; 
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

    handleSelection(event){
        console.log('###');
    }

}