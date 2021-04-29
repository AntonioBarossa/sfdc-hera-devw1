import { LightningElement, api, track } from 'lwc';

export default class HdtCustomCombobox extends LightningElement {
        
    @api fieldName;
    @api fieldType;
    @track operator;
    showCombobox = true;

    numberOperator = [
        {label: 'uguale a', value: '='},
        {label: 'maggiore di', value: '>'}
    ];

    textOperator = [
        {label: 'uguale a', value: '='},
        {label: 'contiene i caratteri', value: 'in'}
    ];

    dateOperator = [
        {label: 'uguale a', value: '='},
        {label: 'maggiore di', value: '>'},
    ];

    connectedCallback(){

        switch (this.fieldType) {
            case 'text':
                this.operator = this.textOperator;
                break;
            case 'number':
                this.operator = this.numberOperator;
                break;
            case 'checkbox':
                this.showCombobox = false;
            case 'date':
                this.operator = this.dateOperator;
        }

        if(this.fieldName==='contoContrattuale'){
            this.operator.push({label: 'contiene i valori', value: 'on'});
        }

    }

    handleChange(event) {
        const setOperator = new CustomEvent("setoperator", {
            detail: {fieldName: event.currentTarget.name, operator: event.detail.value}
        });
        // Dispatches the event.
        this.dispatchEvent(setOperator);
    }

}