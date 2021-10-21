import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecordNotifyChange } from "lightning/uiRecordApi";
import reassignActivity from "@salesforce/apex/HDT_LC_ActivityReassignmentTool.reassignActivity";
import assignToMe from "@salesforce/apex/HDT_LC_ActivityReassignmentTool.assignToMe";
import isDynamicWorkGroup from "@salesforce/apex/HDT_LC_ActivityReassignmentTool.isDynamicWorkGroup";
import getWorkGroups from "@salesforce/apex/HDT_LC_ActivityReassignmentTool.getWorkGroups";
import getCurrentUser from "@salesforce/apex/HDT_LC_ActivityReassignmentTool.getCurrentUser";

export default class HdtActivityReassignToMe extends LightningElement {
    @api recordId;
    currentUser;
    showSearchBar = false;
    workGroups;
    get workGroupsFound() {
        this.workGroups === null || this.workGroups === undefined || this.workGroups.length === 0;
    };
    
    async connectedCallback() {
        try {
            this.currentUser = await getCurrentUser();
            if(await isDynamicWorkGroup({loginChannel: this.currentUser.LoginChannel__c})) {
                this.showSearchBar = true;
            } else {
                this.handleReassignResult(await assignToMe({recordId: this.recordId}));
            }
        } catch (error) {
            console.error(error);
        }
    }

    async handleWorkGroupSearch(event) {
        if(event.keyCode === 13 && event.target.value) {
            try {
                this.workGroups = await getWorkGroups({queryString: event.target.value});
            } catch (err) {
            }
        }
    }

    async selectWorkGroup(event) {
        this.handleReassignResult(await reassignActivity({
            recordId: this.recordId,
            assigneeId: this.currentUser.Id,
            wrapperId: null,
            workGroup: event.currentTarget.dataset.workgroup,
            agency: event.currentTarget.dataset.agency
        }));
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