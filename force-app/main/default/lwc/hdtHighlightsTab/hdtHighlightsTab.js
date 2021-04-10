import { LightningElement, track, api } from 'lwc';

const fields = [
    'DataEnrichmentLastUpdate__c',
    'AssistedCustomer__c',
    'ChurnkRisk__c',
    'AccountRating__c'
];

const clcEnergyFields = [
    'CustomerLifeCycleEle__c',
    'CustomerLifeCycleGas__c'
];

export default class HdtHighlightsTab extends LightningElement {
    @api recordId;
    @track fields = fields;
    @track clcEnergyFields = clcEnergyFields;
    gridClass = '';
    clcEnergyGridClass = '';

    connectedCallback(){
        this.gridClass = 'slds-col slds-size_1-of-' + fields.length.toString();
        this.clcEnergyGridClass = 'slds-col slds-size_1-of-' + clcEnergyFields.length.toString();
    }


}