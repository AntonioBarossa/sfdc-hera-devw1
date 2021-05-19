import { LightningElement, api, track} from 'lwc';

export default class HdtRadioGroup extends LightningElement {
    
    @track options = [];
    @api rowId;
    @api mValue;

    connectedCallback(){
        
        if(this.mValue){
            console.log('>>> m -> true');
            this.options.push({label: 'M', value: 'm', checked: '1'});
            this.options.push({label: 'V', value: 'v', checked: ''});
        } else {
            console.log('>>> m -> false');
            this.options.push({label: 'M', value: 'm', checked: ''});
            this.options.push({label: 'V', value: 'v', checked: '1'});
        }
        console.log(JSON.stringify(this.options));
    }

    handleSelected(event) {
        //window.console.log('selected value ===> '+event.target.value + ' on row -> ' + this.rowId);
 
         const radioSelect = new CustomEvent("radioselect", {
             detail:  {rowId: this.rowId, value: event.target.value}
         });
 
         // Dispatches the event.
         this.dispatchEvent(radioSelect);
 
     }

}