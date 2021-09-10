import { api, LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import initialize from '@salesforce/apex/HDT_LC_SendCertificationRequest.initialize';

import successLabel from '@salesforce/label/c.Success';
import errorLabel from '@salesforce/label/c.Error';

export default class HdtSendCertificationRequest extends LightningElement {

    @api objectapiname;
    @api recordId;

    loading = true;

    connectedCallback() {
        console.log(this.objectapiname);
        console.log(this.recordId);

        initialize({
            objectapiname: this.objectapiname,
            recordId: this.recordId
        })
        .then(result => {

            if (result.error == false) {

                this.handleToastEvent(successLabel, result.resultMessage, 'success', null);
                
            } else {

                console.log('HdtSendCertificationRequest.initialize - Error: ' + result.errorMessage);
                console.log('HdtSendCertificationRequest.initialize - ErrorStackTrace: ' + result.errorStackTraceString);

                this.handleToastEvent(errorLabel, result.errorMessage, 'error', null);

            }

            this.loading = false;

            const quitAction = new CustomEvent('operationcompleted', { detail: { closeAction: true } });            
            this.dispatchEvent(quitAction);

        })
        .catch(error => {

            this.loading = false;
            console.log('HdtSendCertificationRequest.initialize - Javascript Error: ', error);

            this.handleToastEvent(errorLabel, error, 'error', null);

            const quitAction = new CustomEvent('operationcompleted', { detail: { closeAction: true } });            
            this.dispatchEvent(quitAction);

        })
    }

    handleToastEvent(title, message, variant, mode) {

        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });

        this.dispatchEvent(toastEvent);

    }
}