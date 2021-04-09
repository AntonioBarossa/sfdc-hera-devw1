import { LightningElement, track, api } from 'lwc';

const fields = [
    'DataEnrichmentLastUpdate__c'//,
/*     'ActiveServices__c',
    'ActiveCampaigns__c',
    'CreditFormula__c',
    'RecallerFormula__c',
    'ComplaintRateFormula__c',
    'SatisfactionIndex__c' */
];

export default class HdtHighlightsTab extends LightningElement {
    @api recordId;
    @track fields = fields;
    gridClass = '';

    connectedCallback(){
        var arraySize = fields.length;
        this.gridClass = 'slds-col slds-size_1-of-' + arraySize.toString();
        console.log(this.gridClass);
    }


}