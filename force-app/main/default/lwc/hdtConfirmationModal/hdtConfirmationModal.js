import { LightningElement, api } from 'lwc';

export default class HdtConfirmationModal extends LightningElement {

    @api modalHeader;
    @api modalBody;
    @api operation;
    @api enforceConfirmation;

    buttonClick(event){

        var decision = event.currentTarget.dataset.id;

        if(decision=== 'conf' && this.enforceConfirmation != undefined && this.enforceConfirmation){
            const checked = Array.from(
                this.template.querySelectorAll('lightning-input')
            )
            .filter(element => element.checked)
            .map(element => element.name);

            if(checked.length === 0 || !checked.includes('allSafeCheckbox')){
                return;
            }
        }

        const confirmModal = new CustomEvent("confirm", {
            detail:  {
                operation: this.operation,
                decision: decision
            }
        });
        // Dispatches the event.
        this.dispatchEvent(confirmModal);
    }

}