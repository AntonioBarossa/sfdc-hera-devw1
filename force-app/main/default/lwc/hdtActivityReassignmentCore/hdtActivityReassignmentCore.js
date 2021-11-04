import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecordNotifyChange } from "lightning/uiRecordApi";
import getAssignees from "@salesforce/apex/HDT_LC_ActivityReassignmentTool.getAssignees";
import reassignActivity from "@salesforce/apex/HDT_LC_ActivityReassignmentTool.reassignActivity";
import assignToMe from "@salesforce/apex/HDT_LC_ActivityReassignmentTool.assignToMe";
import isDynamicWorkGroup from "@salesforce/apex/HDT_LC_ActivityReassignmentTool.isDynamicWorkGroup";
import getWorkGroups from "@salesforce/apex/HDT_LC_ActivityReassignmentTool.getWorkGroups";
import getCurrentUser from "@salesforce/apex/HDT_LC_ActivityReassignmentTool.getCurrentUser";

export default class hdtActivityReassignmentCore extends LightningElement {
    @api recordId;
    @api idList;
    @api assignToMeMode;
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

    connectedCallback() {
        if(this.recordId) {
            this.idList = [this.recordId];
        }
        if(this.assignToMeMode) {
            this.handleButtonClick();
        }
    }

    async handleAssigneeSearch(event) {
        if(event.keyCode === 13 && event.target.value) {
            try {
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
        // this.template.querySelector('[data-id="button1"]').classList.toggle('slds-hidden');
    }

    async selectWorkGroup(event) {
        this.handleReassignResult(await reassignActivity({
            idList: this.idList,
            assigneeId: this.assigneeId,
            wrapperId: null,
            workGroup: event.currentTarget.dataset.workgroup,
            agency: event.currentTarget.dataset.agency
        }));
    }

    async handleListClick(event) {
        const dataset = event.currentTarget.dataset;

        if(dataset.wrapperid) {
            this.handleReassignResult(await reassignActivity({
                idList: this.idList,
                assigneeId: dataset.id,
                wrapperId: dataset.wrapperid,
                workGroup: dataset.workgroup,
                agency: dataset.agency
            }));
        } else {
            if(await isDynamicWorkGroup({loginChannel: dataset.loginchannel})) {
                this.toggleWorkGroupSearch(dataset.id);
            } else {
                this.handleReassignResult(await reassignActivity({
                    idList: this.idList,
                    assigneeId: dataset.id,
                    wrapperId: null,
                    workGroup: dataset.workgroup,
                    agency: dataset.agency
                }));
            }
        }
    }

    async handleButtonClick() {
        try {
            const currentUser = await getCurrentUser();
            if(await isDynamicWorkGroup({loginChannel: currentUser.LoginChannel__c})) {
                this.toggleWorkGroupSearch(currentUser.Id);
            } else {
                this.handleReassignResult(await assignToMe({idList: this.idList}));
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
            if(this.recordId) {
                this.refreshPage();
                this.showToast("success", "Operazione completata", "Activity riassegnata con successo.");
                this.closeModal();
            } else {
                window.history.back();
            }
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