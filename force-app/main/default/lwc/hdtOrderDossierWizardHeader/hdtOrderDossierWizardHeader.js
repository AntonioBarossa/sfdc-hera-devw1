import { LightningElement, api } from 'lwc';

export default class hdtOrderDossierWizardHeader extends LightningElement {
    @api orderParentRecord;
    orderNumber = '';
    orderNumberLink = '';
    orderName = '';
    accountName = '';
    firstName = '';
    lastName = '';
    accountFiscalCode = '';
    accountVatNumber = '';
    phase = '';
    createdDate = '';
    isAccountBusiness = false;

    connectedCallback(){
        console.log('orderParentRecord: ',JSON.parse(JSON.stringify(this.orderParentRecord)));

        this.orderName = this.orderParentRecord.Name;
        this.orderNumber = this.orderParentRecord.OrderNumber;
        this.accountName = this.orderParentRecord.Account.Name;
        this.firstName = this.orderParentRecord.Account.FirstName__c;
        this.lastName = this.orderParentRecord.Account.LastName__c;
        this.accountFiscalCode = this.orderParentRecord.Account.FiscalCode__c;
        this.accountVatNumber = this.orderParentRecord.Account.VATNumber__c;
        this.phase = this.orderParentRecord.Phase__c;
        this.createdDate = this.orderParentRecord.CreatedDate;
        this.isAccountBusiness = this.orderParentRecord.Account.RecordType.DeveloperName === 'HDT_RT_Business';
    }
}