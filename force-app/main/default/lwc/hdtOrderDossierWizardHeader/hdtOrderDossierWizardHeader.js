import { LightningElement, api } from 'lwc';

export default class hdtOrderDossierWizardHeader extends LightningElement {
    @api orderParentRecord;
    orderName = '';
    accountName = '';
    accountFiscalCode = '';
    accountVatNumber = '';

    connectedCallback(){
        this.orderName = this.orderParentRecord.Name;
        this.accountName = this.orderParentRecord.Account.Name;
        this.accountFiscalCode = this.orderParentRecord.Account.FiscalCode__c;
        this.accountVatNumber = this.orderParentRecord.Account.VATNumber__c;
    }
}