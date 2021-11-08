import { LightningElement, api } from "lwc";

export default class HdtActivityReassignToMe extends LightningElement {
    @api recordId;
    @api idList;
    assignToMeMode = true;

    closeModal() {
        this.dispatchEvent(new CustomEvent('close'));
    }
}