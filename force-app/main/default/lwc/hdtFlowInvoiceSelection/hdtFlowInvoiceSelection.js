import { LightningElement, api, track } from 'lwc';

export default class HdtFlowInvoiceSelection extends LightningElement {
    @api accountId;
    @track statementType = 'ORDINARIO';
    @api invoices;

    setStatementType(event){
        this.statementType = event.detail;
    }

    @api
    validate() {
        let invoiceSelection = this.template.querySelector('c-hdt-account-statement-viewer').getInvoiceSelection();
        this.invoices = invoiceSelection.map(invoice => invoice.numeroFattura).join(';');
        console.log("invoices", this.invoices);

        if (invoiceSelection.length==0) {
            return {
                isValid: false,
                errorMessage: 'Non hai selezionato nessuna fattura'
            };
        }
        else {
            return {
                isValid: true
            };
        }
    }
}