import { LightningElement, api } from 'lwc';

export default class HdtInputCheckbox extends LightningElement {
    @api input;
    @api rowId;

    renderedCallback(){
        this.template.querySelectorAll('lightning-input').forEach((but) => {
            if(this.input=='true'){
                but.checked = true;
            } else {
                but.checked = false;
            }
            
        });
    }

    handleCheckboxChange() {

        const checked = Array.from(
            this.template.querySelectorAll('lightning-input')
        ).filter(element => element.checked)
        .map(element => element.name);

        const notChecked = Array.from(
            this.template.querySelectorAll('lightning-input')
        ).filter(element => !element.checked)
        .map(element => element.name);

        var flagChecked = (checked.length > 0 && notChecked.length==0) ? 'true' : 'false';

        const setFlag = new CustomEvent("setflag", {
            detail:  {rowId: this.rowId, flag: flagChecked}
        });

        // Dispatches the event.
        this.dispatchEvent(setFlag);
    
    }

}