import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAccountAndCampaign from '@salesforce/apex/HDT_LC_CampaignsController.getAccountAndCampaign';

export default class hdtNewSaleCampaignMemberCommunity extends NavigationMixin(LightningElement) {
    @api recordId;
    CampaignProcessType = '';
    connectedCallback() {
        getAccountAndCampaign({ campaignMemberId: this.recordId }).then(data => {
            console.log(JSON.stringify(data));
            this.CampaignProcessType = data.Campaign.ProcessType__c;
            console.log('CampaignProcessType Sale --> '+this.CampaignProcessType);
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
                this[NavigationMixin.GenerateUrl]({
                    type: "comm__namedPage",
                    attributes: {
                        name: "WizardVendita__c"
                    },
                    state: {
                        c__accountId: data.Contact.AccountId,
                        c__campaignCommissioningId: data.CampaignId,
                        c__campaignMemberId: this.recordId
                    }
                }).then(url => {
                    window.open(url, "_self");
                });
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
        return this.CampaignProcessType == 'Nuovo Caso' || this.CampaignProcessType == '';
    }
}
