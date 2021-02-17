import { LightningElement, api } from 'lwc';

export default class hdtOrderDossierWizardHeader extends LightningElement {
    @api orderParentRecord;
    orderName = '';
    accountName = '';
    accountFiscalCode = '';
    accountVatNumber = '';
    createdDate = '';

    connectedCallback(){
        console.log('orderParentRecord: ',JSON.parse(JSON.stringify(this.orderParentRecord)));

        this.orderName = this.orderParentRecord.Name;
        this.accountName = this.orderParentRecord.Account.Name;
        this.accountFiscalCode = this.orderParentRecord.Account.FiscalCode__c;
        this.accountVatNumber = this.orderParentRecord.Account.VATNumber__c;
        this.createdDate = this.orderParentRecord.CreatedDate;
    }
}