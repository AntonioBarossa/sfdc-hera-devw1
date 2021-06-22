import { LightningElement, api } from 'lwc';

export default class HdtWelcomeMatModal extends LightningElement {

    @api iconName;
    @api mainTitleLabel;
    @api newTitleLabel;
    @api searchTitleLabel;

    closeModal(event){
        console.log('### closeModal ###');
        const closeEvent = new CustomEvent("closemodal", {
            detail:  ''
        });

        // Dispatches the event.
        this.dispatchEvent(closeEvent);
    }

    createNew(event){
        console.log('### createNew ###');
        const createnewEvent = new CustomEvent("createnew", {
            detail:  ''
        });

        // Dispatches the event.
        this.dispatchEvent(createnewEvent);
    }

    search(event){
        console.log('### search ###');
        const searchEvent = new CustomEvent("search", {
            detail:  ''
        });

        // Dispatches the event.
        this.dispatchEvent(searchEvent);        
    }

}