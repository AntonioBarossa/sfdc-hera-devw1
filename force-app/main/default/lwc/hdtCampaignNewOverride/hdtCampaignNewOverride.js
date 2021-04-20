import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class HdtCampaignNewOverride extends LightningElement {
    @api objectApiName = 'Campaign';

    @api handleSubmit() {
        this.template.querySelector('lightning-record-edit-form').submit();
    }

    handleSuccess(event) {
        console.log(event.detail.id);
        let newRecordId = event.detail.id;
        this.dispatchEvent(new CustomEvent('afterExecution', { detail: {newRecordId} }));
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Campagna Salvata',
                message: '',
                variant: 'success'
            })
        );
    }
}