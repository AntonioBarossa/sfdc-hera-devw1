import { LightningElement, api } from 'lwc';

export default class HdtViewResult extends LightningElement {

    @api resultData;
    showData;

    connectedCallback(){
        this.showData = this.resultData;
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