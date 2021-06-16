import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import controllerHandler from '@salesforce/apex/HDT_LC_DocumentalConfigController.controllerHandler';
import getDocument from '@salesforce/apex/HDT_LC_DocumentalConfigController.getDocument';
import { NavigationMixin } from 'lightning/navigation';

export default class HdtDocumentalPayloadAdministration extends NavigationMixin(LightningElement) {

    showSpinner = true;
    showDataList = false;
    showEmpty = false;
    showError = false;
    documents = [];
    errorDataList = [];

    @track modalObj = {
        isVisible: false,
        header: '',
        body: '',
        operation: ''
    }

    connectedCallback(){
        console.log('>>> connectedCallback');
        this.getDocument();
    }

    getDocument(){
        console.log('>>> getDocument');
        getDocument().then(result => {
            console.log('# getDocument #');
    
            if(result.length>0){
                this.documents = result;
                this.showSpinner = false;
                this.showDataList = true;
                this.showEmpty = false;
                this.showError = false;
            } else {

            }

        }).catch(error => {
            console.log('# getDocument error #');
            console.log('# resp -> ' + result.message);
        });
    }

    generateDoc(event){
        console.log('>>> generateDoc');
        this.showSpinner = true;

        controllerHandler().then(result => {
            console.log('# controllerHandler #');
    
            var toastObj = {};

            if(result.success){
                toastObj.title = 'Successo';
                toastObj.message = result.message;
                toastObj.variant = 'success';
                this.showDataList = true;
                this.showError = false;
                this.getDocument();
            } else {
                toastObj.title = 'Attenzione';
                toastObj.message = result.message;
                toastObj.variant = 'warning';

                console.log('>>> ' + JSON.stringify(result));

                this.errorDataList = result.errorData;
                this.showDataList = false;
                this.showError = true;          
            }
    
            this.showSpinner = false;
            this.showEmpty = false;

            this.dispatchEvent(
                new ShowToastEvent({
                    title: toastObj.title,
                    message: toastObj.message,
                    variant: toastObj.variant
                }),
            );

            
            this.showSpinner = false;

        }).catch(error => {
            console.log('# controllerHandler error #');
            console.log('# resp -> ' + result.message);
        });

    }

    navigateToWebPage(event) {
        console.log('>>> navigateToWe -> ' + event.currentTarget.dataset.id);
        var id = event.currentTarget.dataset.id;
        // Navigate to a URL
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/servlet/servlet.FileDownload?file=' + id
            }
        },
        false // Replaces the current page in your browser history with the URL
      );
    }

    openConfirmation(event){
        try {

            this.modalObj.header = 'Generazione JSON';
            this.modalObj.body = 'Vuoi confermare?';
            this.modalObj.isVisible = true;
            this.modalObj.operation = event.target.name;

        } catch(e){
            console.error('# Name => ' + e.name );
            console.error('# Message => ' + e.message );
            console.error('# Stack => ' + e.stack );
        }
    }

    modalResponse(event){
        if(event.detail.decision === 'conf'){
            this[event.detail.operation](event);
        }
        this.modalObj.isVisible = false;
    }

}