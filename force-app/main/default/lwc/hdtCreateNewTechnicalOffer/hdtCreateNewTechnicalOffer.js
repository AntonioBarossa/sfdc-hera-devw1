import { LightningElement, wire, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
//import { getRecord } from 'lightning/uiRecordApi';
import getExistingOffer from '@salesforce/apex/HDT_LC_OfferConfiguratorController.getExistingOffer';

export default class HdtCreateNewTechnicalOffer extends NavigationMixin(LightningElement) {

    @api productid;
    showWelcom = false;
    showSearchOffer = false;
    showCreateOffer = false;
    showEditForm = false;
    //rateTemplate;
    //rateName;
    rateObj;
    newTechOfferObj;
    techOffIdToClone;
    @track technicalOfferId;

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
    productCodeIsAlreadyPresent = false;

    connectedCallback(){
        console.log('#### productid on lwc -> ' + this.productid);
        this.getExistingOfferId();
    }

    //@wire(getRecord, { recordId: '$productid', fields: ['Product2.Template__c'] })
    //wiredProduct({ error, data }) {
    //    if (data) {
    //        console.log('#### template -> ' + data.fields.Template__c.value);
    //        this.template =  data.fields.Template__c.value;
    //    } else if (error) {
    //        for(var key in error){
    //            console.log('# Error -> ' + key + ' - ' + error[key]);
    //        }
    //        
    //    }
    //}

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

                    switch (result.data.tecnicalOffers.length) {
                        case 1:
                            this.selectionObj.enableCreate = true;
                            break;
                        case 2:
                            this.selectionObj.enableCreate = false;
                    }

                    console.log('>>>> ' + JSON.stringify(result.data.tecnicalOffers));

                    result.data.tecnicalOffers.forEach(item => {
                        console.log('>>>  rateName> ' + item.RateCategory__r.Name);
                        var recItem = {id: item.Id, name: item.Name, rateTemp: item.Template__c, rateName: item.RateCategory__r.Name};
                        this.selectionObj.records.push(recItem);
                    });

                    this.selectionObj.hasRecords = true;
                    console.log('>>> ' + this.selectionObj.records.length);

                } else {
                    this.selectionObj.enableCreate = true;
                    this.selectionObj.hasRecords = false;
                }

                this.productCodeIsAlreadyPresent = result.data.productCodeIsAlreadyPresent;
                console.log('>>>>>> productCodeIsAlreadyPresent > ' + this.productCodeIsAlreadyPresent);
                console.log('>>>>>> techOffIdToClone: ' + result.data.techOffIdToClone);
                this.techOffIdToClone = result.data.techOffIdToClone;

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
        console.log('>>> rate id > ' + event.detail.rateId + ' - name > ' + event.detail.rateName + ' - ' + event.detail.rateTemplate);
        this.rateObj = event.detail;
        //this.rateTemplate = event.detail.rateTemplate;
        //this.rateName = event.detail.rateName;
        this.showWelcom = false;

        if(this.productCodeIsAlreadyPresent){
            this.showCreateOffer = true;
        } else {
            this.showEditForm = true;
        }
        
    }

    search(event){
        console.log('### Parent search ###');
        console.log('>>> rate id > ' + event.detail.rateId + ' - name > ' + event.detail.rateName + ' - ' + event.detail.rateTemplate);
        this.rateObj = event.detail;
        //this.rateTemplate = event.detail.rateTemplate;
        //this.rateName = event.detail.rateName;
        this.showWelcom = false;
        this.showSearchOffer = true;
    }

    selectoffer(event){
        console.log('### Parent selectoffer ###');
        var techOffId = event.detail.id;
        console.log('>>> ' + techOffId);

        this.rateObj = {
            rateId: '',
            rateName: event.detail.rate,
            rateTemplate: event.detail.temp,         
        };

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

    handleSelection(){
        console.log('###');
    }

    openEditForm(){
        this.showWelcom = false;
        this.showSearchOffer = false;
        this.showCreateOffer = false;
        this.showEditForm = true;
    }

    newTechOfferCreated(event){
        console.log('>>> newOfferCreated > ' + event.detail.newTechOfferObj);
        this.showEditForm = false;
        this.newTechOfferObj = event.detail.newTechOfferObj;
        this.showCreateOffer = true;
    }

}