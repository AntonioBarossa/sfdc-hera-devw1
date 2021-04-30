import { LightningElement, api } from 'lwc';

export default class HdtTableCell extends LightningElement {
    @api record;
    @api field;
    @api fieldType;
    outputvalue;
    showCurrency;

    connectedCallback(){
        //console.log('# ' + this.record);
        if(this.fieldType == 'number'){
            this.showCurrency = true;
        }
        this.outputvalue = this.record[this.field];
        delete this.record;
        this.field = '';
        this.fieldType = '';
    }
}