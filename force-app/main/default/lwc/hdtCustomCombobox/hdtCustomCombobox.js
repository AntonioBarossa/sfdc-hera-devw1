import { LightningElement, api, track } from 'lwc';

export default class HdtCustomCombobox extends LightningElement {
        
    @api fieldName;
    @api fieldType;
    @api defaultOperator;
    @track operator = [
        {label: 'Nessun operatore', value: null}
    ];

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
    
    value = null;

    connectedCallback(){

        this.value = this.defaultOperator;

        switch (this.fieldType) {
            case 'text':
                this.operator = this.operator.concat(this.textOperator);
                break;
            case 'number':
                this.operator = this.operator.concat(this.numberOperator);
                break;
            case 'checkbox':
                this.showCombobox = false;
            case 'date':
                this.operator = this.operator.concat(this.dateOperator);
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