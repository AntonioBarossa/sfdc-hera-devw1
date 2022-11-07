import { LightningElement, api, wire, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecordNotifyChange } from "lightning/uiRecordApi";
import getAssignees from "@salesforce/apex/HDT_LC_ActivityReassignmentTool.getAssignees";
import getRefreshPage from "@salesforce/apex/HDT_LC_ActivityReassignmentTool.refreshPage";
import reassignActivity from "@salesforce/apex/HDT_LC_ActivityReassignmentTool.reassignActivity";
import assignToMe from "@salesforce/apex/HDT_LC_ActivityReassignmentTool.assignToMe";
import isDynamicWorkGroup from "@salesforce/apex/HDT_LC_ActivityReassignmentTool.isDynamicWorkGroup";
import getWorkGroups from "@salesforce/apex/HDT_LC_ActivityReassignmentTool.getWorkGroups";
import getCurrentUser from "@salesforce/apex/HDT_LC_ActivityReassignmentTool.getCurrentUser";
import getPickListValuesIntoList from "@salesforce/apex/HDT_LC_ActivityReassignmentTool.getPickListValuesIntoList";



export default class hdtActivityReassignmentCore extends LightningElement {
    @api recordId;
    @api idList;
    @api assignToMeMode;
    workGroups;
    assignees;
    assigneeId;
    showSpinner;
    agencyPicklistValues = [];
    agencyValue;

    status = {
        error: false
    };
    refreshPageInTheEnd = false;
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
    get showBackButton() {
        return this.recordId == null;
    }

    

    connectedCallback() {
        this.getRefresPageByType();
        if(this.recordId) {
            this.idList = [this.recordId];
        }
        if(!this.idList[0]) {
            this.handleListButtonError("ATTENZIONE", "Nessun record selezionato.");
        }
        if(this.assignToMeMode) {
            this.doAssignToMe();
        }

        getPickListValuesIntoList({})
        .then(data => 
            {
                let options = [];
                if (data) {
                    data.forEach(val => {
                    options.push({
                    label: val,
                    value: val,
                    });
                });
                }
                this.agencyPicklistValues = options;
            });


    }

    handleAgencyChange(event) {

        this.template.querySelector('[data-id="agency"]').value = event.target.value;
        console.log('nuovo valore ' + this.template.querySelector('[data-id="agency"]').value);

        this.agencyValue = this.template.querySelector('[data-id="agency"]').value;

    }

    async getRefresPageByType(){
        this.refreshPageInTheEnd = await getRefreshPage({recordId : this.recordId});
    }

    async handleAssigneeSearch(event) {
        if(event.keyCode === 13 && event.target.value) {
            try {
                this.assignees = await getAssignees({queryString: event.target.value});
                this.assigneesSearched = true;
            } catch (err) {
                console.error(err);
                this.handleListButtonError("ERRORE", err);
            }
        }
    }

    async handleWorkGroupSearch(event) {
        console.log('this.agencyValue --> '+this.agencyValue);
        console.log('event.keyCode --> '+event.keyCode);
        console.log('event.target.value --> '+event.target.value);
        if(event.keyCode === 13 && event.target.value) {
            try {
                console.log('BEFORE WORKGROUPS');
                this.workGroups = await getWorkGroups({queryString: event.target.value, agency: this.agencyValue});
                console.log('this.workGroups --> '+this.workGroups);
            } catch (err) {
                console.error(err);
                this.handleListButtonError("ERRORE", err);
            }
        }
    }

    toggleWorkGroupSearch(agentId) {
        this.assignees = undefined;
        this.assigneesSearched = false;
        this.assigneeId = agentId;
    }

    async selectWorkGroup(event) {
        this.showSpinner = true;
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
            this.showSpinner = true;
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
                this.showSpinner = true;
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

    async doAssignToMe() {
        try {
            this.showSpinner = true;
            const currentUser = await getCurrentUser();
            if(await isDynamicWorkGroup({loginChannel: currentUser.LoginChannel__c})) {
                this.showSpinner = false;
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
            if(errorMessage.includes("TRANSFER_REQUIRES_READ") || errorMessage.includes("INSUFFICIENT_ACCESS_OR_READONLY")) {
                errorMessage = "L'utente a cui si è selezionato non dispone dei permessi sufficenti su uno o più record che si è cercato di riassegnare.";
            }

            if(this.recordId) {
                this.showToast("error", "Errore", errorMessage);
                this.closeModal();
            } else {
                this.handleListButtonError("ERRORE", errorMessage);
            }
        } else {
            if(this.recordId) {
                this.refreshPage();
                this.showToast("success", "Operazione completata", "Activity riassegnata con successo.");
                this.closeModal();
                if (this.refreshPageInTheEnd === true || this.refreshPageInTheEnd ==='true'){
                    this.dispatchEvent(new CustomEvent('assignerupdated'));
                }
            } else {
                this.goBack();
            }
        }
    }

    toggleHoveredClass(event) {
        this.template.querySelector(`[data-id="${event.currentTarget.dataset.id}"]`).classList.toggle("hovered");
    }

    // MODAL

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

    // LIST BUTTONS

    handleListButtonError(title, message) {
        this.status = {
            error: true,
            title: title,
            message: message
        };
    }

    goBack() {
        window.history.back();
    }
}