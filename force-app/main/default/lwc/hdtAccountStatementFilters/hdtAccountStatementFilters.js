import { LightningElement } from 'lwc';

export default class HdtAccountStatementFilters extends LightningElement {

    applyFilters(event){

    }

    closeModal(event){
        console.log('# closeModal #');
        const closeEvent = new CustomEvent("closemodal", {
            detail:  ''
        });

        // Dispatches the event.
        this.dispatchEvent(closeEvent);
    }

}