import { LightningElement, api, track } from 'lwc';

export default class HdtFlowInvoiceSelection extends LightningElement {
    @api accountId;
    @track statementType = 'ORDINARIO';

    setStatementType(event){
        this.statementType = event.detail;
    }
}