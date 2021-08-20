import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecordNotifyChange } from "lightning/uiRecordApi";
import getAssignees from "@salesforce/apex/HDT_LC_ActivityReassignmentTool.getAssignees";
import reassignActivity from "@salesforce/apex/HDT_LC_ActivityReassignmentTool.reassignActivity";
import assignToMe from "@salesforce/apex/HDT_LC_ActivityReassignmentTool.assignToMe";
import isDynamicWorkGroup from "@salesforce/apex/HDT_LC_ActivityReassignmentTool.isDynamicWorkGroup";
import getWorkGroups from "@salesforce/apex/HDT_LC_ActivityReassignmentTool.getWorkGroups";
import getCurrentUser from "@salesforce/apex/HDT_LC_ActivityReassignmentTool.getCurrentUser";

export default class HdtActivityReassignmentTool extends LightningElement {
    @api recordId;
    workGroups;
    assignees;
    assigneeId;
    get searchingWorkGroup() {
        return (this.assigneeId != undefined);
    }
    assigneesSearched;
    get assigneesFound() {
        return this.assignees ? this.assignees.length > 0 : false;
    }
    get assigneesNotFound() {
        return this.assigneesSearched && !this.assigneesFound;
    }

    connectedCallback() {}

    async handleAssigneeSearch(event) {
        if(event.keyCode === 13 && event.target.value) {
            try {
                console.log('b');
                this.assignees = await getAssignees({queryString: event.target.value});
                this.assigneesSearched = true;
            } catch (err) {
                console.log("### ERROR: " + err);
            }
        }
    }

    async handleWorkGroupSearch(event) {
        if(event.keyCode === 13 && event.target.value) {
            try {
                console.log('a');
                this.workGroups = await getWorkGroups({queryString: event.target.value});
            } catch (err) {
                console.log("### ERROR: " + err);
            }
        }
    }

    toggleWorkGroupSearch(agentId) {
        this.assignees = undefined;
        this.assigneesSearched = false;
        this.assigneeId = agentId;
        this.template.querySelector('[data-id="button1"]').classList.toggle('slds-hidden');
    }

    async selectWorkGroup(event) {
        console.log('d');
        console.log(event.currentTarget.dataset.workgroup);
        console.log(event.currentTarget.dataset.agency);
        this.handleReassignResult(await reassignActivity({
            recordId: this.recordId,
            assigneeId: this.assigneeId,
            wrapperId: null,
            workGroup: event.currentTarget.dataset.workgroup,
            agency: event.currentTarget.dataset.agency
        }));
    }

    async handleListClick(event) {
        const dataset = event.currentTarget.dataset;
        console.log(dataset.id);
        console.log(dataset.wrapperid);
        console.log(dataset.workgroup);
        console.log(dataset.agency);
        console.log('c');

        console.log('1' + this.assigneeId);
        console.log('2' + this.recordId);
        if(dataset.wrapperid) {
            console.log(5);
            this.handleReassignResult(await reassignActivity({
                recordId: this.recordId,
                assigneeId: dataset.id,
                wrapperId: dataset.wrapperid,
                workGroup: dataset.workgroup,
                agency: dataset.agency
            }));
            console.log(6);
        } else {
            if(await isDynamicWorkGroup({loginChannel: dataset.loginchannel})) {
                console.log(7);
                this.toggleWorkGroupSearch(dataset.id);
                console.log(8);
            } else {
                console.log(9);
                this.handleReassignResult(await reassignActivity({
                    recordId: this.recordId,
                    assigneeId: dataset.id,
                    wrapperId: null,
                    workGroup: dataset.workgroup,
                    agency: dataset.agency
                }));
                console.log(10);
            }
        }
    }

    async handleButtonClick() {
        try {
            const currentUser = await getCurrentUser();
            if(await isDynamicWorkGroup({loginChannel: currentUser.LoginChannel__c})) {
                this.toggleWorkGroupSearch(currentUser.Id);
            } else {
                this.handleReassignResult(await assignToMe({recordId: this.recordId}));
            }
        } catch (error) {
            console.error(error);
        }
    }

    handleReassignResult(errorMessage) {
        if(errorMessage) {
            if(errorMessage.includes("TRANSFER_REQUIRES_READ")) {
                this.showToast("error", "Riassegnazione fallita", "L'assegnatario selezionato non ha visibilità sul record corrente.");
            } else {
                this.showToast("error", "Errore", errorMessage);
            }
        } else {
            this.refreshPage();
            this.showToast("success", "Operazione completata", "Activity riassegnata con successo.");
            this.closeModal();
        }
    }

    toggleHoveredClass(event) {
        this.template.querySelector(`[data-id="${event.currentTarget.dataset.id}"]`).classList.toggle("hovered");
    }

    refreshPage() {
        getRecordNotifyChange([{recordId: this.recordId}]);
    }

    closeModal() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    showToast(variant, title, message) {
        this.dispatchEvent(new ShowToastEvent({
            variant: variant,
            title: title,
            message: message
        }));
    }
}