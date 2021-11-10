import { LightningElement, api } from 'lwc';

export default class HdtCampaignMemberScriptLauncher extends LightningElement {

    @api campMemberId;

    showModal() {
        this.template.querySelector('c-hdt-manage-script-modal').showModal();
    }
}