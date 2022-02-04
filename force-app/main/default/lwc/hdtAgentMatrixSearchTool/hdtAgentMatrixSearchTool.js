import { LightningElement, api } from 'lwc';
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
                console.log(event.target.value);
                this.agents = await getAgents({queryString: event.target.value});
            } catch(e) {
                console.log(e);
            }
        }
    }
    
    async setAgent(event) {
        var res = await updateRule({ruleId: this.recordId, agentCode: event.target.value});
        if(res) {
            //error
            console.log(res);
        } else {
            this.connectedCallback();
        }
    }

    async clearAgency() {
        this.setAgent({target: {value: null}});
    }
}