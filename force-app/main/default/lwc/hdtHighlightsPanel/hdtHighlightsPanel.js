import { LightningElement, track, api } from 'lwc';

const fields = [
    //'ActiveServices__c',  // spostato fuori dal template iterator
    //'ActiveCampaigns__c', // sostituito con lwc c-hdt-account-highlight-panel
    'SatisfactionIndex__c',
    'RecallerFormula__c',
    'CreditFormula__c',
    'ComplaintRateFormula__c',
];

export default class HdtHighlightsPanel extends LightningElement {
    @api recordId;
    @track fields = fields;
    gridClass = '';

    connectedCallback(){
        var arraySize = fields.length + 2; // + 2 per i servizi attivi e per il KPI Campagne Attive
        this.gridClass = 'slds-col slds-size_1-of-' + arraySize.toString();
        console.log(this.gridClass);
    }


}