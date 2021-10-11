import { LightningElement, api} from 'lwc';
import sendFileToPrint from '@salesforce/apex/HDT_LC_ComunicationsSearchList.sendFileToPrint';
import { NavigationMixin } from 'lightning/navigation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class HdtPdfViewerHandler extends NavigationMixin(LightningElement){

    @api sendPrintFromParent(bodyString){
        console.log('# sendPrintFromParent #');
        this.sendToApex(bodyString);
    }

    sendToApex(bodyString){
        console.log('# sendToApex #');
        //console.log('>>> TO SEND ' + bodyString);
        //bodyString = '{"billNumber":"411911206203","channel":"SOL","date":"2019-11-29","type":"D66l7V","company":"1070"}';
        //bodyString = '{"billNumber":"411709832686","channel":"CRM","date":"2017-12-09","type":"D66l7V","company":"1070"}';
        //bodyString = '{"billNumber":"431900888769","channel":"CRM","date":"2019-12-04","documentType":"Bollette","company":"2060"}';
        console.log('>>> BODY TO RETRIEVE PDF ' + bodyString);
        sendFileToPrint({body: bodyString})
        .then(result => {
            console.log('# save success #');
            console.log('>>> resp: ' + result.success);
    
            var toastObj = {
                title: '',
                message: '',
                variant: ''
            };
    
            if(result.success){
                toastObj.title = 'Successo!';
                toastObj.message = 'Il documento è stato recuperato correttamente';
                toastObj.variant = 'success';


                try{

                    var base64 = result.bodyBase64; 
                    var sliceSize = 512;
                    base64 = base64.replace(/^[^,]+,/, '');
                    base64 = base64.replace(/\s/g, '');
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
                    //var data = new FormData();
                    //data.append("file", blob, "file");

                    const blobURL = URL.createObjectURL(this.blob);
                    //console.log('url-' + blobURL);
                    //window.open(blobURL);
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

                }catch(err){
                    console.log(err.message);
                }

            } else {
                toastObj.title = 'Errore!';
                //toastObj.message = result.message;
                toastObj.message = 'Bolletta non disponibile';
                toastObj.variant = 'warning';
            }
        
            //this.spinner = false;

            this.downloadComplete();

            this.dispatchEvent(
                new ShowToastEvent({
                    title: toastObj.title,
                    message: toastObj.message,
                    variant: toastObj.variant
                }),
            );
    
        })
        .catch(error => {
            this.handleError(error);
        });
        
    }

    openFile(){
        console.log('# openFile #');
        this[NavigationMixin.Navigate](
            {
                type: 'standard__webPage',
                attributes: {
                    url: this.url
                }
            }
        );        
    }

    handleError(error){
        console.error('e.name => ' + error.name );
        console.error('e.message => ' + error.message);
        console.error('e.stack => ' + error.stack);
        this.dispatchEvent(
            new ShowToastEvent({
                title: error.name,
                message: error.message,
                variant: 'error',
                mode: 'sticky'
            })
        );
    }

    resetFile(){
        console.log('# resetFile #');
        this.blob = null;
        this.blobURL = URL.revokeObjectURL();
    }

    downloadComplete(){
        const downloadComplete = new CustomEvent("downloadcomplete", {
            detail:  ''
        });

        // Dispatches the event.
        this.dispatchEvent(downloadComplete);   
    }

}