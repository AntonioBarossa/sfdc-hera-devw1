import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAccountAndCampaign from '@salesforce/apex/HDT_LC_CampaignsController.getAccountAndCampaign';

export default class hdtNewSaleCampaignMemberCommunity extends NavigationMixin(LightningElement) {
    @api recordId;

    navigateToNewSale() {
        getAccountAndCampaign({ campaignMemberId: this.recordId }).then(data => {
            console.log(JSON.stringify(data));
            if (!data.GenericField1__c) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: '',
                        message: 'Si prega di avviare la vendita direttamente sul Account corretto',
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
                        c__campaignId: data.CampaignId,
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
