import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class HdtCreateCampaign extends LightningElement {
    // objectApiName is "Campaign" when this component is placed on an account record page
    //@api objectApiName;
    objectApiName = 'Campaign';
    @track loaded = false;

    fields = [
        { 'fieldName': 'Name', 'required': true, 'class': 'slds-col slds-size_1-of-2 slds-p-around--x-small' },
        { 'fieldName': 'Status', 'required': false, 'class': 'slds-col slds-size_1-of-2 slds-p-around--x-small' },
        { 'fieldName': 'Category__c', 'required': false, 'class': 'slds-col slds-size_1-of-2 slds-p-around--x-small' },
        { 'fieldName': 'Target__c', 'required': false, 'class': 'slds-col slds-size_1-of-2 slds-p-around--x-small' },
        { 'fieldName': 'Description', 'required': false, 'class': 'slds-col slds-size_1-of-1 slds-p-around--x-small' },
        { 'fieldName': 'StartDate', 'required': true, 'class': 'slds-col slds-size_1-of-2 slds-p-around--x-small' },
        { 'fieldName': 'EndDate', 'required': false, 'class': 'slds-col slds-size_1-of-2 slds-p-around--x-small' },
        { 'fieldName': 'Segment__c', 'required': false, 'class': 'slds-col slds-size_1-of-2 slds-p-around--x-small' },
        { 'fieldName': 'TargetDescription__c', 'required': false, 'class': 'slds-col slds-size_1-of-2 slds-p-around--x-small' },
        { 'fieldName': 'TargetingMode__c', 'required': true, 'class': 'slds-col slds-size_1-of-2 slds-p-around--x-small' },
        { 'fieldName': 'Priority__c', 'required': false, 'class': 'slds-col slds-size_1-of-2 slds-p-around--x-small' },
        { 'fieldName': 'ReitekIntegrationTechnology__c', 'required': false, 'class': 'slds-col slds-size_1-of-2 slds-p-around--x-small' }, //obbligatorio per campagne outbound con canale telefonico
        { 'fieldName': 'ParentId', 'required': false, 'class': 'slds-col slds-size_1-of-2 slds-p-around--x-small' },
        { 'fieldName': 'Tipology__c', 'required': false, 'class': 'slds-col slds-size_1-of-2 slds-p-around--x-small' },
        { 'fieldName': 'Channel__c', 'required': false, 'class': 'slds-col slds-size_1-of-2 slds-p-around--x-small' },
        { 'fieldName': 'Required__c', 'required': false, 'class': 'slds-col slds-size_1-of-2 slds-p-around--x-small' },
    ];

    handleFormLoad(event) {
        this.loaded = true;
    }

    @api handleSubmit(event) {
        this.template.querySelector('lightning-record-edit-form').submit();
    }

    handleSuccess(event) {
        const evt = new ShowToastEvent({
            title: "Campaign created",
            message: "Record ID: " + event.detail.id,
            variant: "success"
        });
        this.dispatchEvent(evt);
        //reset the form
        const editForm = this.template.querySelector('lightning-record-edit-form');
        editForm.recordId = null;
        //close the modal
        const closeModal = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeModal);
    }
}