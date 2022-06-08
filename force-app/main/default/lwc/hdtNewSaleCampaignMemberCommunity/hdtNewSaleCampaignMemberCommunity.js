import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAccountAndCampaign from '@salesforce/apex/HDT_LC_CampaignsController.getAccountAndCampaign';
import getAlternativeAccount from '@salesforce/apex/HDT_LC_CampaignsController.getAccountId';

export default class hdtNewSaleCampaignMemberCommunity extends NavigationMixin(LightningElement) {
    @api recordId;
    CampaignProcessType = '';
    accountId='';
    isFromLead=false;
    connectedCallback() {
        getAccountAndCampaign({ campaignMemberId: this.recordId }).then(data => {
            console.log(JSON.stringify(data));
            this.CampaignProcessType = data.Campaign.ProcessType__c;
            console.log('CampaignProcessType Sale --> '+this.CampaignProcessType);
            if(data.ContactId != null && data.ContactId != undefined && data.ContactId != ''){
                this.isFromLead = false;
            }else if(data.LeadId != null && data.LeadId != undefined && data.LeadId != ''){
                this.isFromLead = true;
            }
        }).catch(error => {
            console.log(error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: `${error.status}`,
                    message: `${error.body.message}`,
                    variant: "error"
                })
            );
        });
    }
    navigateToNewSale() {
        getAccountAndCampaign({ campaignMemberId: this.recordId }).then(data => {
            console.log(JSON.stringify(data));
            if(data.ContactId != null && data.ContactId != undefined && data.ContactId != ''){
                this.isFromLead = false;
            }else if(data.LeadId != null && data.LeadId != undefined && data.LeadId != ''){
                this.isFromLead = true;
            }
            if (!data.Contact.AccountId) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: '',
                        message: 'Per procedere con la vendita si richiede di andare nel Account e procedere con Catalogo servizi', //HRAWRM-626 22/09/2021 EC
                        variant: "error"
                    })
                );
            } else {
                //navigate to new sale
                getAlternativeAccount({ campaignMemberId: this.recordId }).then(res => {
                    console.log('krist: '+res);
                    if(res){
                        this.accountId=res;
                    }
                    else {
                        this.accountId=data.Contact.AccountId;

                    }
                    console.log('KKKKKKK: '+this.accountId);

                    this[NavigationMixin.GenerateUrl]({
                        type: "comm__namedPage",
                        attributes: {
                            name: "WizardVendita__c"
                        },
                        state: {
                            c__accountId: this.accountId,
                            c__campaignCommissioningId: data.CampaignId,
                            c__campaignMemberId: this.recordId
                        }
                    }).then(url => {
                        window.open(url, "_self");
                    });

                }).catch(error => {
                    console.log(error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: `${error.status}`,
                            message: `${error.body.message}`,
                            variant: "error"
                        })
                    );
                });
               /* this[NavigationMixin.GenerateUrl]({
                    type: "comm__namedPage",
                    attributes: {
                        name: "WizardVendita__c"
                    },
                    state: {
                        c__accountId: this.accountId,
                        c__campaignCommissioningId: data.CampaignId,
                        c__campaignMemberId: this.recordId
                    }
                }).then(url => {
                    window.open(url, "_self");
                });*/
            }
        }).catch(error => {
            console.log(error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: `${error.status}`,
                    message: `${error.body.message}`,
                    variant: "error"
                })
            );
        });
    }

    get manageDisable(){
        return this.CampaignProcessType == 'Nuovo Caso' || this.CampaignProcessType == '' || this.isFromLead;
    }
}