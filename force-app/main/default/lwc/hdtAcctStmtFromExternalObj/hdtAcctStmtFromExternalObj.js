import { LightningElement, api } from 'lwc';

export default class HdtAcctStmtFromExternalObj extends LightningElement {

    @api recordId;

    connectedCallback(){
        console.log('>>> external obj id -> ' + this.recordId);
        //this.recordId = '0011X00000owtvoQAA';
    }

}