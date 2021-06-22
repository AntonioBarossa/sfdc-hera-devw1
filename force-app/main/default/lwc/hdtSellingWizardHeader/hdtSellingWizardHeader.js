import { LightningElement, api, track } from 'lwc';

export default class HdtSellingWizardHeader extends LightningElement {
    @api saleRecord;
    isAccountBusiness = false;

    connectedCallback(){
        console.log('HdtSellingWizardHeader: ', JSON.stringify(this.saleRecord));
        console.log('HdtSellingWizardHeader - Account__r.RecordType.DeveloperName: HDT_RT_Business', this.saleRecord.Account__r.RecordType.DeveloperName);

        if(this.saleRecord.Account__r.RecordType !== undefined){
            this.isAccountBusiness = this.saleRecord.Account__r.RecordType.DeveloperName === 'HDT_RT_Business';
        }
    }
}