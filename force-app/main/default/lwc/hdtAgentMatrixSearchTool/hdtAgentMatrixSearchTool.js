import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCurrentAgent from '@salesforce/apex/HDT_LC_AgentMatrixSearchToolController.getCurrentAgent';
import updateRule from '@salesforce/apex/HDT_LC_AgentMatrixSearchToolController.updateRule';
import getAgents from '@salesforce/apex/HDT_LC_AgentMatrixSearchToolController.getAgents';


export default class HdtAgentMatrixSearchTool extends LightningElement {
    @api recordId;

    selectedAgent;
    get agentSet() {
        return this.selectedAgent;
    };
    get agentNotSet() {
        return !this.selectedAgent;
    };

    agents;
    get agentsFound(){
        return this.agents;
    }

    async connectedCallback() {
        this.selectedAgent = await getCurrentAgent({ruleId: this.recordId});
    }

    async search(event) {
        if(event.keyCode === 13 && event.target.value) {
            try {
                this.agents = await getAgents({queryString: event.target.value});
            } catch(e) {
                console.error(e);
                this.showToast('Errore','Si è verificato un errore. Contattare il supporto tecnico.','error');
            }
        }
    }

    async setAgent(event) {
        var res = await updateRule({ruleId: this.recordId, agentCode: event.currentTarget.dataset.agentcode});
        if(res) {
            console.error(res);
            this.showToast('Errore','Si è verificato un errore. Contattare il supporto tecnico.','error');
        } else {
            this.agents = null;
            this.template.querySelector(".searchBar").value = null;
            this.connectedCallback();
        }
    }

    async clearAgency() {
        this.setAgent({currentTarget:{dataset:{}}});
    }

    showToast(title,message,variant = 'info') {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'sticky'
        }));
    }
}