import { LightningElement, api } from 'lwc';

export default class HdtFilterFirstLevelModal extends LightningElement {
    @api columns;

    connectedCallback(){
        console.log(JSON.stringify(this.columns));
    }

    applyFilter(){

    }

    closeModal() {
        console.log('# closeModal #');

        for (var key in this.filterObject) {
            delete this.filterObject[key];
        }

        const closeModal = new CustomEvent("closemodal", {
            detail:  {action: ''}
        });
        // Dispatches the event.
        this.dispatchEvent(closeModal);
    }

}