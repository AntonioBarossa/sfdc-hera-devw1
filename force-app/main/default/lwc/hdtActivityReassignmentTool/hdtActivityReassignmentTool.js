import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecordNotifyChange } from "lightning/uiRecordApi";
import getAssignees from "@salesforce/apex/HDT_LC_ActivityReassignmentTool.getAssignees";
import reassignActivity from "@salesforce/apex/HDT_LC_ActivityReassignmentTool.reassignActivity";
import assignToMe from "@salesforce/apex/HDT_LC_ActivityReassignmentTool.assignToMe";

export default class HdtActivityReassignmentTool extends LightningElement {
    @api recordId;
    assignees;
    assigneesSearched;
    get assigneesFound() {
        return this.assignees ? this.assignees.length > 0 : false;
    }
    get assigneesNotFound() {
        return this.assigneesSearched && !this.assigneesFound;
    }

    connectedCallback() {}

    async handleKeyUp(event) {
        if(event.keyCode === 13 && event.target.value) {
            try {
                this.assigneesSearched = true;
                this.assignees = await getAssignees({queryString: event.target.value});
            } catch (err) {
                console.log("### ERROR: " + err);
            }
        }
    }

    async handleListClick(event) {
        this.handleErrorMessage(await reassignActivity({
            recordId: this.recordId,
            assigneeId: event.currentTarget.dataset.id,
            wrapperId: event.currentTarget.dataset.wrapperid,
            workGroup: event.currentTarget.dataset.workgroup,
            agency: event.currentTarget.dataset.agency
        }));
    }

    async handleButtonClick() {
        this.handleErrorMessage(await assignToMe({recordId: this.recordId}));
    }

    handleErrorMessage(errorMessage) {
        if(errorMessage) {
            if(errorMessage.includes("TRANSFER_REQUIRES_READ")) {
                this.showToast("error", "Riassegnazione fallita", "L'assegnatario selezionato non ha visibilità sul record corrente.");
            } else {
                this.showToast("error", "Errore", errorMessage);
            }
        } else {
            this.showToast("success", "Operazione completata", "Activity riassegnata con successo.");
            this.closeModal();
            this.refreshPage();
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