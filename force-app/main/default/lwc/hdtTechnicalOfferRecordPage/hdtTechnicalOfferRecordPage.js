import { LightningElement, track, api, wire} from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

export default class HdtTechnicalOfferRecordPage extends LightningElement {
    
    @api recordId;
    @track showRecord = false;
    technicalOfferId;
    productid;
    rateObj;

    @wire(getRecord, { recordId: '$recordId', fields: ['TechnicalOffer__c.Product__c', 'TechnicalOffer__c.RateCategory__c', 'TechnicalOffer__c.RateCategory__r.Name', 'TechnicalOffer__c.Template__c'] })
    wiredOptions({ error, data }) {
        if(data){
            try {
                console.log('>> wiredOptions');

                this.rateObj = {
                    rateId: data.fields.RateCategory__c.value,
                    rateName: data.fields.RateCategory__r.value.fields.Name.value,
                    rateTemplate: data.fields.Template__c.value
                };
                
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