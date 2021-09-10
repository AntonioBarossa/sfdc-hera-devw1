import { api, LightningElement, track } from 'lwc';
import getDocusignUrl from '@salesforce/apex/HDT_LC_DocusignQrCode.getDocusignUrl';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class HdtDocusignQrCode extends LightningElement {

    @api recordId;
    @api objectApiName;
    @track qrcodeUrl;
    @track docusignUrl;

    connectedCallback(){
        this.getDocusignUrl();
    }

    get hasDocusignUrl(){
        return this.docusignUrl !== undefined && this.docusignUrl != null;
    }

    getDocusignUrl(){
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
    }

}