import {
    LightningElement,
    wire,
    track,
    api
} from 'lwc';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import getOutboundCampaigns from '@salesforce/apex/HDT_LC_CampaignsController.getOutboundCampaignsLead';
import createCampaignMemberFromLead from '@salesforce/apex/HDT_LC_RecallMeCreateForm.createCampaignMemberFromLead';
import createCampaignMemberFromContact from '@salesforce/apex/HDT_LC_RecallMeCreateForm.createCampaignMemberFromContact';
import getActivePicklistValues from '@salesforce/apex/HDT_LC_RecallMeCreateForm.getActivePicklistValues';
import {
    getFieldValue,
    getRecord
} from 'lightning/uiRecordApi';
export default class HdtRecallMeCreateForm extends LightningElement {
    @api recordId;
    @api objectApiName;
    @track objName;
    @track leadId;
    @track mobilePhone;
    @track sourceAgencyOptions;
    @track interestProductOptions;
    @track sourceAgency;
    @track interestProduct;
    @track campaignOptions = [];
    @track showSpinner = true;

    @wire(getRecord, {
        recordId: '$recordId',
        fields : ['$objectApiName.MobilePhone']
    })
    wiredMobilePhone({
        error,
        data
    }) {
        if (data) {
            this.mobilePhone = getFieldValue(data, this.objectApiName+'.MobilePhone');            
            console.log(this.mobilePhone);
        } else if (error) {
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

    connectedCallback() {
        console.log('objName ' + this.objectApiName);
        getActivePicklistValues({
            objectapiname: this.objectApiName,
            field : 'SourceAgency__c'
        }).then(data => {
            let options = [];
            data.forEach(elem => {
                options.push({label: elem, value: elem})
            });
            this.sourceAgencyOptions = options;

            getActivePicklistValues({
                objectapiname: this.objectApiName,
                field : 'InterestProduct__c'
            }).then(data => {
                let options = [];
                data.forEach(elem => {
                    options.push({label: elem, value: elem})
                });
                this.interestProductOptions = options;
                this.showSpinner = false;
            });
        });

    }

    handleSubmit(event) {
        this.showSpinner = true; //HRAWRM-640 20/09/2021
        let sourceAgency = this.template.querySelector('[data-id = "agencyField"]').value;
        let interestProduct = this.template.querySelector('[data-id = "interestProductField"]').value;
        let campaignId = this.template.querySelector('[data-id = "campaignOutboundField"]').value;
        let mobilePhone = this.mobilePhone;
        console.log('prova' + sourceAgency);
        console.log('test' + interestProduct);
        console.log('mobile' + mobilePhone);
        if (this.mobilePhone === null || this.mobilePhone === '') {
            console.log('prova te toast');
            this.dispatchEvent(new ShowToastEvent({
                title: '',
                message: 'Per creare un nuovo Campaign Member devi popolare il campo Mobile!',
                variant: 'error'
            }));
            this.dispatchEvent(new CustomEvent('afterSave'));
            this.showSpinner = false; //HRAWRM-640 20/09/2021
        }
        else {
            if (this.objectApiName == "Lead") {
                createCampaignMemberFromLead({
                    leadId: this.recordId,
                    sourceAgency: sourceAgency,
                    interestProduct: interestProduct,
                    campaignId: campaignId,
                    mobilePhone: this.mobilePhone
                }).then(result => {
                    if (result != null) {
                        console.log(JSON.stringify(result));
                        this.showSpinner = false;
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'Success',
                            message: 'Campaign member created successfully!',
                            variant: 'success'
                        }));
                        this.dispatchEvent(new CustomEvent('afterSave'));
                        this.showSpinner = false; //HRAWRM-640 20/09/2021
                    }
                    else {
                        console.log(JSON.stringify(result));
                        this.showSpinner = false;
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'Warning',
                            message: 'Manca la Configurazione per la coppia di valori inseriti',
                            variant: 'warning'
                        }));
                        this.dispatchEvent(new CustomEvent('afterSave'));
                        this.showSpinner = false; //HRAWRM-640 20/09/2021
                    }
                }).catch(err => {
                    console.log(JSON.stringify(err));
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error',
                        message: err.body.message,
                        variant: 'error'
                    }));
                    this.dispatchEvent(new CustomEvent('afterSave'));
                });
            } else if (this.objectApiName == "Contact") {
                createCampaignMemberFromContact({
                    contactId: this.recordId,
                    sourceAgency: sourceAgency,
                    interestProduct: interestProduct,
                    campaignId: campaignId,
                    mobilePhone: this.mobilePhone
                }).then(result => {
                    if (result != null) {
                        console.log(JSON.stringify(result));
                        this.showSpinner = false;
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'Success',
                            message: 'Campaign member created successfully!',
                            variant: 'success'
                        }));
                        this.dispatchEvent(new CustomEvent('afterSave'));
                        this.showSpinner = false; //HRAWRM-640 20/09/2021
                    }
                    else {
                        console.log(JSON.stringify(result));
                        this.showSpinner = false;
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'Warning',
                            message: 'Manca la Configurazione per la coppia di valori inseriti',
                            variant: 'warning'
                        }));
                        this.dispatchEvent(new CustomEvent('afterSave'));
                        this.showSpinner = false; //HRAWRM-640 20/09/2021
                    }
                }).catch(err => {
                    console.log(JSON.stringify(err));
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error',
                        message: err.body.message,
                        variant: 'error'
                    }));
                    this.dispatchEvent(new CustomEvent('afterSave'));
                });
            }
        }
    }
}