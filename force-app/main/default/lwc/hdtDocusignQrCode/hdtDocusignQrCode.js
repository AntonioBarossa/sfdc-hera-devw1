import { api, LightningElement, track } from 'lwc';
//import getDocusignUrl from '@salesforce/apex/HDT_LC_DocusignQrCode.getDocusignUrl';
import getObject from '@salesforce/apex/HDT_LC_DocusignQrCode.getObject';
import sendDocument from '@salesforce/apex/HDT_LC_DocumentSignatureManager.sendDocumentFile';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class HdtDocusignQrCode extends LightningElement {

    @api recordId;
    @api objectApiName;
    @track qrcodeUrl = '';
    @track docusignUrl;
    processRecord = {};

    connectedCallback(){
        this.getObject();
    }

    get hasDocusignUrl(){
        return this.docusignUrl !== undefined && this.docusignUrl != null;
    }

/*     getDocusignUrl(){
        getDocusignUrl({
            recordId: this.recordId,
            objectApiName: this.objectApiName
        }).then(result => {
            this.docusignUrl = result;
            console.log('docusign url: ' + this.docusignUrl);
            this.qrcodeUrl = 'https://chart.googleapis.com/chart?chs=400x400&cht=qr&chl=' + this.docusignUrl + '&choe=UTF-8';
        })
        .catch(error => {
            console.error(error);
        });
    } */

    getObject(){
        getObject({
            recordId: this.recordId,
            objectApiName: this.objectApiName
        }).then(result => {
            if (result != null){
                this.processRecord = JSON.parse(result);
                console.log('object fields: ' + JSON.stringify(this.processRecord));
                if (this.processRecord['DocusignURL__c'] !== undefined && this.processRecord['DocusignURL__c'] != null){
                    this.docusignUrl = this.processRecord['DocusignURL__c'];
                    console.log('docusign url: ' + this.docusignUrl);
                    this.qrcodeUrl = 'https://chart.googleapis.com/chart?chs=400x400&cht=qr&chl=' + this.docusignUrl + '&choe=UTF-8';
                }
            }
        })
        .catch(error => {
            console.error(error);
        });
    }

    resendFile(){
        try{
            let telefono = this.processRecord['PhoneNumber__c'];
            let email = this.objectApiName && this.objectApiName.localeCompare('Order') === 0 ? this.processRecord['ShippingMail__c'] : this.processRecord['Email__c'];
            let tipoPlico = '';
            // Gestione stampe da processo di piano rateizzazione
            // Va mandato TipoPLico = 'RICH_RATEIZZAZIONE' per stampare i moduli di autorizzazione del piano rata.
            if (this.objectApiName && this.objectApiName.localeCompare('Case') === 0 && this.processRecord['Type'] != null && this.processRecord['Type'].localeCompare('Piano Rateizzazione')){
                tipoPlico = 'RICH_RATEIZZAZIONE';
            }
            var formParams = {
                sendMode : 'E-Mail',
                signMode : 'OTP Coopresenza',
                telefono : telefono,
                email : email,
                TipoPlico : tipoPlico,
                mode : 'Print',
                Archiviato : 'Y'
            }
            console.log('formParams: ' + JSON.stringify(formParams));
            sendDocument({
                recordId: this.recordId,
                context: this.objectApiName,
                formParams: JSON.stringify(formParams)
            }).then(result => {
                console.log('resend ok');
                this.showMessage('', 'Nuova Busta Docusign in fase di preparazione. Attendi qualche secondo e ricarica la pagina per inquadrare il nuovo QR Code.','success');
            }).catch(error => {
                this.showMessage('Errore', 'Errore nella rigenerazione della Busta Docusign.','error');
                console.error(error);
            });
        }catch(error){
            console.error(error);
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

}