import { LightningElement, track, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import showArchivedAttachment from '@salesforce/apex/HDT_LC_DocumentSignatureManager.showArchivedAttachment';

export default class HdtShowArchivedAttachment extends NavigationMixin(LightningElement) {

    @api recordId;
    rendered = false;

    renderedCallback(){
        // Usiamo this.rendered per assicurarci di chiamare una volta sola il metodo.
        if (this.recordId != undefined && this.rendered === false) {
            this.rendered = true;
            this.showArchivedAttachment();
        }
    }

    showArchivedAttachment(){
        try{
            showArchivedAttachment({
                recordId: this.recordId
            }).then(result => {
                var resultParsed = JSON.parse(result);
                if(resultParsed.outcome === 'OK'){
                    this.showPdfFromBase64(resultParsed.base64);
                    this.closeAction();
                }else{
                    if(resultParsed.errorMessage != null && resultParsed.errorMessage != undefined){
                        this.closeAction();
                        this.showErrorMessage(resultParsed.errorMessage);
                    }else{
                        this.closeAction();
                        this.showErrorMessage('Impossibile visualizzare il documento archiviato.');
                    }
                }
            })
            .catch(error => {
                this.closeAction();
                console.error('error: ' + JSON.stringify(error));
            });
        }catch(error){
            this.closeAction();
            console.error('error: ' + JSON.stringify(error));
        }
    }

    closeAction(){
        console.log('closing action');
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    showErrorMessage(errorMessage){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Errore',
                message: errorMessage,
                variant: 'error'
            }),
        );
    }

    showPdfFromBase64(base64){
        var sliceSize = 512;
        var byteCharacters = window.atob(base64);
        var byteArrays = [];

        for (var offset = 0; offset < byteCharacters.length; offset = offset + sliceSize) {
            var slice = byteCharacters.slice(offset, offset + sliceSize);
            var byteNumbers = new Array(slice.length);
            for (var i = 0; i < slice.length; i++) {
                byteNumbers[i] = slice.charCodeAt(i);
            }
            var byteArray = new Uint8Array(byteNumbers);
            byteArrays.push(byteArray);
        }

        const blob = new Blob(byteArrays, { type: 'application/pdf' });
        const blobURL = URL.createObjectURL(blob);
        this[NavigationMixin.Navigate](
            {
                type: 'standard__webPage',
                attributes: {
                    url: blobURL
                }
            }
        );
    }
}