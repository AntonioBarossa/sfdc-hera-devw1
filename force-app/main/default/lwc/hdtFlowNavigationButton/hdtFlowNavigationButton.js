import { LightningElement, api } from 'lwc';


export default class HdtFlowNavigationButton extends LightningElement {


    @api nextLabel;
    @api nextVariant;
    @api isDraft;


    handleClick(event){

        this.dispatchEvent(new CustomEvent('navigation', {detail: event.target.name}));


    }


}