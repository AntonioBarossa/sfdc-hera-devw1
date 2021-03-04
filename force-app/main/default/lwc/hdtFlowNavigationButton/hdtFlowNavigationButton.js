import { LightningElement, api } from 'lwc';


export default class HdtFlowNavigationButton extends LightningElement {


    @api nextLabel;
    @api nextVariant;
    @api isDraft;
    @api showBackButton;

    handleClick(event){

        console.log('hdtFlowNavigationButton: ' + event.target.name);
        this.dispatchEvent(new CustomEvent('navigation', {detail: event.target.name}));

    }


}