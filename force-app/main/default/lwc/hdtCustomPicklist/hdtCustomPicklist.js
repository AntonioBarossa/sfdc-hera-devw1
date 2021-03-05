import { LightningElement,api,track } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';

export default class HdtCustomPicklist extends LightningElement {

    @api label;
    @api value;
    @api placeholder;
    @api options;
    @api outcome;
    @api required;

    handleChange(event){
        console.log(event.detail.value);
        this.outcome = event.detail.value;
        const attributeChangeEvent = new FlowAttributeChangeEvent('outcome', event.detail.value);
        this.dispatchEvent(attributeChangeEvent);
    }

    get listOptions(){
            console.log('List opt JSON '+this.options);
            return JSON.parse(this.options);
    }
    connectedCallback(){

    }
}