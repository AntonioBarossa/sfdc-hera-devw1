import { LightningElement, api } from 'lwc';

export default class HdtConfirmationModal extends LightningElement {

    @api modalHeader;
    @api modalBody;
    @api operation;

    buttonClick(event){

        const confirmModal = new CustomEvent("confirm", {
            detail:  {
                operation: this.operation,
                decision: event.currentTarget.dataset.id
            }
        });
        // Dispatches the event.
        this.dispatchEvent(confirmModal);
    }

}