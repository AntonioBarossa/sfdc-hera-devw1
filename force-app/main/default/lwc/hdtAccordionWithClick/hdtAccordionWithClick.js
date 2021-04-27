import { LightningElement, api } from 'lwc';

export default class HdtAccordionWithClick extends LightningElement {
    @api sections;

    connectedCallback(){
        console.log('HdtAccordionWithClick: ', JSON.stringify(this.sections));
    }

    @api
    refreshValues(recordId) {

        updateRecord({fields: { Id: recordId }});

    }

}