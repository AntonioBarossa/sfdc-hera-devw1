import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateCampaignMemberStatusValue from '@salesforce/apex/HDT_LC_CampaignsController.updateCampaignMemberStatus';
import getchannel from '@salesforce/apex/HDT_LC_CampaignsController.getCampaignChannel';
import getPartialOutcomeValues from '@salesforce/apex/HDT_LC_CampaignsController.getOutcomeValues';


export default class HdtCampaignMemberPartialOutcome extends LightningElement {

    @track isModalOpen = false;
    @track value;
    @api campaignMemberId;

    options;

    partialResultClick() {

        getPartialOutcomeValues({'campaignMemberId': this.campaignMemberId , 'outcomeType': 'Esito Parziale'}).then(result => {

            console.log('result --> '+JSON.stringify(result));
            var conts = result;
            for(var key in conts){
                console.log('conts[key] --> '+conts[key]);
                console.log('key --> '+key);
                const option = {
                    label: key,
                    value: conts[key]
                };

                if(this.options != undefined){
                    this.options = [...this.options, option];
                }
                else{
                    this.options = [option];
                }

            }

            console.log('this.options --> '+JSON.stringify(this.options));
        })
        .catch(error => {
            alert(JSON.stringify(error));
        });
    
        this.isModalOpen = true;
    }
    closeModal() {
        this.isModalOpen = false;
    }

    submitDetails() {
        console.log('this.value --> '+this.value);
        updateCampaignMemberStatusValue({ 'campaignMemberId': this.campaignMemberId, 'statusValue': this.value }).then(data => {
            console.log("ok" + JSON.stringify(data));
            this.isModalOpen = false;
            let status = this.value;
            this.dispatchEvent(new CustomEvent('aftersubmit', { detail: {status} }));
        }).catch(err => {
            console.log(err);
        });
    }

    handleChange(event) {
        this.value = event.detail.value;
        console.log(this.value);
    }
}