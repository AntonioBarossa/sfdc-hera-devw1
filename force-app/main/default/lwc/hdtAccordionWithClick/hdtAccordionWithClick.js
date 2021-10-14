import { LightningElement, api } from 'lwc';
import { getRecord, getFieldValue, updateRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';

export default class HdtAccordionWithClick extends LightningElement {
    @api sections;

    @api
    refreshValues(recordId) {

        updateRecord({fields: { Id: recordId }});

    }

}