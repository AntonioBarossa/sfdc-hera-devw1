import { LightningElement, track, api } from 'lwc';

export default class HdtPaperCampaignFields extends LightningElement {
    @api paperRecordId;
    @api reqrec;  // Start HRAWRM-621 16/09/2021
    @track campaignName;

    handleFormLoad() {
    }

    @api handleSubmit(cmp) {
        //check if form is valid
        this.template.querySelector('lightning-input-field.nameField').value = cmp;
        let fields = this.template.querySelectorAll('lightning-input-field.obb');
        let notValid = [];
        fields.forEach(field => {
            if (field.value == '' || field.value == null) {
                field.reportValidity();
                notValid.push(false);
            }
        });
        console.log(notValid);
        if (notValid.length > 0 && this.reqrec==true) {
            let msg = "Completa tutti i campi obbligatori";
            this.dispatchEvent(new CustomEvent('erroroccurred', { detail: { msg } }));
        } else {
            this.template.querySelector('lightning-record-edit-form.paperForm').submit();
        }
    }

    handleError(event) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: "Update failed!",
                message: event.detail.message,
                variant: "error"
            })
        );
    }

    handleSuccess(event) {
        //dispact event to parent
        let newRecordId = event.detail.id;
        this.dispatchEvent(new CustomEvent('recordsubmitted', { detail: { newRecordId } }));
        console.log("paper success " + newRecordId);
    }
}