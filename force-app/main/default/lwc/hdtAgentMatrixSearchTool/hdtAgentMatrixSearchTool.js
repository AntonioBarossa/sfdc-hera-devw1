import { LightningElement, api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import getCurrentAgent from '@salesforce/apex/HDT_LC_AgentMatrixSearchToolController.getCurrentAgent';
import getAgentsGrouped from '@salesforce/apex/HDT_LC_AgentMatrixSearchToolController.getAgentsGrouped';
import updateRule from '@salesforce/apex/HDT_LC_AgentMatrixSearchToolController.updateRule';
import getAgents from '@salesforce/apex/HDT_LC_AgentMatrixSearchToolController.getAgents';

// INIZIALMENTE QUESTO CMP DOVEVA USARE IL CODICE AGENTE. E' STATO ROZZAMENTE CONVERTITO PER USARE IL CODICE AGENZIA
export default class HdtAgentMatrixSearchTool extends LightningElement {
    @api recordId;
    @track agentCodes=[];
    @track selectedAgents=[];
    @track showAgents=false;
    @track agentUpdate=[];

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

    connectedCallback() {
        getCurrentAgent({ruleId: this.recordId}).then(result => {    
            this.selectedAgents = [];       
            this.agentCodes = []; 
            this.selectedAgent = result;
            this.selectedAgent.forEach(agent => {
                var singleAgent = {
                    "name":agent.AgencyName__c + ' - ' + agent.AgencyCode__c,
                    "value":agent.AgencyCode__c
                }
                this.selectedAgents.push(singleAgent);
                this.agentCodes.push(agent.AgencyCode__c);
                console.log(this.selectedAgents);
            });
            this.showAgents = true;
        })
    }

    async search(event) {
        if(event.keyCode === 13 && event.target.value) {
            try {
                this.agents = await getAgentsGrouped({queryString: event.target.value});
            } catch(e) {
                console.error(e);
                this.showToast('Errore','Si è verificato un errore. Contattare il supporto tecnico.','error');
            }
        }
    }

    async setAgent(event) {
        this.agentCodes.push(event.currentTarget.dataset.agentcode);
        var codeUpdate = this.agentCodes.join(';');
        var res = await updateRule({ruleId: this.recordId, agentCode: codeUpdate});
        if(res) {
            console.error(res);
            this.showToast('Errore','Si è verificato un errore. Contattare il supporto tecnico.','error');
        } else {
            getRecordNotifyChange([{recordId: this.recordId}]);
            this.agents = null;
            this.template.querySelector(".searchBar").value = null;
            this.connectedCallback();
        }
    }

    async clearAgency() {
        this.setAgent({currentTarget:{dataset:{}}});
    }
    handleClick(event){
        var agentUpdate=[];
        this.selectedAgents = this.selectedAgents.filter(function(agentCod, index, arr){ 
            console.log(agentCod.value + ' ' + event.currentTarget.dataset.id);
            if(agentCod.value != event.currentTarget.dataset.id){
                agentUpdate.push(agentCod.value);
            }
            return agentCod.value != event.currentTarget.dataset.id;
        });
        this.agentCodes = agentUpdate;
        console.log(JSON.stringify(this.selectedAgents));
        if(agentUpdate){
            agentUpdate = agentUpdate.join(';');
        }
        updateRule({ruleId: this.recordId, agentCode: agentUpdate}).then(result => {
            getRecordNotifyChange([{recordId: this.recordId}]);
            this.agents = null;
            this.template.querySelector(".searchBar").value = null;
            this.connectedCallback();
        })
        
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