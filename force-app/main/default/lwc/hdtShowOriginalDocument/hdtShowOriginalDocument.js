import { LightningElement, track, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import showOriginalDocument from '@salesforce/apex/HDT_LC_DocumentSignatureManager.showOriginalDocument';

export default class HdtShowOriginalDocument extends NavigationMixin(LightningElement) {

    @api recordId;
    rendered = false;

    renderedCallback(){
        // Usiamo this.rendered per assicurarci di chiamare una volta sola il metodo.
        if (this.recordId != undefined && this.rendered === false) {
            this.rendered = true;
            this.showOriginalDocument();
        }
    }

    showOriginalDocument(){
        try{
            showOriginalDocument({
                recordId: this.recordId
            }).then(result => {
                var resultParsed = JSON.parse(result);
                if(resultParsed.outcome === 'OK'){
                    if (resultParsed.type === 'pdf') {
                        this.showPdfFromBase64(resultParsed.base64);
                        this.closeAction();
                    } else if (resultParsed.type === 'zip') {
                        // TODO: convertire base64 in zip e farlo scaricare nel browser
                    }
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
        base64 = base64.replace(/^[^,]+,/, '');
        base64 = base64.replace(/\s/g, '');
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