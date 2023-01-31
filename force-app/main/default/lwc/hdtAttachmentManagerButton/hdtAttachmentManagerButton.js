import { LightningElement, api ,track} from 'lwc';
import getOrderForButton from  "@salesforce/apex/HDT_LC_AttachmentManager.getOrderForButton"

export default class HdtAttachmentManagerButton extends LightningElement {

    @api recordId;
    @api parentRecordId;
    @api params;
    @api additionalAttachments;
    @track isModalOpen = false;
    
    async openModal() {
        this.params = await this.outputObject();
        this.isModalOpen = true;
    }
    closeModal() {
        this.isModalOpen = false;
    }

    async outputObject(){
        console.log('order figlio ->' + this.recordId);
        let outputObject = await getOrderForButton({ recordId: this.recordId });
        return outputObject;
    }

    handleCloseAttachment(event){
        this.dispatchEvent(new CustomEvent('close_attachment_manager', { bubbles: true, composed: true, detail: event.detail }));
    }
}