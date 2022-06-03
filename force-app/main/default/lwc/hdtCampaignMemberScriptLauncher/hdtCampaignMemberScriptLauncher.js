import { LightningElement, api } from 'lwc';
import getFlowCampaign from '@salesforce/apex/HDT_SRV_ScriptManager.getFlowCampaign';
import getCommunity from '@salesforce/apex/HDT_LC_ProcessesContainer.isCommunity';
export default class HdtCampaignMemberScriptLauncher extends LightningElement {

    @api campMemberId;
    flowUrl;
    map;
    flowFound = false;
    openModal = false;
    community = false;
    showModal() {

        // this.template.querySelector('c-hdt-manage-script-modal').showModal();
        this.openModal = true;

        getFlowCampaign({campaignMemberId: this.campMemberId}).then(flowUrl => {
            console.log('campid returned: ' + this.campMemberId);
            console.log('flowUrl returned: ' + flowUrl);
            if (flowUrl !== null && flowUrl !== '' && flowUrl !== 'flow not found') {
                this.flowFound = true;
                this.flowUrl = flowUrl;
            }else{
                console.log('flowerror');
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

    
    get setHeight() {
        getCommunity().then(map => {
            console.log('map returned: ' +  JSON.stringify(map));
            if (JSON.stringify(map).indexOf('"isCommunity":false')> -1) {
                this.community = false;   
            }

        },error => {
            console.log(error);
        });
        if(this.community){
            console.log('height: 80%');
            return " max-height: 80rem !important;height: 80% !important;";
        }
        else{
            console.log('height: 50%');
            return " max-height: 80rem !important;height: 50% !important;";
        }
    }

}