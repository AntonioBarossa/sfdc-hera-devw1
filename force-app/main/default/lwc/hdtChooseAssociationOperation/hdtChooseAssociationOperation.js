import { LightningElement, api } from 'lwc';

export default class HdtChooseAssociationOperation extends LightningElement {

    @api iconName;
    @api mainTitleLabel;
    @api deleteTitleLabel;
    @api associationTitleLabel;
    @api enableCreate;
    @api enableDelete;

    createAssociationClass;
    deleteAssociationClass;

    createAssociationTitle;
    deleteAssociationTitle;

    connectedCallback(){
        this.createAssociationClass = (this.enableCreate) ? 'slds-box slds-box_link slds-media' : 'slds-box slds-box_link slds-media isDisabled';
        this.deleteAssociationClass = (this.enableDelete) ? 'slds-box slds-box_link slds-media' : 'slds-box slds-box_link slds-media isDisabled';
        this.createAssociationTitle = (this.enableCreate) ? 'Puoi associare i prodotti opzione' : 'Lo stato del prodotto opzione non è compatibile';
        this.deleteAssociationTitle = (this.enableDelete) ? 'Puoi eliminare i prodotti opzione' : 'Lo stato del prodotto opzione non è compatibile';
    }

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
        if(this.enableCreate){
            const searchEvent = new CustomEvent("createassociation", {
                detail:  ''
            });
    
            // Dispatches the event.
            this.dispatchEvent(searchEvent); 
        }
    }

    onDelete(event){
        console.log('### createNew ###');
        if(this.enableDelete){
            const createnewEvent = new CustomEvent("deleteassociation", {
                detail:  ''
            });

            // Dispatches the event.
            this.dispatchEvent(createnewEvent);
        }
    }

}