import { LightningElement, track, api } from 'lwc';
import updateKpis from '@salesforce/apex/HDT_LC_HighlightsPanel.updateKpis';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

const fields = [
    //'ActiveServices__c',  // spostato fuori dal template iterator
    //'ActiveCampaigns__c', // sostituito con lwc c-hdt-account-highlight-panel
    'SatisfactionIndex__c',
    'RecallerFormula__c',
    //'CreditFormula__c', // fix 903689C
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
        this.doUpdateKpis();
    }

    async doUpdateKpis() {
        const error = await updateKpis({accountId: this.recordId});
        if(error) {
            // this.dispatchEvent(new ShowToastEvent({
            //     variant: 'error',
            //     title: 'Errore',
            //     message: 'Impossibile aggiornare i KPI Recaller e Tasso Reclamosità.',
            // }));
            console.log('### hdtHighlightsPanel.js.doUpdatesKpis() - ERROR: ' + error);
        }
    }
}