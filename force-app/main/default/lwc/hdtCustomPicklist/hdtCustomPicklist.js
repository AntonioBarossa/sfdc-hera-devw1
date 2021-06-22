import { LightningElement,api,track } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';

export default class HdtCustomPicklist extends LightningElement {

    @api label;
    @api value;
    @api placeholder;
    @api options;
    @api outcome;
    @api required;
    @api disabled;

    connectedCallback(){
    
        console.log('value--> '+this.value);

        if(this.value != null && this.value != ''){
            console.log('inside condition')
            this.outcome = this.value;
            const attributeChangeEvent = new FlowAttributeChangeEvent('outcome', this.value);
            this.dispatchEvent(attributeChangeEvent);
        }

    }

    handleChange(event){
        console.log(event.detail.value);
        this.outcome = event.detail.value;
        // Creates the event with the value data.
        const selectedEvent = new CustomEvent('selected', { detail: event.detail.value });
        const attributeChangeEvent = new FlowAttributeChangeEvent('outcome', event.detail.value);
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
        this.dispatchEvent(attributeChangeEvent);
    }

    get listOptions(){
            console.log('List opt JSON '+this.options);
            return JSON.parse(this.options);
    }

}