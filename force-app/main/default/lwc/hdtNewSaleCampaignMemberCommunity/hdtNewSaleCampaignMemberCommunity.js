import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAccountAndCampaign from '@salesforce/apex/HDT_LC_CampaignsController.getAccountAndCampaign';

export default class hdtNewSaleCampaignMemberCommunity extends NavigationMixin(LightningElement) {
    @api recordId;

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
                        c__accountId: data.GenericField1__c,
                        c__campaignCommissioningId: data.CampaignId,
                    }
                }).then(url => {
                    window.open(url, "_blank");
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
}
