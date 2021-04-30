import { LightningElement,api } from 'lwc';

export default class HdtMockCmp extends LightningElement {

    @api isLoaded;

    connectedCallback() {
        this.openMainSpinner();

        setTimeout(() => {
            this.closeMainSpinner();         
        }, 2000);
        this.isLoaded = true;
    }

    openMainSpinner(){
        const openSpinner = new CustomEvent("openspinner", {
            detail:  ''
        });
        // Dispatches the event.
        this.dispatchEvent(openSpinner);        
    }

    closeMainSpinner(){
        const removeSpinner = new CustomEvent("removespinner", {
            detail:  ''
        });
        // Dispatches the event.
        this.dispatchEvent(removeSpinner);
    }

    @api cancelData(){
        console.log('# cancel data mock #');
    }

    @api reopenTab(){
        console.log('# reopenTab #');
        this.openMainSpinner();

        setTimeout(() => {
            this.closeMainSpinner();         
        }, 2000);

    }
}