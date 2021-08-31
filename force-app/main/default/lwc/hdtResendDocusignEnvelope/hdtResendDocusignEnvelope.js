import { LightningElement, track, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import resendDocusignEnvelope from '@salesforce/apex/HDT_LC_DocumentSignatureManager.resendDocusignEnvelope';

export default class HdtResendDocusignEnvelope extends NavigationMixin(LightningElement) {

    @api recordId;
    rendered = false;

    renderedCallback(){
        // Usiamo this.rendered per assicurarci di chiamare una volta sola il metodo.
        if (this.recordId != undefined && this.rendered === false) {
            this.rendered = true;
            this.resendDocusignEnvelope();
        }
    }

    resendDocusignEnvelope(){
        try{
            resendDocusignEnvelope({
                recordId: this.recordId
            }).then(result => {
                var resultParsed = JSON.parse(result);
                console.log('result: ' + result);
                if(resultParsed.outcome === 'OK'){
                    this.closeAction();
                    this.showSuccessMessage('Re-invio busta effettuato con successo.');
                }else{
                    if(resultParsed.errorMessage != null && resultParsed.errorMessage != undefined){
                        this.closeAction();
                        this.showErrorMessage(resultParsed.errorMessage);
                    }else{
                        this.closeAction();
                        this.showErrorMessage('Impossibile re-inviare la busta di Docusign.');
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

    showSuccessMessage(successMessage){
        this.dispatchEvent(
            new ShowToastEvent({
                title: '',
                message: successMessage,
                variant: 'success'
            }),
        );
    }
}