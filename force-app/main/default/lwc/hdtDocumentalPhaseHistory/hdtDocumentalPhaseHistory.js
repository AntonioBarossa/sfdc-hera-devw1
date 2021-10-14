import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getDocumentalPhaseHistory from '@salesforce/apex/HDT_LC_DocumentalPhaseHistory.getDocumentalPhaseHistory';
import getParentOrderId from '@salesforce/apex/HDT_LC_DocumentalPhaseHistory.getParentOrderId';
import previewDocumentFile from '@salesforce/apex/HDT_LC_DocumentSignatureManager.previewDocumentFile';

const columns  = [
    { label: 'Da', fieldName: 'OldValue' },
    { label: 'A', fieldName: 'NewValue'},
    { label: 'Data', fieldName: 'CreatedDate', type: 'date',
      typeAttributes:{
        year: "numeric",
        month: "2-digit",
        day: "2-digit",
        hour: "2-digit",
        minute: "2-digit"
      }
    }
];

export default class HdtDocumentalPhaseHistory extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    data = [];
    columns = columns;
    @track parentOrderId;
    @track sendMode;
    @track signMode;
    @track email;
    @track phone;
    @track address;
    @track dataLoaded=false;
    @track showSpinner = false;

    get targetId(){
        let targetId = '';

        if(this.objectApiName && this.objectApiName.localeCompare('Order') === 0 && this.parentOrderId != null){
            targetId = this.parentOrderId;
        }else{
            targetId = this.recordId;
        }

        console.log('target id: ' + targetId);
        return targetId;
    }

    connectedCallback(){
        console.log(this.recordId + ' ' + this.objectApiName);
        this.getHistory();
        this.setEditFormVariables();

        if(this.objectApiName && this.objectApiName.localeCompare('Order') === 0){
            this.getParentOrderId();
        }
    }

    setEditFormVariables(){
        if(this.objectApiName && this.objectApiName.localeCompare('Case') === 0){
            this.sendMode = 'SendMode__c';
            this.signMode = 'SignMode__c';
            this.email = 'Email__c';
            this.phone = 'PhoneNumber__c';
            this.address = 'DeliveryAddress__c';
            this.dataLoaded = true;
        }else if(this.objectApiName && this.objectApiName.localeCompare('Order') === 0){
            this.sendMode = 'DocSendingMethod__c';
            this.signMode = 'SignatureMethod__c';
            this.email = 'ShippingMail__c';
            this.phone = 'PhoneNumber__c';
            this.address = 'ShippingAddressFormula__c';
            this.dataLoaded = true;
        }
    }

    getParentOrderId(){
        getParentOrderId({
            orderId: this.recordId
        }).then(result => {
            if(result != null && result.length>0)
                this.parentOrderId = result;
            else   
                this.parentOrderId = null;
        })
        .catch(error => {
            console.error(error);
        });
    }

    getHistory(){
        getDocumentalPhaseHistory({
            recordId: this.recordId,
            objectApiName: this.objectApiName,
        }).then(result => {
            if(result != null && result.length>0)
                this.data = result;
            else   
                this.data = null;
        })
        .catch(error => {
            console.error(error);
        });
    }

    handlePreview(){
        try{
            this.showSpinner = true;
            let targetId = this.targetId;

            const formParams = {
                mode : 'Preview',
                Archiviato : 'N'
                // TipoPlico:this.tipoPlico // TODO per il piano rate va passato il tipo plico corretto.
            };

            let context = '';
            if(this.objectApiName && this.objectApiName.localeCompare('Case') === 0){
                context = 'Case';
            }else if(this.objectApiName && this.objectApiName.localeCompare('Order') === 0){
                context = 'Order';
            }
            
            previewDocumentFile({
                recordId: targetId,
                context: context,
                formParams: JSON.stringify(formParams)
            }).then(result => {
                const resultParsed = JSON.parse(result);
                if(resultParsed.code === '200' || resultParsed.code === '201'){
                    if(resultParsed.result === '000'){
                        const base64 = resultParsed.base64;
                        this.showSpinner = false;
                        try{
                            this.showPdfFromBase64(base64);
                        }catch(error){
                            console.log('errore nella conversione in PDF...');
                            console.error(error);
                        }
                    }else{
                        this.showSpinner = false;
                        this.showMessage('Attenzione',resultParsed.message,'error');
                    }
                }else{
                    this.showSpinner = false;
                    this.showMessage('Attenzione','Errore nella composizione del plico','error');
                }
            })
            .catch(error => {
                this.showSpinner = false;
                console.error(error);
            });
        }catch(error){
            this.showSpinner = false;
            console.error();
        }
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