import { LightningElement, api } from 'lwc';

export default class HdtInputField extends LightningElement {
    @api field;
    @api fieldType;
    showCurrency;

    connectedCallback(){
        if(this.fieldType == 'number'){
            this.showCurrency = true;
        }
    }

    setIntParam(event){       
        var fieldId = event.target.id.split("-")[0];
        var value = event.target.value;
        const setTDvalue = new CustomEvent("settdvalue", {
            detail:  {fieldId: fieldId, value: value}
        });
        // Dispatches the event.
        this.dispatchEvent(setTDvalue);
    }   
}