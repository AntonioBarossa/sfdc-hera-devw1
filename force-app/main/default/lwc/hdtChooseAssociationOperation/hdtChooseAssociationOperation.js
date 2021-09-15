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

    createAssociation(event){
        console.log('### createAssociation ###');
        const searchEvent = new CustomEvent("createassociation", {
            detail:  ''
        });

        // Dispatches the event.
        this.dispatchEvent(searchEvent);        
    }

    onDelete(event){
        console.log('### createNew ###');
        const createnewEvent = new CustomEvent("deleteassociation", {
            detail:  ''
        });

        // Dispatches the event.
        this.dispatchEvent(createnewEvent);
    }

}