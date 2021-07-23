import { LightningElement, api} from 'lwc';

export default class HdtErrorModalMessage extends LightningElement {
    @api header;
    @api bodyMessage;
    @api headerClass;
    @api bodyClass;

    closeModal(event){
        const closeEvent = new CustomEvent("closeerrormodal", {
            detail:  ''
        });

        // Dispatches the event.
        this.dispatchEvent(closeEvent);
    }
}