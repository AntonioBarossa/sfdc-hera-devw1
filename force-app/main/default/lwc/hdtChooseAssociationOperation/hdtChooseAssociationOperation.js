import { LightningElement, api } from 'lwc';

export default class HdtChooseAssociationOperation extends LightningElement {

    @api iconName;
    @api mainTitleLabel;
    @api deleteTitleLabel;
    @api associationTitleLabel;

    closeModal(event){
        console.log('### closeModal ###');
        const closeEvent = new CustomEvent("closemodal", {
            detail:  ''
        });

        // Dispatches the event.
        this.dispatchEvent(closeEvent);
    }

    onDelete(event){
        console.log('### createNew ###');
        const createnewEvent = new CustomEvent("createnew", {
            detail:  ''
        });

        // Dispatches the event.
        this.dispatchEvent(createnewEvent);
    }

    createAssociation(event){
        console.log('### search ###');
        const searchEvent = new CustomEvent("search", {
            detail:  ''
        });

        // Dispatches the event.
        this.dispatchEvent(searchEvent);        
    }

}