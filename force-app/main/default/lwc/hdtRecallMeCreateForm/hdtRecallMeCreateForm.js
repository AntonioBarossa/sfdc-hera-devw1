import {
    LightningElement,
    wire,
    track,
    api
} from 'lwc';
 import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOutboundCampaigns from '@salesforce/apex/HDT_LC_CampaignsController.getOutboundCampaigns';
import createCampaignMemberFromLead from '@salesforce/apex/HDT_LC_RecallMeCreateForm.createCampaignMemberFromLead';
import {getFieldValue, getRecord } from 'lightning/uiRecordApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import SOURCE_AGENCY from '@salesforce/schema/Lead.SourceAgency__c';
import INTEREST_PRODUCT from '@salesforce/schema/Lead.InterestProduct__c';
import MOBILE_PHONE from '@salesforce/schema/Lead.MobilePhone';
const fields = [MOBILE_PHONE];

export default class HdtRecallMeCreateForm extends LightningElement {
    @api recordId;
    @track leadId;
   @track mobilePhone;
    @track sourceAgencyOptions;
    @track interestProductOptions;
    @track sourceAgency;
    @track interestProduct;
    @track campaignOptions = [];
    @track showSpinner = false;


    @wire(getPicklistValues, {recordTypeId: '0121X000001kRdeQAE' , fieldApiName: SOURCE_AGENCY })
    sourceAgencyGetOptions({error, data}) {
        if(data){
            this.sourceAgencyOptions = data.values;
        }
    }  
    @wire(getPicklistValues, {recordTypeId: '0121X000001kRdeQAE' , fieldApiName: INTEREST_PRODUCT  })
    interstProductsGetOptions({error, data}) {
        if(data){
            this.interestProductOptions = data.values;
        }
    }  
     @wire(getRecord, { recordId: '$recordId', fields})
     wiredMobilePhone({error, data}){
        if(data){

            this.mobilePhone = getFieldValue(data, MOBILE_PHONE);

            console.log(this.mobilePhone);

        }else if(error){

            console.log(error);

        }    
    }

    @wire(getOutboundCampaigns) wireCampaign({
        error,
        data
    }) {
        if (error) {
            console.log(JSON.stringify(error));
        } else if (data) {
            console.log(JSON.stringify(data));
            for (var i = 0; i < data.length; i++) {
                let campaign = data[i];
                this.campaignOptions = [...this.campaignOptions, {
                    label: campaign.Name,
                    value: campaign.Id
                }];
            }
        }
    }
  
  
    renderedCallback() {
        console.log(this.recordId);
        this.leadId = this.recordId;
    }

  
 
    handleSubmit(event) {
  
        let sourceAgency = this.template.querySelector('[data-id = "agencyField"]').value;
        let interestProduct = this.template.querySelector('[data-id = "interestProductField"]').value;
        let campaignId = this.template.querySelector('[data-id = "campaignOutboundField"]').value;
        let mobilePhone = this.mobilePhone;
        console.log('prova' + sourceAgency);
        console.log('test' + interestProduct);
       console.log('mobile'+mobilePhone);


     /*  this.dispatchEvent(new ShowToastEvent({
        title: '',
        message: 'Per creare un nuovo Campaign Member devi popolare il campo Mobile del Lead!',
        variant: 'error'
    }));*/

       if(this.mobilePhone.value===null || this.mobilePhone.value===''){
        messageError = 'Per creare un nuovo Campaign Member devi popolare il campo Mobile del Lead!';
        this.dispatchEvent(new ShowToastEvent({
            title: '',
            message: 'Per creare un nuovo Campaign Member devi popolare il campo Mobile del Lead!',
            variant: 'error'
        }));   
    } else {
         createCampaignMemberFromLead({
            leadId: this.recordId,
            sourceAgency: sourceAgency,
            interestProduct: interestProduct,
            campaignId: campaignId,
            mobilePhone: this.mobilePhone

        }).then(result => {
            console.log(JSON.stringify(result));
        }).catch(err => {
            console.log(JSON.stringify(err));
        });
 
        this.showSpinner = false;
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: 'Campaign member created successfully!',
            variant: 'success'
        }));
        dispatchEvent(new CustomEvent('afterSave')); 

    } 
    }
   
       

}