import { LightningElement, api } from 'lwc';

export default class HdtTechnicalOfferSelection extends LightningElement {

    @api tiles;
    @api iconName;
    @api mainTitleLabel;
    @api newTitleLabel;
    @api searchTitleLabel;

    connectedCallback(){
        //enableCreate: false,
        //hasRecords: false,
        //records: []
        this.class1 = (this.tiles.enableCreate) ? 'slds-box slds-box_link slds-media' : 'slds-box slds-box_link slds-media isDisabled';
    }

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
            if(this.tiles.enableCreate){
            const createnewEvent = new CustomEvent("createnew", {
                detail:  ''
            });

            // Dispatches the event.
            this.dispatchEvent(createnewEvent);
        }
    }

    search(event){
        console.log('### search ###');
        if(this.tiles.enableCreate){
            const searchEvent = new CustomEvent("search", {
                detail:  ''
            });

            // Dispatches the event.
            this.dispatchEvent(searchEvent);
        }     
    }

    selectOffer(event){
        console.log('### selectOffer ###');
        console.log('>>> '+event.currentTarget.dataset.name);
        const selectOffer = new CustomEvent("selectoffer", {
            detail: event.currentTarget.dataset.name
        });

        // Dispatches the event.
        this.dispatchEvent(selectOffer);
    }

}