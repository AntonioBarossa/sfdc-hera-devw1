import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateCampaignMemberStatusValue from '@salesforce/apex/HDT_LC_CampaignsController.updateCampaignMemberStatus';

export default class HdtCampaignMemberNegativeOutcome extends LightningElement {
    @track isModalOpen = false;
    @track value;
    @api campaignMemberId;

    options = [
        { value: 'Black List', label: 'Black List' },
        { value: 'Già Cliente', label: 'Già Cliente' },
        { value: 'Da poco con altro Gestore', label: 'Da poco con altro Gestore' },
        { value: 'Cliente non coperto rete gas', label: 'Cliente non coperto rete gas' },
        { value: 'Non interessato all\'offerta', label: 'Non interessato all\'offerta' },
        { value: 'Prima attivazione', label: 'Prima attivazione' },
        { value: 'Cliente rifiuta la vendita', label: 'Cliente rifiuta la vendita' },
        { value: 'Riaggancia e rifiuta il contatto', label: 'Riaggancia e rifiuta il contatto' },
        { value: 'Fuori Target', label: 'Fuori Target' },
        { value: 'Titolare della fornitura non disponibile', label: 'Titolare della fornitura non disponibile' },
        { value: 'La proposta non è competitiva', label: 'La proposta non è competitiva' }
    ];

    negativeResultClick() {
        this.isModalOpen = true;
    }
    closeModal() {
        this.isModalOpen = false;
    }

    submitDetails() {
        updateCampaignMemberStatusValue({ 'campaignMemberId': this.campaignMemberId, 'statusValue': this.value }).then(data => {
            console.log("ok" + JSON.stringify(data));
            this.isModalOpen = false;
            let status = this.value;
            this.dispatchEvent(new CustomEvent('aftersubmit', { detail: {status} }));
        }).catch(err => {
            console.log(err);
        });
    }

    handleChange(event) {
        this.value = event.detail.value;
        console.log(this.value);
    }

}