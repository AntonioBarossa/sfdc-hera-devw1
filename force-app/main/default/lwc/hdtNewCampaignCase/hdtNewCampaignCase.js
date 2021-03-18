import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createNewCase from '@salesforce/apex/HDT_LC_CampaignsController.createNewCase';

export default class HdtNewCampaignCase extends NavigationMixin(LightningElement) {
    @api accountId;
    @api caseCluster;
    @api caseSubProcess;
    @api campaignId;
    caseObj = null;

    connectedCallback() {
        this.caseObj = {
            'Subject': 'PostVendita',
            'AccountId': this.accountId,
            'Cluster__c' : this.caseCluster,
            'Subprocess__c': this.caseSubProcess,
            'Campaign__c' : this.campaignId
        };
    }

    handleNewCase() {
        createNewCase({ c: this.caseObj }).then(data => {
            console.log(JSON.stringify(data));
            //navigate to new created case
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: data.Id,
                    objectApiName: 'Case',
                    actionName: 'view'
                },
            });
        }).catch(error => {
            console.log(error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: `${error.body.pageErrors[0].statusCode}`,
                    message: `${error.body.pageErrors[0].message}`,
                    variant: "error"
                })
            );
        });
    }
}