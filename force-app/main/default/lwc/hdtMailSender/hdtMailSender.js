import { LightningElement } from "lwc";

export default class HdtMNailSender extends LightningElement {
    bodyMail = 'Ciao Mario Rossi,<br>questa è la prima mail';

    get options() {
        return [
            { label: 'New', value: 'new' },
            { label: 'In Progress', value: 'inProgress' },
            { label: 'Finished', value: 'finished' },
        ];
    }

    handleTemplateChange(event) {
        this.value = event.detail.value;
    }

    handleChange(event) {
        this.bodyMail = event.target.value;
    }

    handleClick(event){
        
    }
}