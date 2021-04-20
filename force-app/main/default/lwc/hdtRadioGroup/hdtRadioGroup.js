import { LightningElement, api} from 'lwc';

export default class HdtRadioGroup extends LightningElement {
    @api options;
    @api rowId;

    handleSelected(event) {
        //window.console.log('selected value ===> '+event.target.value + ' on row -> ' + this.rowId);
 
         const radioSelect = new CustomEvent("radioselect", {
             detail:  {rowId: this.rowId, value: event.target.value}
         });
 
         // Dispatches the event.
         this.dispatchEvent(radioSelect);
 
     }

}