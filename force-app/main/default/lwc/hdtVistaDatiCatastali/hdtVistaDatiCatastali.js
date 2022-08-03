import { LightningElement, api } from 'lwc';
import getVistaDatiCatastali from '@salesforce/apex/HDT_UTL_LandRegistry.getVistaDatiCatastali';

export default class HdtVistaDatiCatastali extends LightningElement {

    @api recordId;

    cols = [];
    rows = [];

    connectedCallback(){
        getVistaDatiCatastali({recordId: this.recordId})
            .then(result => {
                //assegnare rows
            })
            .catch(error => console.error(error));
    }
}