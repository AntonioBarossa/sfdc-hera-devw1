import { LightningElement,api} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { FlowNavigationFinishEvent} from 'lightning/flowSupport';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import previewDocumentFile from '@salesforce/apex/HDT_LC_DocumentSignatureManager.previewDocumentFile';


export default class HdtViewPdfForPaperless extends NavigationMixin(LightningElement) {
    @api recordId;

    connectedCallback(){
        try{
            var formParams = {
                sendMode : 'Stampa Cartacea',
                signMode : 'Cartacea',
                mode : 'Preview',
                Archiviato : 'N'
            };
            
            previewDocumentFile({
                recordId: this.recordId,
                context: 'Case',
                formParams: JSON.stringify(formParams)
            }).then(result => {
                var resultParsed = JSON.parse(result);
                if(resultParsed.code === '200' || resultParsed.code === '201'){
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
                        this[NavigationMixin.Navigate](
                            {
                                type: 'standard__webPage',
                                attributes: {
                                    url: blobURL
                                }
                            }
                        );
                    }else{
                        this.showMessage('Attenzione',resultParsed.message,'error');
                    }
                }else{
                    this.showMessage('Attenzione','Errore nella composizione del plico','error');
                }
                this.closeFlow();
            })
            .catch(error => {
                this.showMessage('Attenzione',error,'error');
                this.closeFlow();
            });
        }catch(error){
            this.showMessage('Attenzione',error.message,'error');
            this.closeFlow();
        }
    }

    closeFlow(){
        const navigateFinish = new FlowNavigationFinishEvent();
        this.dispatchEvent(navigateFinish);
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
}