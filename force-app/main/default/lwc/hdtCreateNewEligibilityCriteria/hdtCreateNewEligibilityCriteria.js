import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import getExistingCriteria from '@salesforce/apex/HDT_LC_EligibilityCriteriaController.getExistingCriteria';
import mainTitle from '@salesforce/label/c.HDT_LWC_CreateNewCriteria_MainTitle';
import newTitleLabel from '@salesforce/label/c.HDT_LWC_CreateNewCriteria_NewTitleLabel';
import searchTitleLabel from '@salesforce/label/c.HDT_LWC_CreateNewCriteria_SearchTitleLabel';

export default class HdtCreateNewEligibilityCriteria extends NavigationMixin(LightningElement) {

    label = {
        mainTitle,
        newTitleLabel,
        searchTitleLabel
    };

    @api productid;
    //@api eligibilityId;
    eligibilityId;
    showWelcom = false;
    showSearchOffer = false;
    showCreateOffer = false;
    template;
    showError = false;
    errorHeader = '';
    errorMessage = '';

    connectedCallback(){
        console.log('#### productid > ' + this.productid + ' - ' + this.eligibilityId);
        this.getEligibilityId();
        //if(this.eligibilityId != null && this.eligibilityId != '' && this.eligibilityId != undefined){
        //    this.showWelcom = false;
        //    this.showSearchOffer = false;
        //    this.showCreateOffer = true;
        //}

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

    getEligibilityId(){
        console.log('# getEligibilityId #');

        //this.spinnerObj.spinner = true;
        //this.spinnerObj.spincss = 'savingdata slds-text-heading_small';

        getExistingCriteria({productId: this.productid})
        .then(result => {
            console.log('# getEligibilityId success #');
            console.log('# resp -> ' + result.success);

            var toastObj = {
                title: '',
                message: '',
                variant: ''
            };

            if(result.success){
                console.log('# getEligibilityId success #');
                console.log('# result.recIsPresent > ' + result.recIsPresent + ' - result.eligibilityId > ' + result.eligibilityId);

                if(result.eligibilityId != null && result.eligibilityId != '' && result.eligibilityId != undefined){
                    this.eligibilityId = result.eligibilityId;
                    this.showCreateOffer = true;
                } else {
                    this.showWelcom = true;                
                }

            } else {
                console.log('# getEligibilityId not success #');
                this.showError = true;
                this.errorHeader = 'Eleggibilità';
                this.errorMessage = result.message;
            }



        }).catch(error => {
            console.log('# getEligibilityId error #');
            console.log('# resp -> ' + result.message);
            this.showError = true;
            this.errorHeader = 'Eleggibilità';
            this.errorMessage = result.message;
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