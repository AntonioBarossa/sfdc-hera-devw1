import { LightningElement, api } from 'lwc';

export default class HdtTableCell extends LightningElement {
    @api record;
    @api field;
    @api fieldType;
    outputvalue;
    showCurrency = false;
    showField = false;
    showIcon = false;
    iconClass = '';

    connectedCallback(){

        switch (this.fieldType) {
            case 'text':
                this.showField = true;
                break;
            case 'checkbox':
                this.showField = true;
                break;
            case 'number':
                this.showCurrency = true;
                break;
            case 'date':
                this.showField = true;
                break;
            case 'icon':

                if(this.record.ordineDiPagamento != undefined){
                    this.iconClass = 'orange-icon';
                } else {

                    if(new Date(this.record.dataScadenza) > new Date()){
                        this.iconClass = 'yellow-icon';
                    } else {
                        this.iconClass = 'red-icon';
                    }
                }

                this.showIcon = true;
                
        }

        //if(this.fieldType == 'number'){
        //    this.showCurrency = true;
        //}

        this.outputvalue = this.record[this.field];
        delete this.record;
        this.field = '';
        this.fieldType = '';
    }
}