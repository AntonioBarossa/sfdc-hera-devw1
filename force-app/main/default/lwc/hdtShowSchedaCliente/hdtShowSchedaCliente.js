import { LightningElement, track, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import previewDocumentFile from '@salesforce/apex/HDT_LC_DocumentSignatureManager.previewDocumentFile';

export default class HdtShowOriginalDocument extends NavigationMixin(LightningElement) {

    @api recordId;
    rendered = false;

    renderedCallback(){
        // Usiamo this.rendered per assicurarci di chiamare una volta sola il metodo.
        if (this.recordId != undefined && this.rendered === false) {
            this.rendered = true;
            this.showSchedaCliente();
        }
    }

    showSchedaCliente(){
        try{
            var formParams = {      
                mode : 'Preview',
                Archiviato : 'N',
                TipoPlico:'Scheda Cliente'
            };
            previewDocumentFile({
                recordId: this.recordId,
                context: 'Account',
                formParams: JSON.stringify(formParams)
            }).then(result => {
                var resultParsed = JSON.parse(result);
                if(resultParsed.code === '200'){
                    if(resultParsed.result === '000'){
                        var base64 = resultParsed.base64;
                        var sliceSize = 512;
                        var byteCharacters = window.atob(base64);
                        var byteArrays = [];

                        for ( var offset = 0; offset < byteCharacters.length; offset = offset + sliceSize ) {
                            var slice = byteCharacters.slice(offset, offset + sliceSize);
                            var byteNumbers = new Array(slice.length);
                            for (var i = 0; i < slice.length; i++) {
                                byteNumbers[i] = slice.charCodeAt(i);
                            }
                            var byteArray = new Uint8Array(byteNumbers);

                            byteArrays.push(byteArray);
                        }

                        this.blob = new Blob(byteArrays, { type: 'application/pdf' });

                        const blobURL = URL.createObjectURL(this.blob);
                        this.url = blobURL;
                        this.fileName = 'myFileName.pdf';
                        this.showFile = true;
                        this.showSpinner = false;
                        this[NavigationMixin.Navigate](
                            {
                                type: 'standard__webPage',
                                attributes: {
                                    url: blobURL
                                }
                            }
                        );
                        this.closeAction();
                    }else{
                        this.showSpinner = false;
                        this.showMessage('Attenzione',resultParsed.message,'error');
                        this.closeAction();
                    }
                }else{
                    this.showSpinner = false;
                    this.showMessage('Attenzione','Errore nella composizione del plico','error');
                    this.closeAction();
                }
            })
            .catch(error => {
                this.showSpinner = false;
                console.error(error);
            });
        }catch(error){
            this.closeAction();
            console.error('error: ' + JSON.stringify(error));
        }
    }

    showMessage(title,message,variant){
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            }),
        );
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