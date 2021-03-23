import { LightningElement, api } from 'lwc';
export default class HdtRowActionCustomType extends LightningElement {

    @api recordId;
    
    fireDeleteAction() {
        console.log('in');
        const event = new CustomEvent('customrowaction', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                recordId: this.recordId,
                eventName: 'delete'
            },
        });
        console.log('in' + JSON.stringify(event));
        this.dispatchEvent(event);
    }

    firePreviewAction() {
        const event = new CustomEvent('customrowaction', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                recordId: this.recordId,
                eventName: 'preview'
            },
        });
        this.dispatchEvent(event);
    }
}