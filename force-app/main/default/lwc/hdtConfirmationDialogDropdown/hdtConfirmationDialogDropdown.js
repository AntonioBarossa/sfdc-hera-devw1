import { LightningElement, api } from 'lwc';

export default class hdtConfirmationDialogDropdown extends LightningElement {

    @api objectApiName; //object apiname on which it will be used
    @api picklistApiName; //picklist field apiname that will be displayed
    @api visible; //used to hide/show dialog
    @api title; //modal title
    @api name; //reference name of the component
    @api message; //modal message
    @api confirmLabel; //confirm button label
    @api cancelLabel; //cancel button label
    @api originalMessage; //any event/message/detail to be published back to the parent component
    choice = '';
    get isConfirmDisabled(){
        return this.choice === '' ? true : false;
    }

    //get value from dropdown list
    handleDropdownChoice(event){
        this.choice = event.target.value;
    }

    //handles button clicks
    handleClick(event){
        //get status in boolean variable ('confirm' => true; 'cancel' => false)
        let status = event.target.name == 'confirm' ? true : false;

        //creates object which will be published to the parent component
        let finalEvent = {
            originalMessage: this.originalMessage,
            status: status, //status which will be "true for confirm" and "false for cancel"
            choice: this.choice //selected choice
        };

        //dispatch a 'click' event so the parent component can handle it
        this.dispatchEvent(new CustomEvent('click', {detail: finalEvent}));

        //reset choice
        this.choice = '';
    }

}