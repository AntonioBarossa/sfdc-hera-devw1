import { LightningElement, api } from 'lwc';
import updateCampaignMemberStatus from '@salesforce/apex/HDT_LC_CampaignsController.updateCampaignMemberStatus';

export default class NotProposed extends LightningElement {
    @api campaignMemberId;
    status = "Non Proposto";

    handleClick(event) {
        console.log(this.campaignMemberId);
        //update the status
        updateCampaignMemberStatus({ campaignMemberId: this.campaignMemberId, statusValue: this.status }).then(data => {
            console.log("ok" + JSON.stringify(data));
            this.dispatchEvent(new CustomEvent('statusupdate'));
        }).catch(err => {
            console.log(err.body.message);
        });
    }
}