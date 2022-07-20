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
                // -- montors fix 30/06/2022             
                var dateParts = this.record.dataScadenza.split("/");
                // month is 0-based, that's why we need dataParts[1] - 1
                var dateObject = new Date(+dateParts[2], dateParts[1] - 1, +dateParts[0]);
        
                if(this.record.ordineDiPagamento != undefined){
                    this.iconClass = 'orange-icon';
                } else {
                    //if(new Date(this.record.dataScadenza) > new Date()){ --- montors fix 30/06/2022
                    if(dateObject > new Date()){
                        this.iconClass = 'yellow-icon';
                    } else {
                        this.iconClass = 'red-icon';
                    }
                }
                console.log('---> this.iconClass: ' + this.iconClass);
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