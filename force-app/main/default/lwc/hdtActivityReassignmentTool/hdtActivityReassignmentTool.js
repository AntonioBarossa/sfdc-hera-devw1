import { LightningElement, api } from "lwc";

export default class HdtActivityReassignmentTool extends LightningElement {
    @api recordId;
    @api idList;
    assignToMeMode = false;

    closeModal() {
        this.dispatchEvent(new CustomEvent('close'));
    }
}