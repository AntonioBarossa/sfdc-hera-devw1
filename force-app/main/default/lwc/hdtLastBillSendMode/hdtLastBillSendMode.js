import { LightningElement, api } from 'lwc';

export default class HdtLastBillSendMode extends LightningElement {

    @api theCase;
    recordId;
    recordTypeId;
    accountId;

    _modInvio;
    get modInvio(){
        return this._modInvio == 'Cartaceo';
    }

    onChange(event){
        this.modInvio = event.target.value;
    }

    connectedCallback(){
        this.recordId = this.theCase.Id;
        this.recordTypeId = this.theCase.RecordTypeId;
        this.accountId = this.theCase.AccountId;
    }

}