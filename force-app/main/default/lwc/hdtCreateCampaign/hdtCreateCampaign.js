import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class HdtCreateCampaign extends LightningElement {
    // objectApiName is "Campaign" when this component is placed on an account record page
    //@api objectApiName;
    objectApiName = 'Campaign';
    @track loaded = false;
    @track reitekFieldRequired = false;

    handleFormLoad(event) {
        this.loaded = true;
    }

    handleChangeChannel(event) {
        if (event.detail.value === 'Telefonico Outbound') {
            this.reitekFieldRequired = true;
        } else {
            this.reitekFieldRequired = false;
        }
    }

    @api handleSubmit(event) {
        let isValid = true;
        const fields = this.template.querySelectorAll('lightning-input-field');
        fields.forEach(element => {
            element.reportValidity();
        });
        if (isValid) {
            this.template.querySelector('lightning-record-edit-form').submit();
        } else {
            reitekFld.reportValidity();
        }
    }

    handleError(event) {
        console.log(event.detail.message);
    }

    handleSuccess(event) {
        const evt = new ShowToastEvent({
            title: "Campaign created",
            message: "Record ID: " + event.detail.id,
            variant: "success"
        });

        this.dispatchEvent(evt);
        //reset the form
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
        //close the modal
        this.dispatchEvent(new CustomEvent('close'));
    }
}