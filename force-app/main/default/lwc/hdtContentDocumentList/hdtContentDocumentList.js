import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


const columns = [
    {
        label: 'Nome Allegato',
        fieldName: 'Title',
        type: 'text',
    }, {
        label: 'Tipo',
        fieldName: 'FileType',
        type: 'text'
    }, {
        label: 'Data Creazione',
        fieldName: 'CreatedDate',
        type: 'date'
    },
    {
        type: 'customRowAction',
        fieldName:'Id',
        typeAttributes: {
            recordId: { fieldName: 'Id' }
        }
    }
];
export default class HdtContentDocumentList extends NavigationMixin(LightningElement) {

    @api files;
    @track originalMessage;
    @track isDialogVisible = false;
    columns = columns;

    filePreview(recordId) {
        // Naviagation Service to the show preview
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                // assigning ContentDocumentId to show the preview of file
                selectedRecordId: recordId
            }
        })
    }
    handleClick(event){
        const row = event.detail.row;
    }
    handleRowAction(event) {
        const actionName = event.detail.eventName;
        const recordId = event.detail.recordId;
        console.log(actionName);
        switch (actionName) {
            case 'delete':
                this.originalMessage = recordId;
                //shows the component
                this.isDialogVisible = true;
                break;
            case 'preview':
                    this.filePreview(recordId);

            default:
        }
    
    }
    handleDelete(event) {
        if (event.target) {
            if (event.target.name === 'confirmModal') {
                if (event.detail !== 1) {
                    if (event.detail.status === 'confirm') {
                        //delete content document
                        let contentDocumentId = event.detail.originalMessage;
                        deleteRecord(contentDocumentId)
                            .then(() => {
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Success',
                                        message: 'File deleted',
                                        variant: 'success'
                                    })
                                );
                                this.dispatchEvent(new CustomEvent('filedelete', {}));
                            })
                            .catch(error => {
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Error deleting file',
                                        message: error.body.message,
                                        variant: 'error'
                                    })
                                );
                            });
                    }
                }

                //hides the component
                this.isDialogVisible = false;
            }
        }
    }
}