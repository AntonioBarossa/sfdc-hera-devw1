import { LightningElement, api } from 'lwc';
import getFlowCampaign from '@salesforce/apex/HDT_SRV_ScriptManager.getFlowCampaign';

export default class HdtCampaignMemberScriptLauncher extends LightningElement {

    @api campMemberId;
    flowUrl;
    flowFound = false;
    openModal = false;

    showModal() {
        
        // this.template.querySelector('c-hdt-manage-script-modal').showModal();
        this.openModal = true;

        getFlowCampaign({campaignMemberId: this.campMemberId}).then(flowUrl => {
            console.log('flowUrl returned: ' + flowUrl);
            if (flowUrl !== null && flowUrl !== '' && flowUrl !== 'flow not found') {
                this.flowFound = true;
                this.flowUrl = flowUrl;
            }else{
                this.flowFound = false;
            }

            this.isLoading = false;
        },error => {
            console.log(error);
            const evt = new ShowToastEvent({
                title: 'Errore caricamento Script',
                message: 'Non è stato possibile recuperare le informazioni relative agli script',
                variant: 'error'
            });
            this.dispatchEvent(evt);
        });
    }

    closeModal(){
        this.openModal = false;
        this.dispatchEvent(new CustomEvent('close'));
    }
}