import { LightningElement, track, api, wire} from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

export default class HdtTechnicalOfferRecordPage extends LightningElement {
    
    @api recordId;
    @track showRecord = false;
    technicalOfferId;
    productid;


    @wire(getRecord, { recordId: '$recordId', fields: ['TechnicalOffer__c.Product__c'] })
    wiredOptions({ error, data }) {
        if(data){
            try {
                console.log('>> wiredOptions');

                for(var i in data.fields.Product__c ){
                    console.log('>> ' + i + ' - ' + data.fields.Product__c[i]);
                }
                
                this.productid = data.fields.Product__c.value;
                this.technicalOfferId = this.recordId;
                this.showRecord = true;
  
            } catch(e){
                console.log('# Name => ' + e.name );
                console.log('# Message => ' + e.message );
                console.log('# Stack => ' + e.stack );
            }
  
        } else if (error) {
            console.log("# error: ", this.error);
        }
    }

    closeModal(event){

    }

}