import { LightningElement, api } from 'lwc';

export default class HdtAccordionWithClick extends LightningElement {
    @api sections;

    @api
    refreshValues(recordId) {

        updateRecord({fields: { Id: recordId }});

    }

}